#!/bin/zsh
# This script ...
# Example usage:
# >>
# ASSIGN CORE VARIABLES FROM ARGUMENTS
BASEDIR=$(dirname "$0")
METADATA=$1
EXTRACTED=$2
GRAPH=$3

# EXTRACT PROPERTIES USING JQ
# dataset_id
dataset_id=$(jq '.dataset_id' <<< $METADATA)
# dataset_version
dataset_version=$(jq '.dataset_version' <<< $METADATA)
# extractors_used
extractors_used=$(jq '[{"extractor_name": .extractor_name, "extractor_version": .extractor_version, "extraction_parameter": .extraction_parameter, "extraction_time": .extraction_time, "agent_name": .agent_name, "agent_email": .agent_email,}]' <<< $METADATA)
# type
type=$(jq .type <<< $METADATA)
# strip quotes from type
ttype=$(echo "$type" | xargs)
# echo "$ttype"
# The rest depends on the type of core extractor: dataset or file
if [[ ${ttype} == "dataset" ]]; then
    # dataset
    # name
    name=""
    # short_name
    short_name=""
    # description
    description=""
    # doi
    doi=""
    # url
    url=$(jq '.[]? | select(.["@type"] == "Dataset") | [.distribution[]? | select(has("url")) | .url]' <<< $GRAPH)
    # license
    license="{}"
    # authors
    authors=$(jq '[.[]? | select(.["@type"]=="agent")] | map(del(.["@id"], .["@type"]))' <<< $GRAPH)
    if [ -z "$authors" ]; then
        authors="[]"
    fi
    # keywords
    keywords="[]"
    # funding
    funding="[]"
    # publications
    publications="[]"
    # subdatasets
    subdatasets=$(jq '.[]? | select(.["@type"] == "Dataset") | [.hasPart[]? | {"dataset_id": (.identifier | sub("^datalad:"; "")), "dataset_version": (.["@id"] | sub("^datalad:"; "")), "dataset_path": .name, "dirs_from_path": []}]' <<< $GRAPH)
    if [ -z "$subdatasets" ]; then
        subdatasets="[]"
    fi
    # children
    children="[]"
    # ADD EXTRACTED PROPERTIES TO A SINGLE OUTPUT OBJECT, WRITE TO FILE
    output_meta=$(jq -c -n --argjson 'type' "$type" \
    --argjson dataset_id $dataset_id \
    --argjson dataset_version "$dataset_version" \
    --arg name "$name" \
    --arg short_name "$short_name" \
    --arg description "$description" \
    --arg doi "$doi" \
    --argjson url "$url" \
    --argjson license "$license" \
    --argjson authors "$authors" \
    --argjson keywords "$keywords" \
    --argjson funding "$funding" \
    --argjson publications $publications \
    --argjson subdatasets $subdatasets \
    --argjson children $children \
    --argjson extractors_used $extractors_used \
    '$ARGS.named'
    )
else
    # file
    # path
    ppath=$(jq '.path' <<< $METADATA)
    # contentbytesize
    contentbytesize=$(jq '.extracted_metadata["contentbytesize"]'<<< $METADATA)
    # url
    url=$(jq '.extracted_metadata.distribution.url'<<< $METADATA)
    if [ -z "$url" ]; then
        url="[]"
    fi
    # ADD EXTRACTED PROPERTIES TO A SINGLE OUTPUT OBJECT, WRITE TO FILE
    output_meta=$(jq -c -n --argjson 'type' "$type" \
    --argjson dataset_id $dataset_id \
    --argjson dataset_version "$dataset_version" \
    --argjson path "$ppath" \
    --argjson url "$url" \
    --argjson extractors_used $extractors_used \
    '$ARGS.named'
    )
fi
echo $output_meta