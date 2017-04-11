## Getting documents including normalized values

Use the following query to get the data:

````json
{
  "_source": true,
  "fielddata_fields" : [
    "level_normalized",
    "level"
  ],
  "script_fields": {
    "level_script": {
      "script": {
        "inline": "doc['level']"
      }
    },
    "level_normalized_script": {
      "script": {
        "inline": "doc['level_normalized']"
      }
    }
  },
  "query": {
    "bool": {
      "filter": {
        "script": {
          "script": "doc['level'].value != doc['level_normalized'].value"
        }
      }
    }
  }
}

````
To run the query use:

````shell
curl -X GET "${ES_URL}/level/_search?pretty" -d@documents.json
````
