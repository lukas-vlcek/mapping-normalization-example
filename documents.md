## Getting documents including normalized values

Besides querying the data for the needs to dashboards (which are mostly driven by aggregations)
it is often required to get the full content of original documents (for example to populate data
table in the UI). 

When getting the data from Elasticsearch what you get back is the original `_source` document.
This means the document that has been sent to Elasticsearch for indexing.

The issue at this point is that the original `_source` document does not contain the `level_normalized`
field. However, this field is part of Elasticsearch store now and there are ways how to retrieve it.

Check the following query (see below for more details):

````javascript
// content of documents.json file
{
  "fielddata_fields" : [
    "level_normalized",
    "level"
  ],
  "_source": true,
  "script_fields": { // << alternative approach
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

### Performance implications

Accessing [fielddata](https://www.elastic.co/guide/en/elasticsearch/reference/2.4/fielddata.html) is
notoriously known to be expensive in terms of increased JVM Heap usage. It can be source of scaling issues.
However, it is important to understand that in this case there are expected only few distinct
log level categories and we do not expect `level_normalized` field to be high cardinality field.

**TODO:** The real impact of accessing fielddata in case of `level_normalized` field should be properly measured.

### Optional way how to access and work with fielddata

There are also other alternatives how to get analyzed tokens using [`script_fields`](https://www.elastic.co/guide/en/elasticsearch/reference/2.4/search-request-script-fields.html)
but that is more expensive and requires enabled scripting.  

That's it. We are in the end.

To run the [`documents.json`](documents.json) query use:

````shell
curl -X GET "${ES_URL}/level/_search?pretty" -d@documents.json
````
