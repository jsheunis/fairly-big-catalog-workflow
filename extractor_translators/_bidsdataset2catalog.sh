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
# type
type=$(jq '.type' <<< $METADATA )
# dataset_id
dataset_id=$(jq '.dataset_id' <<< $METADATA )
# dataset_version
dataset_version=$(jq '.dataset_version' <<< $METADATA )
# name
name=$(jq '.Name' <<< $EXTRACTED)
# short_name
short_name=""
# description(.tags | join(","))
# description=$(jq -c '.description' <<< $EXTRACTED)
description=$(jq -c '.description | join("\n\n")' <<< $EXTRACTED | jq -R . )
# doi
doi=""
# url
url=""
# license
license=$(jq '{ "name": .License, "url": ""}' <<< $EXTRACTED)
# authors
authors=$(jq '[.Authors[]? as $auth | {"name": $auth, "givenName":"", "familyName":"", "email":"", "honorificSuffix":"", "identifiers":[]}]' <<< $EXTRACTED)
# keywords
keywords=$(jq '. as $parent | .entities.task + .variables.dataset'<<< $EXTRACTED)
# funding
funding=$(jq '[.Funding[]? as $fund | {"name": "", "grant":"", "description":$fund}]' <<< $EXTRACTED)
# publications
publications="[]"
# subdatasets
subdatasets="[]"
# children
children="[]"
# extractors_used
extractors_used=$(jq '[{"extractor_name": .extractor_name, "extractor_version": .extractor_version, "extraction_parameter": .extraction_parameter, "extraction_time": .extraction_time, "agent_name": .agent_name, "agent_email": .agent_email}]'<<< $METADATA )
# additional_display
additional_display=$(jq '[{"name": "BIDS", "content": .entities}]' <<< $EXTRACTED)
# top_content
top_display=$(jq '[{"name": "Subjects", "value": (.entities.subject | length)}, {"name": "Sessions", "value": (.entities.session | length)}, {"name": "Tasks", "value": (.entities.task | length)}, {"name": "Runs", "value": (.entities.run | length)}]' <<< $EXTRACTED)

# ADD EXTRACTED PROPERTIES TO A SINGLE OUTPUT OBJECT, WRITE TO OUTPUT
final=$(jq -c -n --argjson type "$type" \
--argjson dataset_id "$dataset_id" \
--argjson dataset_version "$dataset_version" \
--argjson name "$name" \
--arg short_name "$short_name" \
--argjson description "$description" \
--arg doi "$doi" \
--arg url "$url" \
--argjson license "$license" \
--argjson authors "$authors" \
--argjson keywords "$keywords" \
--argjson funding "$funding" \
--argjson publications $publications \
--argjson subdatasets $subdatasets \
--argjson children $children \
--argjson extractors_used $extractors_used \
--argjson additional_display $additional_display \
--argjson top_display $top_display \
'$ARGS.named'
)
echo $final