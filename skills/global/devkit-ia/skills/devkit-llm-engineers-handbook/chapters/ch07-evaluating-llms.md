# Chapter 7: Evaluating LLMs

## Core Idea
LLM evaluation requires multi-layer measurement: general capability, domain fit, task success, and RAG grounding quality.

## Frameworks Introduced
- **Three-layer LLM Evaluation (General, Domain, Task)**
  - When to use: Any production model selection decision.
  - How: Combine benchmarks with domain and application-specific datasets.
- **RAG Evaluation Stack**
  - When to use: Retrieval quality affects final answer usefulness.
  - How: Evaluate retrieval relevance, answer faithfulness, and response quality.
- **Evaluation-Then-Analysis Loop**
  - When to use: Choosing among model/pipeline variants.
  - How: Generate outputs, score systematically, analyze failure clusters.

## Key Concepts
- **General-purpose evaluation**: Broad capability benchmarks.
- **Domain-specific evaluation**: Coverage of business context.
- **Task-specific evaluation**: Product KPI-aligned test set.
- **Ragas / ARES**: Frameworks for RAG-oriented assessment.
- **Faithfulness**: Degree of grounding in retrieved evidence.

## Mental Models
Use **decision-oriented evaluation**: every metric must support an explicit product decision. Think in **error buckets**, not single aggregate scores.

## Anti-patterns
- **Benchmark-only selection**: Misses domain and workflow failures.
- **No retrieval diagnostics**: Hides root cause of poor RAG answers.

## Worked Example
Comparing two model variants for an LLM Twin:
1. Run both on a fixed domain test set.
2. Score answer quality and retrieval faithfulness.
3. Segment failures by type: missing context, hallucination, style mismatch.
4. Route fixes: feature pipeline updates for context failures, alignment for style issues.

## Key Takeaways
1. Evaluation must mirror production use cases.
2. RAG systems require dedicated retrieval and grounding metrics.
3. Failure analysis drives more improvement than raw score chasing.

## Connects To
- **Ch 4**: Feature pipeline quality impacts retrieval metrics.
- **Ch 9**: Inference strategy changes should be re-evaluated systematically.
