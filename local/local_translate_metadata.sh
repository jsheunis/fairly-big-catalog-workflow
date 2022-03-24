#!/bin/zsh
# PREPARATION:
# =. If it doesn't exist yet, create a mapping script that translates your metadata into the
#    format expected by datalad catalog. See e.g. _core2catalog.sh, _studyminimeta2catalog.sh (these use jq)
# =. Add another set to the conditional statement below for your new extractor+mapper, in the same format.
# STEPS:
# 1. Extract metadata for a dataset and deposit in a file (json lines or json). Compatible extractors:
#   - metalad_core (datalad metalad)
#   - metalad_studyminimeta (datalad metalad)
#   - bids_dataset (datalad neuroimaging)
#   - datacite_gin (datalad catalog)
# 2. Call this script with the filename as input. This script will:
#   - Process the file per line
#   - Identify which extractor was used, and call the relevant mapper script, which returns the mapped object
#   - Write the returned line to file OR
#   - Directly call datalad catalog per returned object(TODO)
# 3. Run datalad catalog with output file of step 2. This will create the catalog dataset entry
# Example usage:
# >>
# ASSIGN CORE VARIABLES FROM ARGUMENTS
BASEDIR=$(dirname "$0")
INPUT_META=$1
OUTPUT_FILE=$2
i=0
while IFS="" read -r p || [ -n "$p" ]
do
    # remove leading or trailing brackets or commas (in case file is a json array)
    # LINE=$(echo "$p" | sed 's/^\[//' | sed 's/,$//' | sed 's/\]$//')
    LINE=$p
    # printf '\n%s\n\n' "$LINE"
    i=$((i+1))
    echo "Translating line $i:"

    # Ignore empty LINEs
    [ -z "$LINE" ] && continue

    if [[ $LINE == *"subdataset(ok):"* ]];then
        echo "Not metadata, skipping line: $LINE" && continue
    fi

    # Test if LINE is valid metadata object (this is a bad test)
    if [[ $LINE == "{"* ]] && [[ $LINE == *"}" ]]; then
        /bin/zsh $BASEDIR/../extractor_translators/translate2catalog.sh -x $LINE >> $OUTPUT_FILE
    else
        echo "Line is not a valid metadata object: $LINE"
    fi
done < $INPUT_META