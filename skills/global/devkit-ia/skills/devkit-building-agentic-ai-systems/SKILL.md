---
name: devkit-building-agentic-ai-systems
description: "Knowledge base for designing safe, observable agentic AI systems with bounded autonomy, planning, orchestration, trust, and evaluation."
triggers:
	- "diseña una arquitectura de agentes"
	- "necesito un sistema multiagente"
	- "define guardrails para agentes de IA"
non_triggers:
	- "implementar una cadena LangChain concreta"
	- "entrenar o afinar un modelo"
---

<!-- argument-hint: [topic, framework name, or chapter number] -->

# Building Agentic AI Systems
**Author**: Anjanava Biswas, Wrick Talukdar | **Pages**: ~292 | **Chapters**: 11 | **Generated**: 2026-08-06

## Purpose

Provide architecture guidance for agentic AI systems, including autonomy boundaries, orchestration, safety, trust, and evaluation.

## When to use

- Designing agents, multi-agent workflows, planning loops, memory, tool use, or human approval checkpoints.
- Defining safety, traceability, and evaluation requirements for an agentic product.

## When NOT to use

- Implementing a framework-specific LangChain or LangGraph workflow; use `devkit-generative-ai-langchain`.
- Selecting fine-tuning, PyTorch, or generative-model techniques; use `devkit-generative-ai-with-python-and-pytorch`.

## Inputs

- Product objective, users, data sensitivity, autonomy level, tool permissions, latency and cost constraints.
- Existing software and mobile architecture when integration is in scope.

## Steps

1. Define the user outcome and bounded autonomy policy.
2. Select the smallest viable agent topology and assign tool preconditions and postconditions.
3. Define human escalation, observability, safety controls, and measurable evaluation criteria.
4. Read the relevant chapter material before making a detailed recommendation.
5. When versions, model availability, APIs, pricing, regulation, or security guidance affect the outcome, verify them online using official provider or framework documentation before recommending them.

## Expected outputs

- A documented agent topology, responsibilities, trust boundaries, and escalation paths.
- Acceptance criteria for safety, observability, and evaluation.

## Validation

- Confirm each autonomous action has explicit permissions, failure behavior, and human escalation where risk requires it.
- Confirm current external facts with official online documentation and record assumptions.

## Examples

- "Diseña un agente que clasifique solicitudes y escale decisiones de crédito a una persona."
- "Compara supervisor y coordinator-worker-delegator para un asistente de soporte."

## How to Use This Skill

- **Without arguments**: load core frameworks and navigate the chapter map.
- **With a topic**: ask for terms like `reflection`, `tool use`, `trust`, `safety`, or `cwd`.
- **With chapter**: ask for `ch05` to dive into a specific section.
- **Browse**: ask "what chapters do you have?" to list all chapter entries.

When you ask about a topic that is not in the core section, read the relevant chapter file before answering.

## Core Frameworks & Mental Models

- **Bounded Autonomy**: allow agents to act only inside explicit policy, safety, and cost boundaries.
- **Plan-Act-Reflect**: design execution as an iterative loop; quality emerges from controlled revision.
- **Memory Stratification**: combine short-term working context with durable indexed memory.
- **Tool-Gated Execution**: treat tool use as controlled side effects with preconditions and postconditions.
- **Role-Based Orchestration (CWD)**: split responsibilities into coordinator, worker, and delegator roles.
- **Evaluation-First Delivery**: define measurable acceptance criteria before implementation.
- **Trust by Design**: expose traces, confidence, and rationale to users and operators.
- **Safety Layering**: stack preventive, detective, and corrective controls instead of relying on one filter.
- **Human Escalation Paths**: route ambiguous or high-risk decisions to a human checkpoint.
- **Operational Feedback Loops**: feed incidents and drift signals back into policy and tests.

## Chapter Index

| # | Title | Key Frameworks |
|---|---|---|
| [ch01](chapters/ch01-fundamentals-of-generative-ai.md) | Fundamentals of Generative AI | Generative modeling lifecycle, Latent representation learning |
| [ch02](chapters/ch02-principles-of-agentic-systems.md) | Principles of Agentic Systems | Agency and autonomy boundaries, Perceive-think-act loop |
| [ch03](chapters/ch03-essential-components-of-intelligent-agents.md) | Essential Components of Intelligent Agents | Memory and context windows, Reasoning core and policy |
| [ch04](chapters/ch04-reflection-and-introspection-in-agents.md) | Reflection and Introspection in Agents | Self-critique loops, Error attribution |
| [ch05](chapters/ch05-enabling-tool-use-and-planning-in-agents.md) | Enabling Tool Use and Planning in Agents | Tool selection policy, Task planning graph |
| [ch06](chapters/ch06-coordinator-worker-and-delegator-approach.md) | Exploring the Coordinator, Worker, and Delegator Approach | Role-based orchestration, Work decomposition contracts |
| [ch07](chapters/ch07-effective-agentic-system-design-techniques.md) | Effective Agentic System Design Techniques | Design-by-constraints, Evaluation-first development |
| [ch08](chapters/ch08-building-trust-in-generative-ai-systems.md) | Building Trust in Generative AI Systems | Traceability, Explainability artifacts |
| [ch09](chapters/ch09-managing-safety-and-ethical-considerations.md) | Managing Safety and Ethical Considerations | Risk taxonomy, Guardrail layering |
| [ch10](chapters/ch10-common-use-cases-and-applications.md) | Common Use Cases and Applications | Support automation, Knowledge copilots |
| [ch11](chapters/ch11-conclusion-and-future-outlook.md) | Conclusion and Future Outlook | Operational maturity model, Roadmap for adoption |

## Topic Index

- **agency** -> ch02
- **applications** -> ch10
- **coordinator worker delegator** -> ch06
- **ethics** -> ch09
- **evaluation rubric** -> ch07
- **generative ai fundamentals** -> ch01
- **introspection** -> ch04
- **planning** -> ch05
- **reflection loop** -> ch04
- **safety** -> ch09
- **tool use** -> ch05
- **trust** -> ch08

## Supporting Files

- [glossary.md](glossary.md) — key terms and concise definitions.
- [patterns.md](patterns.md) — reusable architecture and execution patterns.
- [cheatsheet.md](cheatsheet.md) — quick decision rules and trade-off tables.

## Scope & Limits

This skill covers concepts from this specific book. For implementation details in your own codebase, combine these patterns with your stack-specific constraints, internal standards, and operational requirements.
