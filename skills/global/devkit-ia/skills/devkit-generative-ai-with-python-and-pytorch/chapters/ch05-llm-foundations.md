# Chapter 5: LLM Foundations

## Core Idea
Large Language Models (LLMs) differ from fine-tuned transformers not just in scale but in their training paradigm: pre-training on internet-scale data followed by instruction fine-tuning and Reinforcement Learning from Human Feedback (RLHF) to align model behavior with human intent. InstructGPT (Ouyang et al., 2022) established this three-stage recipe that powers GPT-4, Claude, and all modern aligned LLMs.

## Frameworks Introduced

- **Two-Step Training Paradigm (Pre-training + Fine-tuning)**:
  - Pre-training: unsupervised causal LM objective on massive corpora (web text, books, code). Learns broad language understanding.
  - Fine-tuning: supervised adaptation on smaller task-specific datasets. Specializes pre-trained knowledge.
  - When to choose fine-tuning over RAG: when the task requires behavior/style change, not just knowledge injection.

- **Instruction Fine-tuning (SFT)**:
  - When to use: when a pre-trained LM consistently goes off-context or fails to follow user instructions.
  - How: curate a demonstration dataset with (instruction, desired_output) pairs → fine-tune with standard causal LM objective on these pairs.
  - Key difference from standard SFT: input includes explicit task instruction, not just context.

- **RLHF (Reinforcement Learning from Human Feedback)**:
  - When to use: after SFT, when model outputs are functional but not aligned with human preferences.
  - How (3 steps):
    1. **Supervised Fine-Tuning (SFT)**: fine-tune base LM on demonstrations.
    2. **Reward Model Training**: train a classifier on human preference rankings (A is better than B).
    3. **RL Optimization (PPO)**: optimize policy LM to maximize reward, with KL divergence penalty against reference model to prevent distribution collapse.
  - Key hyperparameter: KL penalty coefficient — prevents the RL-optimized model from diverging too far from the SFT model.

- **PPO (Proximal Policy Optimization)**:
  - When to use: the standard RL algorithm for RLHF in LLMs.
  - How: generates response from policy model → score with reward model → update policy to increase expected reward → KL term constrains update size.
  - Hugging Face `trl` library implements this cleanly.

## Key Concepts

- **Alignment**: ensuring model outputs match user intent and human values — not just "correct" but "helpful, harmless, honest"
- **InstructGPT**: 1.3B parameter model (vs. GPT-3's 175B) that outperformed GPT-3 via RLHF — smaller but better aligned
- **Context Window**: maximum token length the LM can attend to; longer → richer context but more compute
- **Emergent Capabilities**: abilities (e.g., in-context learning, chain-of-thought) that appear abruptly as model scale increases
- **In-Context Learning**: GPT-style models adapt to tasks via examples in the prompt — no gradient updates
- **Zero-shot / Few-shot**: prompting without / with a few examples; LLMs do both via in-context learning
- **KL Divergence Penalty**: constraint in RLHF preventing policy model from drifting too far from reference; preserves linguistic quality
- **Reference Model**: frozen copy of SFT model used as KL anchor during PPO training
- **Reward Model**: a classifier trained on human preference labels to score LM outputs during RL

## Mental Models

- Think of RLHF as "hiring a supervisor" — the reward model is a human preference proxy, PPO is the training loop that optimizes for the supervisor's score.
- Pre-training = "read everything on the internet." Instruction fine-tuning = "now follow instructions." RLHF = "now be actually helpful and safe."
- InstructGPT lesson: alignment beats scale — a 1.3B model trained with RLHF beats a 175B model without it.
- KL penalty = "don't change too much per step" — like a leash on the RL optimization to prevent catastrophic forgetting.

## Anti-patterns

- **Skipping instruction tuning before RLHF**: RLHF alone is insufficient if the base model doesn't know how to follow instructions.
- **Reward hacking**: reward model trained on limited human data can be gamed by RL — model learns to maximize reward score without being genuinely helpful.
- **Ignoring KL penalty**: without KL constraint, PPO drives the LM to degenerate outputs that fool the reward model.
- **Fine-tuning the full model on tiny datasets**: catastrophic forgetting; use LoRA/PEFT instead for small datasets.

## Code Examples

```python
from trl import PPOTrainer, PPOConfig, AutoModelForCausalLMWithValueHead, create_reference_model

ppo_config = PPOConfig(
    model_name="raghavbali/gpt2-movie_reviewer",
    steps=200,
    learning_rate=1.41e-5,
)

# Policy model + frozen reference model (share 6 layers to save memory)
model = AutoModelForCausalLMWithValueHead.from_pretrained(ppo_config.model_name)
ref_model = create_reference_model(model, num_shared_layers=6)

ppo_trainer = PPOTrainer(ppo_config, model, ref_model, tokenizer, dataset, data_collator=data_collator)
```
- **What it demonstrates**: setting up the PPO training loop with a policy model and KL-anchoring reference model via Hugging Face `trl`.

```python
# RLHF training loop: generate → score → PPO step
for epoch, batch in enumerate(ppo_trainer.dataloader):
    query_tensors = batch["input_ids"]
    # Step 1: Generate response from policy model
    response_tensors = [ppo_trainer.generate(q, **generation_kwargs) for q in query_tensors]
    # Step 2: Score with reward model (sentiment classifier)
    texts = [q + r for q, r in zip(batch["query"], batch["response"])]
    rewards = [get_rewards(sentiment_pipe(t)) for t in texts]
    # Step 3: PPO update (maximizes reward, penalizes KL divergence from ref)
    stats = ppo_trainer.step(query_tensors, response_tensors, rewards)
```
- **What it demonstrates**: the three-step RLHF loop — generate, score with reward model, update with PPO.

## Worked Example

**RLHF to make GPT-2 generate positive movie reviews:**

Problem: GPT-2 fine-tuned on IMDb generates both positive and negative reviews.
Goal: use RLHF to steer it toward generating positive reviews only.

Setup:
- **Policy model**: `gpt2-movie_reviewer` (GPT-2 fine-tuned on IMDb)
- **Reward model**: `distilbert-imdb` (DistilBERT classifier for sentiment)
- **Reward function**: positive sentiment → reward × 4; negative → reward × 0.5
- **Algorithm**: PPO with KL penalty (shared 6 layers between policy and reference)

Result: after 200 steps, reward score distribution shifts toward positive — model learns to generate positive-sentiment completions from any prompt. Training validated by inspecting `objective/kl` (should stay bounded) and `ppo/returns/mean` (should increase).

## Key Takeaways

1. The three-stage LLM training recipe: Pre-training → Instruction Fine-tuning (SFT) → RLHF. Each stage has a distinct purpose.
2. InstructGPT proved alignment > scale: 1.3B aligned model outperforms 175B unaligned model on instruction following.
3. RLHF requires three components: SFT model, reward model (trained on human preferences), and PPO optimizer.
4. KL divergence penalty is critical in RLHF — prevents reward hacking and preserves linguistic quality.
5. Hugging Face `trl` library makes RLHF experiments accessible without implementing PPO from scratch.

## Connects To

- **Ch 4**: transformer architecture (BERT/GPT) is the base model for all LLM training stages here
- **Ch 6**: open-source LLMs (LLaMA, Falcon, Mistral) follow the same training paradigm
- **Ch 7**: prompt engineering is the inference-time complement to training-time instruction tuning
- **Ch 9**: LLM optimization techniques reduce the cost of running these large aligned models
