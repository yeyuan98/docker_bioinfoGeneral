# Using micromamba even if the image will be larger than they could be

FROM mambaorg/micromamba:2.1.0

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
USER root
RUN apt-get update && apt-get install -y default-jre-headless && apt-get clean
USER $MAMBA_USER

# Copy snakemake workflows and the manager script
COPY --chown=$MAMBA_USER:$MAMBA_USER ./snakemakeWorkflows /usr/local/bin/snakemakeWorkflows
RUN echo 'export PATH="$PATH:/usr/local/bin/snakemakeWorkflows/bin"' >> ~/.profile
RUN chmod -R 777 /usr/local/bin/snakemakeWorkflows/bin

# Create container temporary folder
#   For programs that require Linux FS (e.g., STAR requires FIFO files for runtime temp folder)
#       https://github.com/alexdobin/STAR/issues/1776
USER root
RUN mkdir /home/temp
RUN chmod 777 /home/temp
USER $MAMBA_USER

# Setup login shell entrypoint
ENTRYPOINT ["/usr/local/bin/_entrypoint.sh", "/bin/bash", "-l"]
CMD ["-i"]