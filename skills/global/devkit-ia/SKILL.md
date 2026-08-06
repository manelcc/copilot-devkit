---
name: "devkit-ia"
description: >
  Umbrella skill for AI architecture and delivery decisions across mobile and backend.
  Routes to the right devkit IA sub-skill for agentic systems, LangChain, model strategy, and LLMOps.
triggers:
  - "quiero arquitectura de IA"
  - "qué stack de IA usamos"
  - "cómo integro IA en mobile"
  - "diseña arquitectura AI end-to-end"
non_triggers:
  - "solo backlog o refinement"
  - "solo implementación de código sin decisión de arquitectura"
---

# Devkit IA

## Purpose

Provide a single entry point for AI decisions and route each request to the most relevant specialized DevKit IA skill.

## When to use

- You need to decide language, architecture, and integration for AI capabilities.
- You need mobile plus backend plus AI design trade-offs.
- You are unsure whether to use agentic systems, LangChain, RAG, fine-tuning, or LLMOps.

## When NOT to use

- Backlog refinement without architecture decisions; use `Scrum Master`.
- Pure implementation tasks where architecture is already approved.

## Inputs

- Product objective and user flows.
- Platform scope (Android, iOS, backend, cloud).
- Data constraints, privacy, latency, cost, and compliance constraints.
- Team capabilities and delivery timeline.

## Steps

1. Classify the decision type: architecture strategy, framework implementation, model strategy, or production operations.
2. Route to one primary skill:
   - `devkit-building-agentic-ai-systems` for autonomy, orchestration, trust, and safety.
   - `devkit-generative-ai-langchain` for LangChain/LangGraph/LangSmith design.
   - `devkit-generative-ai-with-python-and-pytorch` for RAG vs fine-tuning and model choices.
   - `devkit-llm-engineers-handbook` for production FTI and LLMOps.
3. If needed, combine two skills and reconcile trade-offs in one final recommendation.
4. Verify time-sensitive facts online in official documentation before closing the recommendation.

## Expected outputs

- Clear architecture recommendation with 2-3 alternatives and trade-offs.
- Decision record with mobile/backend/AI boundaries.
- Validation plan: quality, safety, latency, cost, and rollout checks.

## Validation

- Confirm recommendations map to measurable product outcomes.
- Confirm all current external facts (versions, prices, support, limits, licensing) using official online sources.
- Confirm handoff target: the correct stack-specific orchestrator for implementation.

## Examples

- "Tenemos app mobile nueva y queremos IA: ¿Python o Kotlin backend y qué arquitectura?"
- "¿On-device inference o backend inference para OCR con datos sensibles?"
- "Queremos asistente con RAG: ¿LangGraph o flow determinista?"
