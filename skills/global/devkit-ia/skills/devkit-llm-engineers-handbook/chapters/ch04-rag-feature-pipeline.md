# Chapter 4: RAG Feature Pipeline

## Core Idea
RAG quality depends on feature pipeline rigor: cleaning, chunking, embedding, indexing, and synchronization must be engineered as a versioned system.

## Frameworks Introduced
- **Vanilla RAG Triad (Ingestion, Retrieval, Generation)**
  - When to use: Baseline retrieval-augmented systems.
  - How: Build each stage independently with measurable interfaces.
- **Advanced RAG Taxonomy (Pre, Retrieval, Post)**
  - When to use: Need quality gains beyond baseline retrieval.
  - How: Add targeted optimizations at each stage.
- **Dual-store Snapshot Strategy**
  - When to use: Maintaining consistency between warehouse and feature store.
  - How: Store synchronized snapshots and use change data capture.

## Key Concepts
- **Embeddings**: Dense vectors encoding semantic meaning.
- **Vector index**: Data structure for nearest-neighbor retrieval.
- **Chunking**: Splitting docs into retrieval units.
- **CDC**: Change data capture for incremental updates.
- **Feature store**: Curated artifacts for inference reuse.
- **OVM**: Operational mapping layer used in the implementation.

## Mental Models
Use **retrieval as data product**: every embedding/index update should be auditable. Optimize **stage by stage** rather than random prompt tweaks.

## Anti-patterns
- **Static index forever**: Retrieval drift appears as source data changes.
- **Aggressive chunking without evaluation**: Loses context or harms recall.

## Worked Example
A nightly batch feature run:
1. Pulls changed records from warehouse.
2. Cleans and canonicalizes text.
3. Chunks by semantic boundaries and max token policy.
4. Computes embeddings and upserts Qdrant vectors.
5. Persists snapshot metadata for rollback and traceability.

## Key Takeaways
1. RAG quality is mostly a data/feature engineering problem.
2. Incremental sync patterns are critical for freshness.
3. Advanced RAG should be introduced where metrics show bottlenecks.

## Connects To
- **Ch 7**: RAG-specific evaluation metrics validate feature decisions.
- **Ch 9**: Inference pipeline consumes these indexed features.
