# Stage 1: Builder environment
FROM debian:bullseye-slim AS builder

# Install build dependencies including download tools
RUN apt-get update && apt-get install -y \
    build-essential wget unzip git curl \
    zlib1g-dev libbz2-dev liblzma-dev \
    libncurses5-dev python3-pip perl \
    openjdk-11-jre && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /build

# All compiled/prebuilt binary goes into /build/bin
RUN mkdir bin

# Download and build components
# Samtools
RUN wget https://github.com/samtools/samtools/releases/download/1.21/samtools-1.21.tar.bz2 && \
    tar -xjf samtools-1.21.tar.bz2 && \
    cd samtools-1.21 && \
    ./configure --prefix=/build/samtools && \
    make && make install && \
    mv /build/samtools/bin/* /build/bin/

# Bedtools
RUN wget https://github.com/arq5x/bedtools2/releases/download/v2.31.0/bedtools-2.31.0.tar.gz && \
    tar -zxvf bedtools-2.31.0.tar.gz && \
    cd bedtools2 && \
    make && mv bin/* /build/bin/

# Seqtk
RUN git clone https://github.com/lh3/seqtk.git && \
    cd seqtk && make && mv seqtk /build/bin/

# Prebuilt binaries
# STAR
RUN wget https://github.com/alexdobin/STAR/releases/download/2.7.11b/STAR_2.7.11b.zip && \
    unzip STAR_2.7.11b.zip -d /build/star/ && \
    mv /build/star/STAR_2.7.11b/Linux_x86_64_static/STAR /build/bin/

# Bowtie2
RUN wget https://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.5.1/bowtie2-2.5.1-linux-x86_64.zip -O bowtie2.zip && \
    unzip bowtie2.zip -d /build/bowtie2/ && \
    mv /build/bowtie2/bowtie2-2.5.1-linux-x86_64/bowtie2* /build/bin/

# FastQC
RUN wget https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.12.1.zip && \
    unzip fastqc_v0.12.1.zip -d /build/fastqc/ && \
    mv /build/fastqc/FastQC /build/bin/FastQC

# Trim Galore
RUN wget https://github.com/FelixKrueger/TrimGalore/archive/0.6.10.tar.gz && \
    tar -zxvf 0.6.10.tar.gz && \
    mv /build/TrimGalore-0.6.10 /build/bin/

# SRA Toolkit
RUN wget https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/3.2.1/sratoolkit.3.2.1-ubuntu64.tar.gz && \
    tar -zxvf sratoolkit.3.2.1-ubuntu64.tar.gz && \
    mv /build/sratoolkit.3.2.1-ubuntu64/bin/* /build/bin/

# Install cutadapt and snakemake
RUN pip3 install --user 'cutadapt==5.0' 'snakemake==7.32.4' 'pulp<2.8' && \
    mv ~/.local /build/bin/.local.pip3

# Stage 2: Runtime environment
FROM debian:bullseye-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    perl python3 openjdk-11-jre \
    pigz zlib1g libbz2-1.0 liblzma5 libncurses6 && \
    rm -rf /var/lib/apt/lists/*

# Copy and organize built components
COPY --from=builder /build/bin /usr/local/bin/
COPY --from=builder /build/bin/.local.pip3 /usr/local/bin/.local.pip3

# Set up symlinks for FastQC and Trim Galore
RUN chmod +x /usr/local/bin/FastQC/fastqc && \
    ln -s /usr/local/bin/FastQC/fastqc /usr/local/bin/fastqc
RUN ln -s /usr/local/bin/TrimGalore-0.6.10/trim_galore /usr/local/bin/trim_galore

# Modify path to include cutadapt library
RUN echo 'export PATH="$PATH:/usr/local/bin/.local.pip3/bin"' >> ~/.profile
RUN echo 'export PYTHONPATH="/usr/local/bin/.local.pip3/lib/python3.9/site-packages"' >> ~/.profile

# Copy snakemake workflows and the manager script
COPY ./snakemakeWorkflows /usr/local/bin/snakemakeWorkflows
RUN echo 'export PATH="$PATH:/usr/local/bin/snakemakeWorkflows/bin"' >> ~/.profile

# Create container temporary folder
RUN mkdir /home/temp
RUN chmod 777 /home/temp

# Set entrypoint and default command
#   Always login shell (entrypoint) so ~/.profile PATH is respected
#       Refer to BASH manual Bash-Startup-Files section.
#   If no command given, "-i" will start an interactive shell.
ENTRYPOINT ["/bin/bash", "-l"]
CMD ["-i"]