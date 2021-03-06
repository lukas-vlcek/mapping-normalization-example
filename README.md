# mapping-normalization-example

This repository is to discuss and demonstrate Elasticsearch mapping and analysis based approach
to normalization of document fields. Namely the log level field.

## Introduction

When collecting and indexing logs from distributed system into central search engine (like Elasticsearch)
it is very important and useful to deploy **data model**
(such as [ViaQ/elasticsearch-templates](https://github.com/ViaQ/elasticsearch-templates)).
In context of logging, one of the most important document fields is the **log level field**. 
Every log record has it. The challenge is that every system that produces logs can use different
log categories.

Assuming logs are collected by light-weight **log collectors** that ship the logs either 
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
... or they ship logs to one or more **log aggregators** first and then logs are sent
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

**The question is:**
 Where the log level categories should be **normalized**
to common scale unified by the data model? Basically, there are two options:

1. One option it to handle log level normalization in every **Log collector**
or in **Log aggregator**.

2. Other option is to handle log level normalization **in Elasticsearch during indexing**.

The following text investigates the later option only.

## Motivation

The main motivation to investigate the later option: 

- implement data normalizations as part of the data model
- easy identification of missing rules or unexpected data transformation results 
- if data model is changed and/or if the data transformations need to be updated it should
  be easier to deploy new code and re-calculate historical data already stored in central
  place

## Goals

- provide implementation guidelines and examples
- investigate pros and cons wrt:
  - side-effects
  - performance impact
  - vendor lock-in
  
## Content

- [Setup Elasticsearch mapping](mapping.md)
- [Index and search](search.md) sample data
- [Get documents](documents.md) including normalized values
