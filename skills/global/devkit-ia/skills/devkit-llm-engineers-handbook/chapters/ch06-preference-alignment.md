# Chapter 6: Fine-Tuning with Preference Alignment

## Core Idea
Preference alignment shifts optimization from "match target text" to "prefer better responses", improving helpfulness and policy adherence when SFT plateaus.

## Frameworks Introduced
- **Preference Dataset Construction Loop**
  - When to use: Need nuanced response ranking quality.
  - How: Generate candidate responses, collect pairwise preferences, validate label quality.
- **RLHF vs DPO Strategy**
  - When to use: Selecting alignment method by complexity and stability needs.
  - How: Use DPO for simpler direct optimization; RLHF for richer reward-driven setups.
- **Preference Evaluation Protocol**
  - When to use: Prevent noisy labels from degrading alignment.
  - How: Audit disagreements, score consistency, and re-label edge cases.

## Key Concepts
- **Preference data**: Pairwise choices between candidate outputs.
- **RLHF**: Reinforcement learning with human preference rewards.
- **DPO**: Direct optimization on preferred vs dispreferred pairs.
- **Alignment objective**: Behavioral optimization target.
- **Evaluator consistency**: Reliability of preference judgments.

## Mental Models
Use **alignment as behavior shaping**, not knowledge injection. Prefer **label quality over label volume** in preference datasets.

## Anti-patterns
- **Unvetted synthetic preferences**: Can encode artifacts and regressions.
- **Skipping pre/post comparison**: Makes alignment gains impossible to trust.

## Worked Example
After SFT, a model is verbose and occasionally evasive:
1. Team samples difficult prompts.
2. Creates A/B responses using baseline and candidate decoding settings.
3. Annotators choose preferred outputs by rubric (clarity, factuality, safety).
4. DPO training runs on curated pairs.
5. Regression suite verifies improvements without loss in task accuracy.

## Key Takeaways
1. Preference alignment is crucial for practical response behavior.
2. DPO often gives high value with lower operational complexity.
3. Label governance is the highest-leverage investment.

## Connects To
- **Ch 7**: Alignment must be verified with targeted evaluation.
- **Ch 11**: Preference data collection belongs in LLMOps loops.
