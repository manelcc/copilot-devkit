# Chapter 11: MLOps and LLMOps

## Core Idea
LLMOps extends DevOps and MLOps with human feedback loops, guardrails, and prompt monitoring to keep LLM systems reliable under continuous change.

## Frameworks Introduced
- **DevOps → MLOps → LLMOps Continuum**
  - When to use: Establishing operating model for AI products.
  - How: Inherit automation/versioning/testing, then add model and prompt-specific controls.
- **CI/CD/CT for LLM Systems**
  - When to use: Continuous delivery with model lifecycle management.
  - How: Automate code checks, deployment, and training triggers.
- **Operational Guardrails Framework**
  - When to use: Safety, quality, or policy compliance risks.
  - How: Add monitoring, alerts, and feedback-driven corrective flows.

## Key Concepts
- **MLOps principles**: Automation, versioning, experiment tracking, testing.
- **LLMOps**: MLOps plus prompt/feedback/safety operations.
- **CI/CD/CT**: Integration, deployment, and training automation.
- **Prompt monitoring**: Runtime prompt-response observability.
- **Alerting**: Detection of quality and reliability regressions.

## Mental Models
Treat LLM operations as **continuous governance**, not periodic cleanup. Build **feedback-to-improvement loops** into default workflows.

## Anti-patterns
- **Deploy-and-forget**: No monitoring for drift or prompt regressions.
- **Manual release gates only**: Slow and inconsistent quality control.

## Worked Example
An LLM Twin production loop:
1. CI validates formatting, linting, and tests.
2. CD deploys inference services after quality gates.
3. CT triggers periodic retraining/alignment jobs.
4. Prompt monitoring surfaces regressions; alerts open incident workflows.

## Key Takeaways
1. LLM systems require stronger operational discipline than prototypes.
2. Human feedback and prompt monitoring are first-class operational signals.
3. CI/CD/CT pipelines are core product infrastructure.

## Connects To
- **Ch 10**: Deployment patterns define operational blast radius.
- **Ch 12**: Principles appendix provides governance checklist.
