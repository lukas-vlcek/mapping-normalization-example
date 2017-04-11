# Index and search sample data

Let's see what [level.template.json](level.template.json) can do in action.

We will index the following 5 documents:

````shell
curl -X POST ${ES_URL}/level/demo -d '{ "level": "WARN" }'
curl -X POST ${ES_URL}/level/demo -d '{ "level": "warn" }'
curl -X POST ${ES_URL}/level/demo -d '{ "level": "ERR" }'
curl -X POST ${ES_URL}/level/demo -d '{ "level": "err" }'
curl -X POST ${ES_URL}/level/demo -d '{ "level": "Foo" }'
````

In the first query we will list log category levels of both fields:

````shell
curl -X GET "${ES_URL}/level/_search?pretty" -d '{
  "size": 0,
  "aggs": {
    "levels": {
      "terms": { "field": "level" } 
    },
    "levels_normalized": {
      "terms": { "field": "level_normalized" }
    }
  }
}'
````

The [terms aggregation](https://www.elastic.co/guide/en/elasticsearch/reference/2.4/search-aggregations-bucket-terms-aggregation.html)
gives us number of documents per unique field category (it is equivalent to SQL `GROUP BY` function).
Notice run two aggregations, first against the original `level` field and second against `level_normalized` field.

We get the following outputs (truncated):

For the original `level` field we get (as expected) five distinct categories, each containing one document.

````javascript
"aggregations" : {
  "levels" : {
    ...  
    "buckets" : [ {
      "key" : "ERR",   // << category name
      "doc_count" : 1  // << document count
    }, {
      "key" : "Foo",
      "doc_count" : 1
    }, {
      "key" : "WARN",
      "doc_count" : 1
    }, {
      "key" : "err",
      "doc_count" : 1
    }, {
      "key" : "warn",
      "doc_count" : 1
    } ]
  }
}
````
However, when similar aggregation is run against normalized field `level_normalized` we
 get different results:

````javascript
"aggregations" : {
  "levels_normalized" : {
    ...
    "buckets" : [ {
      "key" : "WARN",
      "doc_count" : 4
    }, {
      "key" : "UNEXPECTED",
      "doc_count" : 1
    } ]
  }
}
````
This means that if dashboards (like Kibana or Graphana) are run against the normalized
field we will get expected results. We can see that four document were assigned the `WARN`
category and one document was assigned `UNEXPECTED` category:

| Original level | Normalized level |
|----------------|------------------|
| WARN | WARN |
| warn | WARN |
| ERR | WARN |
| err | WARN |
| Foo | UNEXPECTED |
