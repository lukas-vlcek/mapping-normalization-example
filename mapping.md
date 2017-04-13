# Setup Elasticsearch mapping

For brevity we are expecting every basic document model - just the
 `level` text field: 

````javascript
{ "level": "WARN" }
````

We expect this field to contain only (short) name of the log level category. We will
use the following mapping:

````javascript
"level": {
  "type": "string",
  "index": "not_analyzed"
}
````
The field is not analyzed because it is a keyword - in this case it is a **category name**.

Since this field will contain the original log level value we will introduce another
 field to contain the normalized value: `level_normalized` and we will copy the original
 value to it (we configure this directly in mapping).
 
````javascript
"level": {
  "type": "string",
  "index": "not_analyzed",
  "copy_to": "level_normalized" // << copy to field
},

"level_normalized": {
  "type": "string"
}
 ````

Now, we need to normalize the value. The core idea of data normalization is careful application
of basic building blocks of what makes every full text search shine - **text analysis**.

_To learn more about Lucene text analysis concepts you can read [sample chapter](https://manning-content.s3.amazonaws.com/download/5/fd7e90e-a06e-44ea-b697-4a3837747dcb/sample_ch05_Gheorghe_Elasticsearch_November12.pdf)
   from "Elasticsearch in Action" book (Manning 2015, ISBN 9781617291623)._
   
````javascript
"level": {
  "type": "string",
  "index": "not_analyzed",
  "copy_to": "level_normalized"
},

"level_normalized": {
  "type": "string",
  "analyzer": "level_normalization" // << setup field analyzer
}
 ````
   
And we define this analyzer `level_normalization`:
   
````javascript
"analysis": {
  "analyzer": {
    "level_normalization": {
      "type": "custom",
      "tokenizer": "keyword",
      "filter": ["uppercase", "trim"] // << build in filters
    }
  }  
}
````

At this point the `level_normalization` analyzer turns log category name to
**uppercase** and **trim** whitespaces before and after. So far so good - nothing special.
Now, we will add synonym token filter to transform log categories. For example, let's say
we want to implement transformation rule: `"ERR" -> "WARN"`.

````javascript
"analysis": {
  "analyzer": {
    "level_normalization": {
      "type": "custom",
      "tokenizer": "keyword",
      "filter": ["uppercase", "trim", "level_synonyms"] // << add synonym token filter
    }
  },
  "filter": {
    "level_synonyms": { // << configure synonym token filter
      "type": "synonym",
      "synonyms": [
        "ERR=>WARN"  // << we can add more rules if needed
      ]
    }
  }
}
````

Last but not least, we can add one more filter to catch all other or unexpected log
level categories and translate them to common `UNEXPECTED` category:
 
````javascript
"analysis": {
  "analyzer": {
    "level_normalization": {
      "type": "custom",
      "tokenizer": "keyword",
      "filter": ["uppercase", "trim", "level_synonyms", "catch_new_levels"] // << add pettern replace token filter
    }
  },
  "filter": {
    "level_synonyms": {
      "type": "synonym",
      "synonyms": [
        "ERR=>WARN"
      ]
    },
    "catch_new_levels": { // << configure pattern replace token filter
      "type": "pattern_replace",
      "pattern": "^(?!(DEBUG|INFO|WARN|ERROR|FATAL)).*$",
      "replacement": "UNEXPECTED"
    }
  }
}
````
The pattern replace token filter is configured in such way that all values
that DO NOT start with one of `DEBUG|INFO|WARN|ERROR|FATAL` is replaced with
`UNEXPECTED` token.

In fact we are specifying all acceptable log level options here as well.

We are done with mappings.

See [`level.template.json`](level.template.json) file
for complete index template file.

If you will want to run examples found in the next chapter make sure the index
template has been push to Elasticsearch:

`curl -X POST http://localhost:9200/_template/level -d@./level.template.json`

You can also use [`push_template.sh`](push_template.sh) script.

## Lock-in check:

- `synonym`, `pattern_replace` token filters are found in Lucene and exposed by tools build
  on top of it. For example [Solr expose them](https://wiki.apache.org/solr/AnalyzersTokenizersTokenFilters) too.
- `copy_to` field is not Elasticsearch specific, [Solr provides it](https://cwiki.apache.org/confluence/display/solr/Copying+Fields) too.

## Follow up

- [Index and search](search.md) sample data
