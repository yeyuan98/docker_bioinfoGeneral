# Docker image for bioinformatics

## Tools

Personal tool collection for common  bioinformatics tasks. Currently included tools are:

### FASTQ and data sourcing

- fastqc, v0.12.1
- NCBI SRAtools, v3.2.1
- cutadapt, v5.0
- trimGalore, v0.6.10

### SAM/BED

- samtools, v1.21
- bedtools, v2.31.0

### Aligner

- bowtie2, v2.5.1
- STAR, v2.7.11b

### Other tools

- snakemake, v7.32.4
- seqtk, latest main branch

## Installation and usage

### Installation

Clone this repo and then build with `docker build -t <TARGET_NAME> .`.

Alternatively, you can pull the container from Docker Hub: `docker pull yuanye1998/bioinfo:latest`.

### Usage

To enter an interactive bash shell with your current working directory mounted: `docker run -it -v "$(pwd):/work" -w /work yuanye1998/bioinfo:latest`.

To execute specific commands without entering interactive mode: `docker run -it bioinfo -c "<YOUR_COMMAND>"`.