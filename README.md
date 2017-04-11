# mapping-normalization-example

This repository is to discuss and demonstrate "mapping-analysis" based approach
to normalization of document fields. Namely the log level field.

_Strictly speaking some of the low level details can have performance impact thus this it is
worth mentioning that this demonstration was designed for **Elasticsearch 2.4.x** assuming
certain conditions are met, read below for more details._

## Introduction

When collecting and indexing logs from distributed system into central search engine (like Elasticsearch)
it is very important and useful to deploy **data model**
(such as [ViaQ/elasticsearch-templates](https://github.com/ViaQ/elasticsearch-templates)).
In context of logging, one of the most important document fields is the **log level field**. 
Every log record has it. The problem is that every system that produces logs can use different
log categories.

Assuming logs are collected by light-weight log collectors that ship the logs either 
  to Elasticsearch directly ...
   
````
 +-----------------+     +-----------------+
 |  Log collector  |     |  Log collector  |
 +-----------------+     +-----------------+
          |                       |
          |                       |
          |                       |
          |  +-----------------+  |
          |  |                 |  |
          +->|  Elasticsearch  |<-+
             |                 |
             +-----------------+
````
... or they ship logs to one or more log aggregators first and then logs are sent
to Elasticsearch.
````
 +-----------------+     +-----------------+
 |  Log collector  |     |  Log collector  |
 +-----------------+     +-----------------+
          |                       |
          |                       |         
          |  +-----------------+  | 
          +->| Logs aggregator |<-+
             +-----------------+                  
                      |
                      V
             +-----------------+
             |                 |
             |  Elasticsearch  |
             |                 |
             +-----------------+
````

The question is where the log level categories are **normalized**
to common scale unified by the data model.

One option it to handle log level normalization in every **Log collector**
or in **Log aggregator**.

Other option is to handle log level normalization **in Elasticsearch during indexing**.
The following text focuses only on the later option. In the end we discuss and compare
some of the pros and cons of both options.
