# Chapter 12: Appendix - MLOps Principles

## Core Idea
The appendix distills enduring MLOps principles that stabilize ML and LLM delivery across teams and environments.

## Frameworks Introduced
- **Automation / Operationalization**
  - When to use: Repetitive manual tasks introduce delay or inconsistency.
  - How: Convert manual model lifecycle actions into scripted pipelines.
- **Versioning Everywhere**
  - When to use: Need traceability across data, code, and models.
  - How: Maintain immutable references and lineage links.
- **Experiment Tracking Discipline**
  - When to use: Comparing many runs and configurations.
  - How: Log parameters, datasets, metrics, and artifacts systematically.
- **Testing Layers for ML Systems**
  - When to use: Prevent regressions from code or data changes.
  - How: Combine unit, integration, data, and model-behavior tests.

## Key Concepts
- **Operationalization**: Repeatable, reliable workflow execution.
- **Lineage**: End-to-end provenance of artifacts.
- **Run metadata**: Structured record of each experiment.
- **ML testing pyramid**: Multiple validation layers for confidence.

## Mental Models
Use **traceability as risk control**. Assume change is constant; design **systems that explain themselves** through metadata.

## Anti-patterns
- **Unversioned datasets**: Makes model behavior irreproducible.
- **Metric-only experiment logs**: Hides why outcomes changed.

## Worked Example
A release readiness checklist:
1. Confirm data snapshot and model artifact versions are pinned.
2. Verify training run metadata includes parameters and code revision.
3. Execute automated test suites and gate deployment on thresholds.
4. Store lineage links in registry for incident recovery.

## Key Takeaways
1. Principles outlive tooling choices.
2. Governance improves speed by reducing uncertainty.
3. Reproducibility is a prerequisite for trustworthy AI systems.

## Connects To
- **Ch 5/6**: Fine-tuning and alignment need rigorous experiment tracking.
- **Ch 11**: LLMOps operationalizes these principles continuously.
