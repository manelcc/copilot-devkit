# Chapter 3: Data Engineering

## Core Idea
Data engineering is the foundation of LLM quality: source selection, crawling, normalization, and storage schemas define what the model can learn and retrieve.

## Frameworks Introduced
- **Crawler Dispatcher Pattern**
  - When to use: Multiple heterogeneous sources.
  - How: Route each source type to specialized crawler implementations.
- **Pipeline Step Decomposition**
  - When to use: Need testability and incremental reruns.
  - How: Split extraction, normalization, validation, and persistence into steps.
- **Document Warehouse Modeling (ODM)**
  - When to use: Semi-structured content with evolving fields.
  - How: Version schemas and map categories into explicit document classes.

## Key Concepts
- **Dispatcher**: Resolves source-to-crawler mapping.
- **Crawler**: Source-specific data extractor.
- **ODM**: Object-document mapping abstraction.
- **Raw data warehouse**: Canonical storage before featureization.
- **Data categories**: Content taxonomy used downstream.
- **Troubleshooting loop**: Operational handling of crawler failures.

## Mental Models
Use **schema-light, contract-strong** design: flexible storage with strict interface contracts. Think of ingestion as a **reliability system**, not just ETL scripts.

## Anti-patterns
- **One crawler to rule them all**: Becomes fragile as source heterogeneity grows.
- **No dedup/version logic**: Leads to stale or duplicated training/retrieval corpora.

## Worked Example
For GitHub, Medium, and custom articles:
1. Dispatcher inspects source metadata.
2. Source-specific crawler extracts raw text and metadata.
3. ODM validates required fields (url, author, timestamp, body).
4. Pipeline writes normalized docs to warehouse with source tags.
5. Failed fetches are retried and logged with root-cause labels.

## Key Takeaways
1. Good retrieval starts with disciplined ingestion.
2. Source-specific extraction improves downstream quality.
3. Operational resilience in crawling is mandatory for scale.

## Connects To
- **Ch 4**: Clean warehouse records feed feature generation.
- **Ch 11**: Data pipelines become CI/CD-managed assets.
