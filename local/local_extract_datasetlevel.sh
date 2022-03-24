#!/bin/zsh

# This script ...

# Example usage:
# >>

# ASSIGN VARIABLES FROM ARGUMENTS
BASEDIR=$(dirname "$0")
DATASET_PATH=$1
DATASET_NAME=$(basename "$DATASET_PATH")
OUTFILE=$2

# extract metadata
datalad meta-extract -d "$DATASET_PATH" metalad_core > $OUTFILE
if [ -f "$DATASET_PATH/.studyminimeta.yaml" ]; then
    datalad meta-extract -d "$DATASET_PATH" metalad_studyminimeta >> $OUTFILE
fi
if [ -f "$DATASET_PATH/dataset_description.json" ]; then
    datalad meta-extract -d "$DATASET_PATH" bids_dataset >> $OUTFILE
fi
if [ -f "$DATASET_PATH/datacite.yml" ]; then
    datalad meta-extract -d "$DATASET_PATH" datacite_gin >> $OUTFILE
fi