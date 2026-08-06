# Patterns

## Plan-Act-Reflect Loop
**When to use**: open-ended tasks with quality risk.
**How**: create plan, execute small step set, assess with rubric, revise if needed.
**Trade-offs**: higher latency but significantly better reliability.

## Coordinator-Worker-Delegator (CWD)
**When to use**: tasks require specialization and parallelization.
**How**: coordinator defines DAG, workers execute domain tasks, delegator validates and merges.
**Trade-offs**: orchestration overhead and stronger interface requirements.

## Guardrail Layering
**When to use**: safety, compliance, or reputational risk exists.
**How**: combine input filters, policy checks, output validation, and human escalation.
**Trade-offs**: lower throughput in exchange for lower incident probability.

## Memory Stratification
**When to use**: context spans multiple sessions or stakeholders.
**How**: split volatile working memory from durable indexed memory.
**Trade-offs**: extra design complexity for better consistency and reuse.

## Tool-Gated Execution
**When to use**: external side effects (tickets, code changes, transactions).
**How**: require preconditions before calls and postconditions after responses.
**Trade-offs**: more control logic, fewer silent failures.

## Evaluation-First Delivery
**When to use**: you need measurable quality before shipping.
**How**: define acceptance tests and confidence thresholds before implementation.
**Trade-offs**: more upfront effort, faster downstream iteration.
