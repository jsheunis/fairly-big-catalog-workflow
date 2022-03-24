#!/bin/zsh

# This script ...

# Example usage:
# >>

# ASSIGN VARIABLES FROM ARGUMENTS
BASEDIR=$(dirname "$0")
DATASET_PATH=$1
DATASET_NAME=$(basename "$DATASET_PATH")
OUTFILE=$2

datalad -f json meta-conduct "$BASEDIR/conduct_pipelines/extract_file_metadata.json" \
    traverser.top_level_dir="$DATASET_PATH" \
    traverser.item_type=file \
    extractor.extractor_type=file \
    extractor.extractor_name=metalad_core \
    | jq '.["pipeline_element"]["result"]["metadata"][0]["metadata_record"]' >> $OUTFILE