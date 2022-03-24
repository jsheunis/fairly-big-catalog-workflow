#!/bin/zsh

# Per-dataset job (args: subdataset, catalog):
# - clone subdataset
# - extract dataset/file metadata
# - translate metadata to catalog schema
# - clone catalog, check out subdataset-specific branch
# - add metadata to catalog
# - commit to subdataset-specific branch
# - push to origin

# ASSIGN VARIABLES FROM ARGUMENTS
BASEDIR=$(dirname "$0")
DATASET_PATH=$1
DATASET_NAME=$(basename "$DATASET_PATH")
OUTFILE=$2
CATALOG_DIR=$3
# CLONE_URL
# PUSH_URL

# CLONE SUBDATASET


# EXTRACT DATASET METADATA
/bin/zsh $BASEDIR/local_extract_datasetlevel.sh $DATASET_PATH $OUTFILE

# EXTRACT FILE METADATA OF CURRENT DATASET
# /bin/zsh $BASEDIR/local_extract_filelevel.sh $DATASET_PATH $OUTFILE

# TRANSLATE METADATA TO CATALOG SCHEMA
OUTFILE_BASEDIR=$(dirname "$OUTFILE")
OUTFILE_NAME=$(basename -- "$OUTFILE")
FEXT="${OUTFILE_NAME##*.}"
FNAME="${OUTFILE_NAME%.*}"
TRANSLATED_OUTFILE="$OUTFILE_BASEDIR/${FNAME}_translated.$FEXT"
/bin/zsh $BASEDIR/local_translate_metadata.sh $OUTFILE $TRANSLATED_OUTFILE

# CLONE CATALOG FROM CATALOG_CLONE_DIR
# + ADD REMOTE UPSTREAM PUSH_URL

# CHECKOUT SUBDATASET-SPECIFIC BRANCH

# ADD METADATA TO CATALOG
datalad catalog add -c $CATALOG_DIR -m $TRANSLATED_OUTFILE

# ADD, COMMIT, PUSH BRANCH TO PUSH_URL