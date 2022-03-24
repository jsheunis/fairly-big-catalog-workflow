#!/bin/zsh

# ASSIGN CORE VARIABLES FROM ARGUMENTS
BASEDIR=$(dirname "$0")

# requirements
# - python
# - datalad latest
# - datalad-metalad (git master)
# - datalad-catalog (git master)
# - datalad-neuroimaging (bids_dataset feature branch, or master if merged)
# - jq

