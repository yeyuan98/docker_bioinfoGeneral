# Using micromamba even if the image will be larger than they could be

FROM mambaorg/micromamba:2.1.0-alpine3.18

# Configure conda environment
#       https://micromamba-docker.readthedocs.io/en/latest/quick_start.html
# Remove the many build tool packages (probably many are r-base dependencies)
COPY --chown=$MAMBA_USER:$MAMBA_USER env.yaml /tmp/env.yaml
RUN micromamba install -y -n base -f /tmp/env.yaml && \
    micromamba uninstall -y -n base --force gfortran_impl_linux-64 gcc_impl_linux-64 gxx_impl_linux-64 openjdk && \
    micromamba uninstall -y -n base --force ld_impl_linux-64 kernel-headers_linux-64 libgcc-devel_linux-64 && \
    micromamba uninstall -y -n base --force binutils_impl_linux-64 liblzma-devel libstdcxx-devel_linux-64 && \
    micromamba uninstall -y -n base --force sysroot_linux-64 && \
    micromamba clean --all --yes

# Install JRE headless (openjdk from conda contains unwanted dev files)
USER root
RUN apk add --no-cache openjdk11-jre-headless
USER $MAMBA_USER

# Install multiqc (conda recipe contains unwanted packages)
ARG MAMBA_DOCKERFILE_ACTIVATE=1
RUN pip3 install multiqc==1.25 && pip3 cache purge

# Copy snakemake workflows and the manager script
COPY --chown=$MAMBA_USER:$MAMBA_USER ./snakemakeWorkflows /usr/local/bin/snakemakeWorkflows
RUN chmod -R 777 /usr/local/bin/snakemakeWorkflows/bin

# Setup PATH
USER root
RUN echo '#!/usr/bin/env bash' >> /usr/local/bin/_path.sh
RUN echo 'export PATH="$PATH:/usr/local/bin/snakemakeWorkflows/bin"' >> /usr/local/bin/_path.sh
RUN echo 'export PS1="\\W\\$"' >> /usr/local/bin/_path.sh
RUN echo 'exec "$@"' >> /usr/local/bin/_path.sh
RUN chmod 755 /usr/local/bin/_path.sh
USER $MAMBA_USER

# Create container temporary folder
#   For programs that require Linux FS (e.g., STAR requires FIFO files for runtime temp folder)
#       https://github.com/alexdobin/STAR/issues/1776
USER root
RUN mkdir /home/temp
RUN chmod 777 /home/temp
USER $MAMBA_USER

# Setup entrypoint
ENTRYPOINT ["/usr/local/bin/_entrypoint.sh", "/usr/local/bin/_path.sh"]
#   Interactive if no argument provided
CMD ["/bin/bash", "-i"]