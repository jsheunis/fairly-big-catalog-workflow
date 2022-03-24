#!/bin/zsh

# ASSIGN CORE VARIABLES FROM ARGUMENTS
BASEDIR=$(dirname "$0")
SUPER_PATH=$1
CATALOG_PATH=$2



while IFS="" read -r p || [ -n "$p" ]
do
    # remove leading or trailing brackets or commas (in case file is a json array)
    LINE=$(echo "$p" | sed 's/^\[//' | sed 's/,$//' | sed 's/\]$//')
    # printf '\n%s\n\n' "$LINE"

    # Ignore empty LINEs
    [ -z "$LINE" ] && continue
    # Test if LINE is valid JSON
    if jq -e . >/dev/null 2>&1 <<< $LINE; then
        if [[ ${LINE} == *"metalad_core"* ]];then
            retn_value=$(/bin/zsh /Users/jsheunis/Documents/psyinf/datalad-catalog/datalad_catalog/scripts/_core2catalog.sh $LINE)
        elif [[ ${LINE} == *"bids_dataset"* ]];then
            retn_value=$(/bin/zsh /Users/jsheunis/Documents/psyinf/datalad-catalog/datalad_catalog/scripts/_bidsdataset2catalog.sh $LINE)
        elif [[ ${LINE} == *"studyminimeta"* ]];then
            retn_value=$(/bin/zsh /Users/jsheunis/Documents/psyinf/datalad-catalog/datalad_catalog/scripts/_studyminimeta2catalog.sh $LINE)
        elif [[ ${LINE} == *"datacite_gin"* ]];then
            retn_value=$(/bin/zsh /Users/jsheunis/Documents/psyinf/datalad-catalog/datalad_catalog/scripts/_datacitegin2catalog.sh $LINE)
        else
        # 
        fi
    else
        echo "Failed to parse JSON, or got false/null"
    fi
    echo "$retn_value" >> $OUTPUT_FILE
done < $INPUT_META

# THE PLAN FOR A DISTRIBUTED CATALOG GENERATION WORKFLOW:

# Main job:
# - clone superdataset
# - extract dataset+file metadata (perhaps better as part of loop below?)
# - create catalog (adding whatever metadata extracted)
# - catalog set super
# - save catalog as datalad dataset (which config? text2git?)
# - start per-subdataset jobs in parallel
# Per-dataset job (args: subdataset, catalog):
# - clone subdataset
# - extract dataset/file metadata
# - translate metadata to catalog schema
# - clone catalog, check out subdataset-specific branch
# - add metadata to catalog
# - commit to subdataset-specific branch
# - push to origin
# Main job (continue once subdataset jobs completed):
# - merge all branches into master (no conflicts since subdataset jobs only added new content to seperate locations)
# - push catalog to server

# see also: https://github.com/datalad/datalad-catalog/issues/36