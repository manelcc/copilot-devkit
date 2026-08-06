# Chapter 10: Emerging Applications in Generative AI

## Core Idea
The frontier of LLM research is expanding in five directions simultaneously: improved alignment techniques (RLAIF, DPO, KTO), model compression (distillation, LoRA), hallucination detection, multimodal generation (text + images + audio), and agentic AI (models that plan, use tools, and act autonomously). This chapter surveys the cutting edge without deep-diving any single area.

## Frameworks Introduced

- **RLAIF (Reinforcement Learning from AI Feedback)**:
  - When to use: RLHF requires expensive human annotation; RLAIF replaces human labelers with an already-aligned LLM.
  - How: a "constitutional" aligned LLM scores candidate outputs; these AI-generated scores train the reward model.
  - Trade-off: scales better than RLHF; may propagate biases from the scoring LLM.

- **d-RLAIF (Direct RLAIF)**:
  - How: skip training a separate reward model — use the aligned LLM's direct reward scores to fine-tune the policy.
  - Advantage: simpler pipeline; removes reward model training instability.

- **DPO (Direct Preference Optimization)**:
  - When to use: when you have pairwise preference data (preferred vs. rejected responses) but want to skip RL training.
  - How: reformulates RLHF as a supervised classification problem — train to maximize the likelihood ratio of preferred over rejected responses.
  - Advantage: no reward model, no PPO training loop; more stable; works well for instruction following and safety.

- **KTO (Kahneman-Tversky Optimization)**:
  - When to use: when you only have binary feedback (good/bad) instead of pairwise preferences.
  - How: inspired by prospect theory — treats gains (good responses) and losses (bad responses) asymmetrically; maximizes the KTO objective directly.
  - Advantage: works with simpler annotation (thumbs up/down, customer satisfaction ratings).

- **Knowledge Distillation**:
  - When to use: compress a large "teacher" model into a smaller "student" model for efficient deployment.
  - How: student is trained to match the teacher's output distribution (soft labels) rather than just the ground-truth labels.
  - Variants: response distillation (match output), feature distillation (match intermediate activations).

- **Hallucination Detection**:
  - Approaches: SelfCheckGPT (sample multiple outputs, check consistency), factuality classifiers, RAG-grounded verification.
  - When to use: any production LLM system where factual correctness is required.

- **Agentic AI**:
  - Definition: models that plan multi-step tasks, use external tools (search, code, APIs), maintain state, and adapt based on outcomes.
  - Key components: planning (CoT/ToT), tool use (ReAct), memory (LangGraph MemorySaver), evaluation/reflection.
  - When to use: tasks that can't be solved in a single LLM call — web research, code generation + execution, multi-document analysis.

## Key Concepts

- **RLHF**: Reinforcement Learning from Human Feedback — the foundational alignment technique (Ch 5)
- **RLAIF**: replace human annotators with an aligned LLM; reduces annotation cost
- **DPO**: direct supervised approach to preference optimization; no RL loop needed
- **KTO**: binary-feedback alignment based on Kahneman-Tversky prospect theory
- **Knowledge Distillation**: teacher (large) → student (small) via soft label matching
- **SelfCheckGPT**: hallucination detection by sampling multiple LLM outputs and measuring consistency
- **Multimodal LLM**: models processing and generating text + images + audio (e.g., GPT-4V, LLaMA-Vision)
- **LoRA (inference context)**: low-rank factorization of weight matrices reduces model size without retraining (see Ch 9)
- **Constitutional AI**: Anthropic's approach — uses a set of written principles as the "constitution" to guide AI feedback
- **Agentic loop**: Plan → Act (external operation) → Observe (operation output) → Reflect → repeat until task complete

## Mental Models

- RLHF → RLAIF → DPO → KTO: progressively reduce human annotation requirements while maintaining alignment quality.
- DPO = "teach the model to prefer better answers" without needing a reward model or RL training.
- Knowledge distillation = "the student learns to think like the teacher" — soft output distributions carry more signal than hard labels.
- Agentic AI = "give the LLM a pen and a phone book, not just its own knowledge" — tools extend what the model can do beyond its training data.

## Anti-patterns

- **Deploying LLMs without hallucination detection in factual domains**: LLMs confidently fabricate citations and statistics; always ground with RAG or verify with SelfCheckGPT.
- **Choosing DPO without pairwise data**: DPO requires (preferred, rejected) pairs; use KTO if you only have binary labels.
- **Agentic loops without termination conditions**: unbounded planning loops will call tools indefinitely; always set max_iterations.
- **Distilling a poorly aligned teacher**: the student inherits the teacher's biases; align the teacher first.

## Reference Tables

| Alignment Method | Human Annotation | RL Training | Pairwise Data | Best For |
|---|---|---|---|---|
| RLHF | High (comparative) | Yes (PPO) | Yes | Highest quality alignment |
| RLAIF | None (AI scores) | Yes | Yes | Scale without human cost |
| DPO | Low (comparative) | No | Yes | Stable alignment, simpler pipeline |
| KTO | Minimal (binary) | No | No | Customer feedback, thumbs up/down |

| Compression Technique | Size Reduction | Quality Impact | Training Required |
|---|---|---|---|
| Knowledge Distillation | 2–10× | Moderate | Yes (supervised) |
| LoRA merge | ~0% (same base) | Minimal | Yes (fine-tuning) |
| Quantization (INT4) | 4× | Small (~1-2%) | No (PTQ) |
| Pruning | 2–4× | Moderate | Optional |

## Key Takeaways

1. Alignment research is moving from expensive RLHF toward cheaper alternatives: RLAIF (AI annotators), DPO (no RL), KTO (binary labels).
2. DPO is rapidly becoming the standard fine-tuning approach for preference alignment — simpler, more stable than PPO-based RLHF.
3. Hallucination detection is not optional in production: use SelfCheckGPT (sampling consistency), RAG grounding, or factuality classifiers.
4. Knowledge distillation can compress a 70B teacher into a competitive 7B student at 10× lower inference cost.
5. Agentic AI (Plan → Act → Observe → Reflect) is the path from LLM as a chatbot to LLM as an autonomous assistant.

## Connects To

- **Ch 5**: RLHF foundational training paradigm — DPO/KTO/RLAIF are improvements on it
- **Ch 7**: ReAct prompting (Ch 7) is the foundation of agentic tool-use loops
- **Ch 8**: LangGraph implements the agentic loop described here
- **Ch 9**: LoRA + quantization (Ch 9) are the compression techniques enabling efficient model deployment
