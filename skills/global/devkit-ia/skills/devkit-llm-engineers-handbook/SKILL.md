---
name: devkit-llm-engineers-handbook
description: "Knowledge base for production LLM engineering: feature-training-inference architecture, RAG, evaluation, inference optimisation, deployment, and LLMOps."
triggers:
	- "diseña LLMOps"
	- "despliega un LLM en producción"
	- "optimiza inferencia o costes de LLM"
non_triggers:
	- "implementar una cadena LangChain concreta"
	- "elegir una arquitectura general de agentes"
---

<!-- argument-hint: [topic, framework name, or chapter number] -->

# LLM Engineer's Handbook
**Author**: Paul Iusztin, Maxime Labonne | **Pages**: ~523 | **Chapters**: 12 | **Generated**: 2026-08-06

## Purpose

Guide production architecture for LLM products: data, training, inference, evaluation, observability, deployment, and LLMOps.

## When to use

- Designing production RAG, LLM feature/training/inference pipelines, deployment, observability, cost optimisation, or LLMOps.
- Defining operational controls for an AI capability consumed by mobile or backend applications.

## When NOT to use

- Selecting model learning techniques in isolation; use `devkit-generative-ai-with-python-and-pytorch`.
- Implementing LangChain or LangGraph specifics; use `devkit-generative-ai-langchain`.

## Inputs

- Product requirements, data freshness, quality, privacy, regulatory, latency, throughput, cost, and operational constraints.
- Existing mobile, backend, cloud, and CI/CD topology.

## Steps

1. Define feature, training, and inference responsibilities and their contracts.
2. Design ingestion, evaluation, serving, monitoring, release, rollback, and cost-control mechanisms.
3. Choose a deployment topology proportional to product scale and operational maturity.
4. Read the detailed source material for the selected pipeline components.
5. Check official online documentation for current providers, deployment platforms, pricing, security, licensing, and regulations before making recommendations.

## Expected outputs

- An FTI/LLMOps architecture with interfaces, quality gates, observability, and operations plan.
- Explicit rollout, rollback, monitoring, and governance requirements.

## Validation

- Verify quality, grounding, latency, cost, safety, and operational alerts against measurable thresholds.
- Confirm all external technology claims with current official sources.

## Examples

- "Diseña el pipeline de producción para un RAG que consume una aplicación iOS y Android."
- "Define métricas, despliegue progresivo y rollback para una nueva versión de un modelo."

## How to Use This Skill

- **Without arguments**: load core frameworks for production LLM engineering
- **With a topic**: ask about `RAG`, `DPO`, `quantization`, `autoscaling`, `LLMOps`, etc.
- **With chapter**: ask for `ch04` or `ch10`
- **Browse**: ask for available chapters and topic index

When a topic is not fully covered in Core Frameworks, read the matching chapter file before answering.

---

## Core Frameworks & Mental Models

### 1) Build LLM products as systems, not prompts
Use **FTI architecture** (Feature, Training, Inference) as the default operating model.
- Use **Feature pipeline** for ingestion, cleaning, chunking, embedding, indexing.
- Use **Training pipeline** for SFT/alignment lifecycle and experiment reproducibility.
- Use **Inference pipeline** for runtime retrieval, generation, policy enforcement, and observability.
- Prefer explicit contracts between stages to minimize hidden coupling.

Decision rule: if one component change breaks unrelated runtime behavior, your boundaries are weak.

### 2) Start with MVP and traceable tooling
Use an MVP lens to define narrow, measurable product value before deep optimization.
- Prefer reproducible environments and lockfiles.
- Use orchestration and artifact metadata from the beginning.
- Track experiments and prompts to make regressions diagnosable.

Decision rule: if onboarding requires tribal setup knowledge, tooling discipline is insufficient.

### 3) Treat data engineering as the quality floor
For LLM Twins and RAG applications, answer quality is bounded by data quality and freshness.
- Separate crawlers by source type and normalize into stable document schemas.
- Keep raw and feature representations traceable.
- Use incremental synchronization (CDC or equivalent) to maintain freshness.

Decision rule: before changing model weights, inspect ingestion and document quality first.

### 4) Engineer RAG as a staged pipeline
Use the three-stage RAG view:
- **Pre-retrieval**: query transformations (expansion, self-querying)
- **Retrieval**: vector + metadata-constrained search
- **Post-retrieval**: reranking and context quality filtering

This allows targeted optimization where failures occur.

Decision rule: if answers are plausible but ungrounded, inspect retrieval precision before prompt tweaks.

### 5) Fine-tune with data-first discipline
SFT success comes from dataset quality, format consistency, and controlled tuning loops.
- Curate and deduplicate instruction data.
- Decontaminate train/eval overlap.
- Choose FT strategy by constraints: Full FT vs LoRA vs QLoRA.
- Enforce comparable experiment settings when evaluating gains.

Decision rule: unstable response style usually indicates data/template issues more than optimizer choice.

### 6) Use preference alignment to refine behavior
When SFT gets baseline competency but not desired response behavior:
- Build preference datasets with consistent annotation rules.
- Start with DPO when you want lower operational complexity.
- Use RLHF for richer reward-driven optimization when justified.
- Evaluate behavior changes with regression suites, not anecdotal prompts.

Decision rule: if model is knowledgeable but not reliably helpful/safe, align preferences next.

### 7) Evaluate at four levels
Use layered evaluation for trustworthy decisions:
- General benchmarks
- Domain-specific tests
- Task/product metrics
- RAG grounding metrics (faithfulness/relevance)

Decision rule: never promote a model solely on broad benchmark gains.

### 8) Optimize inference with a cost-quality lens
Performance tuning sequence:
1. KV cache
2. Batching strategy
3. Decoding optimizations
4. Parallelism strategy
5. Quantization with regression checks

Decision rule: do not scale hardware before profiling software bottlenecks.

### 9) Choose deployment mode by workload
Select serving mode from product constraints:
- Online for interactive latency-sensitive flows
- Async for queueable medium-latency workloads
- Batch for offline bulk jobs

Use monolith first for rapid iteration unless independent scaling/isolation justifies microservices.

Decision rule: if architecture complexity rises faster than user value, simplify serving boundaries.

### 10) Operationalize with LLMOps loops
LLMOps extends MLOps with prompt and behavior governance.
- CI for code/data contract quality
- CD for controlled release gates
- CT for retraining/alignment triggers
- Prompt monitoring + alerting for production drift

Decision rule: if incidents are discovered by users before dashboards, observability is insufficient.

---

## Chapter Index

| # | Title | Key Frameworks |
|---|---|---|
| [ch01](chapters/ch01-llm-twin-architecture.md) | Understanding the LLM Twin Concept and Architecture | LLM Twin, FTI, MVP |
| [ch02](chapters/ch02-tooling-and-installation.md) | Tooling and Installation | Reproducible stack, orchestration, storage strategy |
| [ch03](chapters/ch03-data-engineering.md) | Data Engineering | Dispatcher crawlers, ODM, ingestion reliability |
| [ch04](chapters/ch04-rag-feature-pipeline.md) | RAG Feature Pipeline | Vanilla/advanced RAG, embeddings, CDC |
| [ch05](chapters/ch05-supervised-fine-tuning.md) | Supervised Fine-Tuning | Data quality loop, PEFT, tuning controls |
| [ch06](chapters/ch06-preference-alignment.md) | Fine-Tuning with Preference Alignment | Preference datasets, DPO, RLHF |
| [ch07](chapters/ch07-evaluating-llms.md) | Evaluating LLMs | Layered evaluation, RAG metrics |
| [ch08](chapters/ch08-inference-optimization.md) | Inference Optimization | KV cache, batching, parallelism, quantization |
| [ch09](chapters/ch09-rag-inference-pipeline.md) | RAG Inference Pipeline | Query expansion, self-querying, reranking |
| [ch10](chapters/ch10-inference-deployment.md) | Inference Pipeline Deployment | Deployment modes, service architecture, autoscaling |
| [ch11](chapters/ch11-mlops-llmops.md) | MLOps and LLMOps | CI/CD/CT, guardrails, monitoring |
| [ch12](chapters/ch12-mlops-principles-appendix.md) | Appendix: MLOps Principles | Automation, versioning, tracking, testing |

## Topic Index

- **Advanced RAG** -> ch04, ch09
- **Autoscaling** -> ch10
- **CDC** -> ch04
- **Comet / Tracking** -> ch02, ch12
- **DPO** -> ch06
- **Evaluation** -> ch07
- **FTI Architecture** -> ch01
- **KV Cache** -> ch08
- **LLM Twin** -> ch01
- **LLMOps** -> ch11
- **LoRA / QLoRA** -> ch05
- **MLOps Principles** -> ch11, ch12
- **Prompt Monitoring** -> ch02, ch11
- **Qdrant / Vector DB** -> ch02, ch04
- **RAG Feature Pipeline** -> ch04
- **RAG Inference Pipeline** -> ch09
- **RLHF** -> ch06
- **SFT** -> ch05
- **SageMaker Deployment** -> ch10
- **ZenML** -> ch02

## Supporting Files

- [glossary.md](glossary.md) - key terms with chapter references
- [patterns.md](patterns.md) - implementation-ready patterns and trade-offs
- [cheatsheet.md](cheatsheet.md) - decision rules and quick selection tables

---

## Scope & Limits

This skill covers concepts and frameworks from the book only. For repo-specific implementation choices, combine with local architecture conventions and testing constraints.
