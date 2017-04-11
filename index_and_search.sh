#!/usr/bin/env bash

source _configure_env.sh

# Delete index and push index template again
./push_template.sh -d

# Index data
curl -X POST ${ES_URL}/level/demo -d '{ "level": "WARN" }'
curl -X POST ${ES_URL}/level/demo -d '{ "level": "warn" }'
curl -X POST ${ES_URL}/level/demo -d '{ "level": "ERR" }'
curl -X POST ${ES_URL}/level/demo -d '{ "level": "err" }'
curl -X POST ${ES_URL}/level/demo -d '{ "level": "Foo" }'

# Refresh - make data searchable
curl -X POST ${ES_URL}/_refresh
echo; echo

echo "Group by categories"
echo --------------------------------------------
curl -X GET "${ES_URL}/level/_search?pretty" -d@categories.json

echo "Check if we have broken rules"
echo --------------------------------------------
curl -X GET "${ES_URL}/level/_search?pretty" -d@check.json

echo "Get raw documents with normalized field"
echo --------------------------------------------
curl -X GET "${ES_URL}/level/_search?pretty" -d@documents.json
