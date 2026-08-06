# Patterns

## FTI Pipeline Decomposition
**When to use**: Building maintainable LLM systems with distinct batch and online workflows.
**How**: Separate Feature, Training, and Inference pipelines with explicit contracts and artifact boundaries.
**Trade-offs**: Higher initial design effort; significantly better long-term operability.

## LLM Twin Product Pattern
**When to use**: Creating a persona/domain-specific assistant requiring style and grounding consistency.
**How**: Combine curated data ingestion, optional fine-tuning/alignment, and RAG inference.
**Trade-offs**: More engineering complexity than prompt-only bots; much better control and reliability.

## Crawler Dispatcher Pattern
**When to use**: Ingesting heterogeneous sources such as GitHub, Medium, and custom sites.
**How**: Dispatch source metadata to specialized crawler implementations and normalize outputs.
**Trade-offs**: More components to maintain; easier extension and debugging.

## RAG Feature Snapshot Pattern
**When to use**: Need reliable, incrementally updated retrieval corpora.
**How**: Clean, chunk, embed, and index content with snapshot metadata and CDC synchronization.
**Trade-offs**: Extra storage and bookkeeping; strong traceability and rollback support.

## Stage-wise Advanced RAG Optimization
**When to use**: Baseline RAG quality plateaus.
**How**: Apply pre-retrieval (query expansion), retrieval (filters), and post-retrieval (reranking) improvements.
**Trade-offs**: Increased runtime complexity; substantial relevance gains when tuned correctly.

## Instruction Data Quality Loop
**When to use**: Preparing SFT datasets for domain-specific behavior.
**How**: Curate, deduplicate, decontaminate, evaluate, and augment instruction samples.
**Trade-offs**: Data prep effort is high; often the highest-return investment for quality.

## PEFT Selection Pattern
**When to use**: Fine-tuning under memory or cost constraints.
**How**: Choose between full FT, LoRA, and QLoRA based on resource and quality targets.
**Trade-offs**: PEFT is efficient but may underperform full FT in some edge cases.

## Preference Alignment Loop
**When to use**: Need behavior refinement after SFT.
**How**: Build preference pairs, validate label quality, train with DPO or RLHF, and run regression checks.
**Trade-offs**: Annotation and evaluation overhead; better helpfulness/safety alignment.

## Evaluation Pyramid for LLM Products
**When to use**: Selecting models and gating releases.
**How**: Combine general benchmarks, domain tests, task metrics, and RAG grounding evaluation.
**Trade-offs**: More metrics and tooling required; better decision quality.

## Inference Optimization Ladder
**When to use**: Latency or serving cost misses targets.
**How**: Sequentially apply KV cache, batching, decoding optimizations, parallelism, then quantization.
**Trade-offs**: Optimization can add operational complexity; must guard against quality regressions.

## Deployment Mode Fit Pattern
**When to use**: Mapping workload to serving architecture.
**How**: Select online, async, or batch inference per SLA and traffic profile; define autoscaling policies.
**Trade-offs**: Hybrid modes increase complexity; improves cost-performance fit.

## CI/CD/CT LLMOps Pattern
**When to use**: Operating LLM systems in production with continuous change.
**How**: Automate integration tests, deployment gates, training triggers, prompt monitoring, and alerts.
**Trade-offs**: Pipeline upkeep required; major reliability and governance gains.
