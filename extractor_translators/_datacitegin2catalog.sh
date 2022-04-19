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
type=$(jq '.type' <<< $METADATA)
# dataset_id
dataset_id=$(jq '.dataset_id' <<< $METADATA)
# dataset_version
dataset_version=$(jq '.dataset_version' <<< $METADATA)
# name
name=$(jq '.title' <<< $EXTRACTED)
# short_name
short_name=""
# description
description=$(jq -c '.description' <<< $EXTRACTED | sed 's/\\"//g' | sed 's:\\\([^n]\):\1:g' )
# doi
doi=""
# url
url="[]"
# license
license=$(jq '.license | { "name": .name, "url": .url}' <<< $EXTRACTED)
# authors
authors=$(jq '[.authors[]? | {"name":"", "givenName":.firstname, "familyName":.lastname, "email":"", "honorificSuffix":"", "identifiers":[.id]} ]' <<< $EXTRACTED)
# keywords
keywords=$(jq '.keywords' <<< $EXTRACTED)
# funding
funding=$(jq '[.funding[]? as $element | {"name": $element, "identifier": "", "description": ""}]' <<< $EXTRACTED)
# publications
publications=$(jq '[.references[]? as $pubin | {"type":"", "title":$pubin["citation"], "doi":($pubin["id"] | sub("^doi:"; "https://www.doi.org/")), "datePublished":"", "publicationOutlet":"", "authors": []}]'<<< $EXTRACTED)
# subdatasets
subdatasets="[]"
# children
children="[]"
# extractors_used
extractors_used=$(jq '[{"extractor_name": .extractor_name, "extractor_version": .extractor_version, "extraction_parameter": .extraction_parameter, "extraction_time": .extraction_time, "agent_name": .agent_name, "agent_email": .agent_email,}]'<<< $METADATA)

# ADD EXTRACTED PROPERTIES TO A SINGLE OUTPUT OBJECT, WRITE TO FILE
final=$(jq -c -n --argjson type "$type" \
--argjson dataset_id $dataset_id \
--argjson dataset_version "$dataset_version" \
--argjson name "$name" \
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
echo $final