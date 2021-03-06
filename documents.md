## Getting documents including normalized values

Besides querying the data for the needs of dashboards (which are mostly driven by aggregations)
it is often required to get the full content of original documents (for example to populate data
table in the UI or to export the data to different data store). 

When getting the data from Elasticsearch what you get back is by default the original `_source` document.
This means the document that has been sent to Elasticsearch for indexing.

The issue at this point is that the original `_source` document **does not contain** the `level_normalized`
field. However, this field is part of Elasticsearch store now and there are ways how to retrieve it.

Check the following query:

````javascript
// content of documents.json file
{
  "fielddata_fields" : [
    "level_normalized", // << get data for normalized field
    "level"
  ],
  "_source": true, // << also get the original document
  "script_fields": { // << alternative approach to get normalized data
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
  }
}
````
To get normalized value of the field you can use
[`fielddata_fields`](https://www.elastic.co/guide/en/elasticsearch/reference/2.4/search-request-fielddata-fields.html)
query option to retrieve the tokens that are result of analysis process from Lucene index
(_read more about [fielddata](https://www.elastic.co/guide/en/elasticsearch/reference/2.4/fielddata.html)_).

Then if you want to get the rest of the document fields you can ask for source by
using `"_source": true` (if you ask for `fielddata_fields` then the _source is not provided by default).

To run the [`documents.json`](documents.json) query use:

````shell
curl -X GET "${ES_URL}/level/_search?pretty" -d@documents.json
````
This will give us individual documents with normalized fields:

````javascript
"hits" : [
    {
        ...
        "_source" : {
            "level" : "err" // << original document value
        },
        "fields" : {
            "level_normalized" : [ "WARN" ], // << normalized value from fielddata
            "level_normalized_script" : [ "WARN" ], // the same but retrieved using script
            "level_script" : [ "err" ],
            "level" : [ "err" ]
        }
    }
    ...
]
````

### Performance implications

Accessing [fielddata](https://www.elastic.co/guide/en/elasticsearch/reference/2.4/fielddata.html) is
notoriously known to be expensive in terms of increased JVM Heap usage (leading to expensive GC). It can be source of scaling issues.
However, it is important to understand that in this case there are expected only few distinct
log level categories (20-30?) and we do not expect `level_normalized` field to be high cardinality field.

**TODO:** The real impact of accessing fielddata in case of `level_normalized` field should be tested.

Notice: Starting with ES 5.x `fielddata_fields` has been replaced with
[`docvalue_fields`](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-docvalue-fields.html)
to avoid JVM Heap issues but in case of **analyzed string fields**
it is [falling back to fielddata](https://www.elastic.co/guide/en/elasticsearch/reference/current/doc-values.html).


### Alternative way how to access fielddata

As seen in the query there are also other alternatives how to get analyzed tokens using [`script_fields`](https://www.elastic.co/guide/en/elasticsearch/reference/2.4/search-request-script-fields.html)
but that is more expensive and requires enabled scripting.  

That's it. We are in the end.
