# Chapter 9: RAG Inference Pipeline

## Core Idea
Advanced RAG inference combines query transformation, selective retrieval, and reranking to improve answer relevance and grounding at runtime.

## Frameworks Introduced
- **Advanced RAG Runtime Stack (Pre, Retrieval, Post)**
  - When to use: Baseline retrieval misses intent or returns noisy context.
  - How: Add query expansion/self-querying, filtered search, and reranking.
- **Modular Retrieval Architecture**
  - When to use: Need experimentation without rewriting full pipeline.
  - How: Encapsulate retriever, filter, reranker, and generator modules.
- **Context Quality Control Loop**
  - When to use: Hallucination or irrelevant answer patterns appear.
  - How: Track retrieval precision and grounding outcomes, then tune stages.

## Key Concepts
- **Query expansion**: Enrich user query terms for better recall.
- **Self-querying**: Model-generated structured retrieval constraints.
- **Filtered vector search**: Semantic + metadata retrieval.
- **Reranking**: Reordering candidates by relevance.
- **Pipeline composition**: Integrating modules into final answer path.

## Mental Models
Think of RAG inference as **search engine + reasoning system**. Optimize **context quality before generation prompt complexity**.

## Anti-patterns
- **Top-k retrieval without filters**: High recall, low precision.
- **No reranking in noisy corpora**: Retrieval quality plateaus quickly.

## Worked Example
For a technical Q&A assistant:
1. Expand query with domain synonyms.
2. Generate metadata filters (topic, date, source).
3. Retrieve semantic candidates from vector store.
4. Rerank by relevance and recency.
5. Generate answer citing top grounded chunks.

## Key Takeaways
1. Runtime retrieval strategy strongly shapes answer quality.
2. Metadata-aware retrieval improves precision.
3. Reranking is a practical lever for grounded outputs.

## Connects To
- **Ch 4**: Feature quality controls retrieval ceiling.
- **Ch 10**: Deployment design affects runtime orchestration choices.
