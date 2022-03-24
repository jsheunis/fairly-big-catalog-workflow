#!/bin/zsh
# This script ...
# Example usage:
# >>
# ASSIGN CORE VARIABLES FROM ARGUMENTS
BASEDIR=$(dirname "$0")
INPUT_META=$1

# PARSE FLAG ARGUMENTS
varx=''
filename=''
verbose='false'
print_usage() {
  printf "Usage: /script.sh [-x <variable> / -f <filename> / -v <verbose>]"
}
while getopts 'x:f:v' flag; do
  case "${flag}" in
    x) varx="${OPTARG}" ;;
    f) filename="${OPTARG}" ;;
    v) verbose='true' ;;
    *) print_usage
       exit 1 ;;
  esac
done
if [ -z "$filename" ] && [ -z "$varx" ]; then
    echo "No argument passed with -x or -f flag; pass either a variable or a filename."
    exit 1
fi
# EXTRACT TOP-LEVEL VARIABLES USING JQ

if [ -z "$filename" ]; then
    # IF THE INPUT IS A VARIABLE
    if [ -z "$varx" ]; then
        echo "No variable provided with -x flag"
        exit 1
    fi
    METADATA=$(jq '.' <<< $varx)
    EXTRACTED=$(jq '.extracted_metadata?' <<< $varx)
    GRAPH=$(jq '.extracted_metadata["@graph"]?' <<< $varx)
else
    # IF THE INPUT IS A FILE
    if [ ! -f $filename ]; then
        # If file doesn't exist
        echo "No file found at: $filename"
        exit 2
    else
        # If input is a file
        METADATA=$(cat "$filename" | jq .)
        EXTRACTED=$(cat "$filename" | jq '.extracted_metadata?')
        GRAPH=$(cat "$filename" | jq '.extracted_metadata["@graph"]?')
    fi
fi

# extractor_name
extractor_name=$(jq '.extractor_name' <<< $METADATA )

if [[ ${extractor_name} == *"metalad_core"* ]];then
    /bin/zsh $BASEDIR/_core2catalog.sh $METADATA $EXTRACTED $GRAPH
elif [[ ${extractor_name} == *"bids_dataset"* ]];then
    /bin/zsh $BASEDIR/_bidsdataset2catalog.sh $METADATA $EXTRACTED $GRAPH
elif [[ ${extractor_name} == *"studyminimeta"* ]];then
    /bin/zsh $BASEDIR/_studyminimeta2catalog.sh $METADATA $EXTRACTED $GRAPH
elif [[ ${extractor_name} == *"datacite_gin"* ]];then
    /bin/zsh $BASEDIR/_datacitegin2catalog.sh $METADATA $EXTRACTED $GRAPH
else
# 
fi