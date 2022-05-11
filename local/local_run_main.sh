#!/bin/zsh

# This script does the following:


# ASSIGN VARIABLES FROM ARGUMENTS
BASEDIR=$(dirname "$0")
SUPER_PATH=$1
SUPER_NAME=$(basename "$SUPER_PATH")
OUTDIR=$2
CATALOGDIR=$3
# CREATE OUTPUTDIR IF IT DOES NOT EXIST
mkdir -p $OUTDIR

SUPER_METADATA_FILE="$OUTDIR/metadata_000_SUPER.jsonl"
SUBDATASETS_FILE="$OUTDIR/subds.txt"
datalad subdatasets -d $SUPER_PATH > $SUBDATASETS_FILE
SUBCOUNT=$(grep "subdataset(ok)" $SUBDATASETS_FILE | wc -l)

# PRINT SOME INFO
echo "Super dataset:"
echo "      $SUPER_PATH"
echo "Super dataset name:"
echo "      $SUPER_NAME"
echo "Number of subdatasets:"
echo "      $SUBCOUNT"
echo "Output directory:"
echo "      $OUTDIR"
echo "Super metadata file:"
echo "      $SUPER_METADATA_FILE"

# INSTALL REQUIREMENTS (put into script/config)
# datalad
# datalad-metalad
# datalad-catalog
# datalad-neuroimaging

# CLONE AND DUPLICATE SUPER DATASET (pass duplicate to subdataset tasks to clone from)
# datalad clone SUPER_URL super_dataset
# cd super_dataset

# CREATE CATALOG
datalad catalog create -f -c $CATALOGDIR

# SET CATALOG SUPER DATASET
wd=$(pwd)
cd $SUPER_PATH
SUPER_ID=$(git config -f .datalad/config datalad.dataset.id)
SUPER_VERSION=$(git rev-parse HEAD)
cd $wd
echo "id: $SUPER_ID"
echo "version: $SUPER_VERSION"
datalad catalog set-super -c $CATALOGDIR -i "$SUPER_ID" -v "$SUPER_VERSION"

# EXTRACT METADATA FROM SUPER
/bin/zsh $BASEDIR/local_run_dataset.sh $SUPER_PATH $SUPER_METADATA_FILE $CATALOGDIR

# RUN PER SUBDATASET TASKS
# Loop through subdatasets
# (TODO: find a smarter way, "cat .gitmodules", "git submodules foreach")
WORD1TOREMOVE="subdataset(ok): "
WORD2TOREMOVE=" (dataset)"
i=0
while read p; do
  SUBDS_PATH="${${p//$WORD1TOREMOVE/}//$WORD2TOREMOVE/}"
  SUBDS_NAME="${SUBDS_PATH##*/}"
  LINE="$SUPER_PATH/$SUBDS_PATH"
  if ! [[ $LINE == *":"* ]]; then
    i=$((i+1))
    printf -v j "%03d" $i
    echo "\n---\n$i) Extract+translate+add metadata for subdataset: $SUBDS_PATH\n---"
    if ! [[ -d "$LINE/.datalad" ]];then
      echo "No datalad dataset installed at: $LINE" && continue
    fi
    # Run per-subdataset extraction+translation pipeline
    SUBDS_FILE="$OUTDIR/metadata_${j}_SUB_$SUBDS_NAME.jsonl"
    /bin/zsh $BASEDIR/local_run_dataset.sh $LINE $SUBDS_FILE $CATALOGDIR
    # FOR DISTRIBUTED PIPELINE, PASS CATALOG AND SUBDATASET:
    # /bin/zsh $BASEDIR/local_run_dataset.sh $LINE $CATALOGDIR
  fi
done < $SUBDATASETS_FILE
