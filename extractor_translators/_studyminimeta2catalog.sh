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
type="dataset"
# dataset_id
dataset_id=$(jq '.dataset_id' <<< $METADATA)
# dataset_version
dataset_version=$(jq '.dataset_version' <<< $METADATA)
# name
name=$(jq '.[] | select(.["@type"] == "Dataset") | .name' <<< $GRAPH)
# short_name
short_name=""
# description
description=$(jq '.[] | select(.["@type"] == "Dataset") | .description' <<< $GRAPH)
# doi
doi=""
# url
url=$(jq '.[] | select(.["@type"] == "Dataset") | .url' <<< $GRAPH)
# license
license="{}"
# authors
combinedpersonsids=$(jq '{"authordetails": .[] | select(.["@id"] == "#personList") | .["@list"], "authorids": .[] | select(.["@type"] == "Dataset") | .author}' <<< $GRAPH)
authors=$(echo "$combinedpersonsids" | jq '. as $parent | [.authorids[]["@id"] as $idin | ($parent.authordetails[] | select(.["@id"] == $idin))]' )
# keywords
keywords=$(jq '.[] | select(.["@type"] == "Dataset") | .keywords' <<< $GRAPH)
# funding
funding=$(jq '.[] | select(.["@type"] == "Dataset") | [.funder[] | {"name": .name, "identifier": "", "description": ""}]' <<< $GRAPH)
# publications
combinedpersonspubs=$(jq '{"authordetails": .[] | select(.["@id"] == "#personList") | .["@list"], "publications": .[] | select(.["@id"] == "#publicationList") | .["@list"]}' <<< $GRAPH)
publications=$(echo "$combinedpersonspubs" | jq '. as $parent | [.publications[] as $pubin | {"type":$pubin["@type"], "title":$pubin["headline"], "doi":$pubin["sameAs"], "datePublished":$pubin["datePublished"], "publicationOutlet":$pubin["publication"]["name"], "authors": ([$pubin.author[]["@id"] as $idin | ($parent.authordetails[] | select(.["@id"] == $idin))])}]')
# subdatasets
subdatasets="[]"
# children
children="[]"
# extractors_used
extractors_used=$(jq '[{"extractor_name": .extractor_name, "extractor_version": .extractor_version, "extraction_parameter": .extraction_parameter, "extraction_time": .extraction_time, "agent_name": .agent_name, "agent_email": .agent_email,}]'<<< $METADATA)

# ADD EXTRACTED PROPERTIES TO A SINGLE OUTPUT OBJECT, WRITE TO FILE
final=$(jq -c -n --arg 'type' "$type" \
--argjson dataset_id $dataset_id \
--argjson dataset_version "$dataset_version" \
--argjson name "$name" \
--arg short_name "$short_name" \
--argjson description "$description" \
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