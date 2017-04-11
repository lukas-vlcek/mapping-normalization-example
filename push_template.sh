#!/usr/bin/env bash

source _configure_env.sh

if [[ $1 == "-d" ]]; then
  curl -X DELETE ${ES_URL}/level
fi

curl -X POST ${ES_URL}/_template/level    -d@./level.template.json
