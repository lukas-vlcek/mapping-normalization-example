#!/usr/bin/env bash

# Use -v argument for verbose output
if [[ $1 == "-v" ]]; then
  set -x
fi

# Set ${ES_URL} nev variable to override the defaults
ES_URL=${ES_URL:-http://localhost:9200}
