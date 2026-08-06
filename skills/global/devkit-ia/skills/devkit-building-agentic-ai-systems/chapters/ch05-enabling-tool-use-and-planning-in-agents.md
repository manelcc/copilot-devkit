# Chapter 5: Enabling Tool Use and Planning in Agents

## Core Idea
This chapter defines the practical operating model for agentic AI in this topic area and shows how to turn LLM capability into repeatable execution rules.

## Frameworks Introduced
- **Tool selection policy**
  - When to use: when scope is broad and requirements are evolving.
  - How: define inputs, control points, success criteria, and stop conditions first.
- **Task planning graph**
  - When to use: when decisions depend on historical context.
  - How: separate short-term working memory from durable knowledge.
- **Execution monitoring**
  - When to use: when actions must be reliable under constraints.
  - How: apply explicit gating before external actions and after each major step.

## Key Concepts
- **Objective function**: explicit definition of what success looks like for the agent run.
- **Constraint envelope**: safety, policy, and cost boundaries that execution cannot violate.
- **Action trace**: observable sequence of reasoning decisions and tool outcomes.
- **Recovery strategy**: pre-defined behavior when confidence drops or tools fail.
- **Evaluation rubric**: measurable quality checks applied before completion.

## Mental Models
- Use **bounded autonomy** when the task has compliance or operational risk.
- Think of the system as a **control loop**, not a single prompt.
- Prefer **small verifiable steps** over long opaque chains of reasoning.

## Anti-patterns
- **Unbounded delegation**: handing off complex work without guardrails or acceptance criteria.
- **Single-pass execution**: shipping first output without reflection or validation.
- **Hidden assumptions**: implicit context that is not encoded in memory or prompts.

## Code Examples
```python
# Minimal pattern: plan -> act -> reflect
state = memory.load(task_id)
plan = planner.create(goal=state.goal, constraints=state.constraints)
result = executor.run(plan)
review = reflector.assess(result, rubric=state.quality_rubric)
if not review.passed:
    plan = planner.revise(plan, feedback=review.feedback)
```

- **What it demonstrates**: iterative execution with explicit review and controlled re-planning.

## Reference Tables
| Decision | Prefer A | Prefer B |
|---|---|---|
| Planning granularity | Short tasks (<30 min) | Multi-stage workflows |
| Memory strategy | Stateless retrieval | Hybrid short+long memory |
| Handoff style | Direct execution | Role-based delegation |

## Worked Example
A product team asks an agent to draft and validate a release-readiness report. The agent breaks work into data collection, risk scoring, and summary drafting. After the first pass, reflection detects missing evidence for two risks. The agent re-plans, fetches additional signals, and only then finalizes the report with confidence notes and open issues.

## Key Takeaways
1. Encode goals and constraints before execution starts.
2. Use reflection checkpoints to improve reliability, not just polish writing.
3. Separate orchestration logic from domain knowledge to keep systems maintainable.
4. Keep observable traces for debugging, trust, and governance.

## Connects To
- **Ch 4**: introduces prerequisites used by this chapter's methods.
- **Ch 6**: extends these methods into the next operational layer.
