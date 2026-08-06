# Chapter 2: Tooling and Installation

## Core Idea
Tooling choices determine developer velocity, reproducibility, and production readiness. The chapter composes a practical stack for LLM engineering from local development to cloud execution.

## Frameworks Introduced
- **Reproducible Python Toolchain (Poetry + task runner)**
  - When to use: Multi-dependency ML projects.
  - How: Lock dependencies, isolate environments, centralize repeatable tasks.
- **LLMOps Platform Stack**
  - When to use: Moving from notebooks to governed workflows.
  - How: Combine model registry, orchestration, experiment tracking, and prompt monitoring.
- **Polyglot Data Storage Strategy**
  - When to use: Need both document retrieval and semantic search.
  - How: Pair document store (NoSQL) with vector DB.

## Key Concepts
- **Poetry**: Dependency and virtualenv management.
- **Poe the Poet**: Task automation.
- **ZenML**: Pipeline orchestration, artifacts, metadata.
- **Comet ML**: Experiment tracking.
- **Opik**: Prompt monitoring and observability.
- **Qdrant**: Vector similarity database.
- **SageMaker**: Managed training/inference infrastructure.

## Mental Models
Use **tooling as architecture**: the selected stack encodes how teams collaborate. Think of **metadata first** systems as easier to debug and audit.

## Anti-patterns
- **Manual environment setup per developer**: Creates irreproducible runs.
- **No experiment tracker**: Hyperparameter decisions become untraceable.

## Worked Example
A team standardizes onboarding:
1. Defines Poetry lockfile and canonical tasks (lint, test, pipeline runs).
2. Registers ZenML stack profiles for local and AWS execution.
3. Stores raw data in MongoDB and embeddings in Qdrant.
4. Tracks every fine-tune run in Comet with dataset and commit references.
Result: new engineers can run end-to-end flows with minimal tribal knowledge.

## Key Takeaways
1. Reproducibility and observability should be first-class requirements.
2. Separate infra concerns early to avoid costly migration later.
3. Use managed services when they reduce operational burden.

## Connects To
- **Ch 3**: Data collection pipelines rely on stack primitives.
- **Ch 10**: Deployment strategy builds on cloud tooling.
