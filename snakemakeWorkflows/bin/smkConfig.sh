#!/bin/bash
# Helper for copying snakemake config files.
SOURCE_DIR="/usr/local/bin/snakemakeWorkflows/config_templates"

if [ $# -eq 0 ]; then
    # List available files (basenames without extension)
    for file in "$SOURCE_DIR"/*; do
        basename "${file%.*}"
    done | sort -u

elif [ $# -eq 1 ]; then
    # Copy specified file if exists
    target_basename="$1"
    first_file=$(ls "$SOURCE_DIR"/* | head -n1)
    
    if [ -z "$first_file" ]; then
        echo "Error: Source directory is empty" >&2
        exit 1
    fi
    
    extension="${first_file##*.}"
    target_file="$target_basename.$extension"

    if [ -e "$SOURCE_DIR/$target_file" ]; then
        cp "$SOURCE_DIR/$target_file" .
    else
        echo "Error: File '$target_basename' not found" >&2
        echo "Available files:" >&2
        for file in "$SOURCE_DIR"/*; do
            basename "${file%.*}"
        done | sort -u
        exit 1
    fi

else
    echo "Error: Invalid number of arguments" >&2
    echo "Usage: $0 [filename]" >&2
    exit 1
fi