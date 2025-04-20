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

To enter an interactive bash shell with your current working directory mounted: `docker run -it -v "$(pwd):/work" -w /work yuanye1998/bioinfo:latest`. After entering the interactive shell, you may use tools in this container.

To directly run a command (or built-in workflow, see below): `docker run -it -v "$(pwd):/work" -w /work yuanye1998/bioinfo:latest [COMMAND] [ARGUMENT(S)]`. Note that here we also mounted the current working directory.

## Built-in workflows

This image has the following built-in Snakemake workflows:

- DownloadListSRA: Download FASTQ files of a list of SRA accession numbers. Supports paired-end and single-end data.
- AlignBowtie2: (config required) Given gzipped FASTQ files in a folder, perform trimming and alignment with user-provided genome index with bowtie2. Supports paired-end and single-end data.
- AlignSTAR: (config required) Given gzipped FASTQ files in a folder, perform trimming and alignment with user-provided genome index with STAR. Supports paired-end and single-end data.

To use a workflow in the interactive shell and get detailed instructions, use command `smkWorkflows`. For workflows that require configuration, use helper script to get a config template with typical values `smkConfig.sh`.

To run a workflow non-interactively, use `smkWorkflows` as `[COMMAND]`. `[ARGUMENT(S)]` will be forwarded to the snakemake manager itself.

## Misc files

The repository contains the following optional files that might help setup the workflows:

- folder `reference_genome` contains collections of reference genomes with annotations for building aligner index. Currently, we have `dm6` (UCSC).