---
name: devkit-generative-ai-with-python-and-pytorch
description: "Knowledge base for generative AI and PyTorch: LLMs, RAG, fine-tuning, LoRA/QLoRA, alignment, and image-generation architectures."
triggers:
  - "elige entre RAG y fine-tuning"
  - "necesito LoRA o QLoRA"
  - "diseña una solución generativa con PyTorch"
non_triggers:
  - "implementar un workflow específico de LangChain o LangGraph"
  - "definir LLMOps y despliegue de producción"
---

<!-- argument-hint: [topic, framework name, or chapter number — e.g. "LoRA", "stable diffusion", "ch07"] -->

# Generative AI with Python and PyTorch (2nd Edition)
**Authors**: Joseph Babcock & Raghav Bali | **Pages**: ~451 | **Chapters**: 15 | **Generated**: 2026-08-06

## Purpose

Guide architecture and technology choices for generative AI, including RAG, fine-tuning, alignment, PyTorch, LLMs, diffusion, GANs, and evaluation.

## When to use

- Selecting RAG, prompting, fine-tuning, LoRA/QLoRA, DPO/RLHF, or a generative model family.
- Evaluating whether inference belongs on-device, in a backend service, or in a managed model provider.

## When NOT to use

- Implementing LangChain-specific chains or orchestration; use `devkit-generative-ai-langchain`.
- Designing production feature/training/inference pipelines and LLMOps; use `devkit-llm-engineers-handbook`.

## Inputs

- User objective, data modality, labelled-data availability, privacy, latency, cost, hardware, quality, and safety constraints.
- Target platforms, including mobile devices and backend infrastructure.

## Steps

1. Classify the problem and establish success metrics before selecting a model family.
2. Compare prompting, RAG, fine-tuning, and on-device inference against data, privacy, latency, cost, and maintenance constraints.
3. Select an evaluation strategy, safety controls, and an integration boundary for mobile and backend components.
4. Consult detailed chapters for the selected technique.
5. Verify current model licences, framework support, hardware requirements, API capabilities, and model-card safety guidance from official online sources.

## Expected outputs

- A model and integration decision with alternatives, constraints, and evaluation metrics.
- Training or inference requirements, including data governance and hardware assumptions.

## Validation

- Validate quality using representative, held-out data and task-specific measures before rollout.
- Validate current external facts with official documentation and model cards.

## Examples

- "¿RAG o LoRA para responder sobre documentación interna que cambia cada semana?"
- "¿Qué opción de inferencia conviene para una aplicación mobile con datos sensibles?"

## How to Use This Skill

- **Without arguments** — load core frameworks for reference
- **With a topic** — ask about `LoRA`, `diffusion`, `RLHF`, or another indexed topic; I find and read the relevant chapter
- **With chapter** — ask for `ch09`; I load that specific chapter
- **Browse** — ask "what chapters do you have?" to see the full index

When you ask about a topic not covered in Core Frameworks below, I will read the relevant chapter file before answering.

---

## Core Frameworks & Mental Models

### The Generative vs. Discriminative Divide
- **Discriminative models**: learn P(Y|X) — given data, predict label. Classification, regression.
- **Generative models**: learn P(X, Y) or P(X) — model the data distribution; generate new samples.
- **When to use generative**: synthesizing data, augmenting datasets, modeling uncertainty, style transfer.
- **Bayes' theorem** bridges the two: P(Y|X) = P(X|Y)·P(Y) / P(X).

### Latent Variable Z — The Universal Generation Pattern
- Deep generative models (VAEs, GANs, Diffusion) all use a latent variable Z.
- Sample Z from a simple prior (Gaussian) → decode to complex data (image, text).
- The model learns P(X|Z) — how to map from simple random vectors to structured data.

### The Five Generative Architectures

| Architecture | Training | Latent Space | Image Quality | Training Stability | Text Support |
|---|---|---|---|---|---|
| VAE | ELBO (reconstruction + KL) | Explicit, structured | Moderate (blurry) | High | No |
| GAN | Adversarial minimax | Implicit | High (sharp) | Low | No |
| Diffusion (DDPM) | Noise prediction MSE | Via denoising steps | Best | High | No |
| LLM (GPT-style) | Causal LM cross-entropy | Token sequence | N/A | High | Yes |
| Stable Diffusion | ELBO (latent) + CLIP | Latent (VAE-encoded) | Best | High | Yes (text→image) |

### The LLM Training Recipe (Three Stages)
1. **Pre-training**: causal LM on internet-scale data → language understanding + world knowledge
2. **SFT (Instruction Tuning)**: (instruction, response) pairs → learn to follow instructions
3. **RLHF / DPO / KTO**: align to human preferences via reward model + PPO, or directly via preference optimization
- **InstructGPT insight**: 1.3B aligned > 175B unaligned — alignment beats scale.
- **DPO**: replaces RL loop with supervised preference classification; simpler, more stable.
- **KTO**: alignment from binary (good/bad) feedback; no pairwise data needed.

### PEFT: Fine-Tuning Without Full Parameters
- **LoRA**: inject low-rank update ΔW = A·B into frozen weight W; train only A and B (r << dim).
  - r=8–64; lora_alpha ≈ 2×r; zero inference overhead after merging.
- **QLoRA**: LoRA + 4-bit NF4 base model via bitsandbytes; fine-tune 7B+ models on 24GB VRAM.
- **Prompt Tuning**: prepend learnable virtual tokens; 0.002% parameters; lowest compute cost.
- **When to use**: LoRA is the default for most tasks; QLoRA for large models on limited hardware.

### RAG: Knowledge Without Fine-Tuning
- **When**: LLM needs domain knowledge or up-to-date information; no behavior change needed.
- **Pipeline**: Load → Split (chunk_size=1000, overlap=200) → Embed → Store (vector DB) → Retrieve (similarity search) → Generate (augmented prompt).
- **Trade-off**: RAG for knowledge injection; fine-tuning for behavior/style/format change.

### Prompt Engineering Escalation Ladder
- **Zero-shot** → **Few-shot** → **Zero-shot CoT** → **Few-shot CoT** → **ReAct** → **Self-consistency**
- Always try cheaper options first. CoT ("Let's think step by step.") is free — just tokens.
- Temperature: 0–0.3 for factual/code; 0.5–0.8 for chat; 0.9–1.2 for creative.

### GAN Core Mechanics
- **Minimax**: min_G max_D [E log D(x) + E log(1−D(G(z)))]
- **Always use non-saturating G loss**: maximize log D(G(z)), not minimize log(1−D(G(z))).
- **DC-GAN rules**: ConvTranspose2d + BatchNorm + ReLU in G; Conv2d + BatchNorm + LeakyReLU in D; no pooling.
- **Mode collapse** → minibatch std dev. **Training instability** → progressive growth or gradient penalty.
- **Measure quality with FID**, not loss curves.

### VAE Core: ELBO + Reparameterization
- **ELBO** = E[log P(x|z)] − KL(q(z|x)||N(0,I)): reconstruction + KL regularizer.
- **Reparameterization trick**: z = μ + σ·ε where ε ~ N(0,I); makes sampling differentiable.
- **β-VAE**: multiply KL by β > 1; better disentanglement at cost of reconstruction quality.
- **KL penalty** = the "regularizer on the latent space" — without it, generation from z fails.

### Stable Diffusion Pipeline
- **Forward process**: add Gaussian noise x_0 → x_T (DDPM Markov chain, β_t schedule).
- **Reverse process**: U-Net predicts noise ε_θ at each step; subtracts to denoise x_T → x_0.
- **Latent space**: VAE compresses image 8× before diffusion → 192× fewer operations.
- **Text conditioning**: CLIP encodes prompt → 768-dim embedding → cross-attention in U-Net.
- **CFG**: guidance_scale blends conditioned and unconditioned noise predictions.
- **Key parameters**: guidance_scale=7–12, num_inference_steps=20–50, negative_prompt always.

### Transformer Architecture
- **Self-attention**: Attention(Q,K,V) = softmax(QKᵀ/√d_k)·V; O(n²) complexity.
- **BERT** = bidirectional encoder (MLM); **GPT** = causal decoder (autoregressive); **T5/BART** = encoder-decoder.
- **Key improvements in LLaMA**: RMSNorm + RoPE + SwiGLU + GQA (Grouped Query Attention).
- **GQA**: groups queries to share fewer K/V heads; reduces KV-cache memory for inference.

### Chinchilla Scaling Law
- Compute-optimal: ~20 tokens per parameter.
- Scale rule: 8× more parameters → only 5× more data needed.
- Most published LLMs are undertrained — more data at same compute beats more parameters.
- Training cost estimate: FLOPs = parameters × tokens × 6.

---

## Chapter Index

| # | Title | Key Frameworks |
|---|-------|----------------|
| [ch01](chapters/ch01-intro-generative-ai.md) | Introduction to Generative AI | Discriminative vs. Generative, Latent Z, Bayes' Theorem |
| [ch02](chapters/ch02-building-blocks-dnn.md) | Building Blocks of Deep Neural Networks | Backprop, CNN, LSTM, Transformer, ADAM, Xavier Init |
| [ch03](chapters/ch03-text-generation-methods.md) | The Rise of Methods for Text Generation | Word2Vec, GloVe, Character LM, Decoding Strategies, Temperature |
| [ch04](chapters/ch04-transformers-text-generation.md) | NLP 2.0: Using Transformers to Generate Text | Self-Attention, BERT, GPT, Fine-tuning, Hugging Face |
| [ch05](chapters/ch05-llm-foundations.md) | LLM Foundations | InstructGPT, SFT, RLHF, PPO, Alignment |
| [ch06](chapters/ch06-open-source-llms.md) | Open-Source LLMs | LLaMA3, GQA, RoPE, SwiGLU, Mixtral/MoE, HellaSwag/MMLU |
| [ch07](chapters/ch07-prompt-engineering.md) | Prompt Engineering | Zero/Few-shot, CoT, ReAct, ToT, Self-consistency, Temperature |
| [ch08](chapters/ch08-llm-toolbox.md) | LLM Toolbox | LangChain, LCEL, RAG, LangGraph, MemorySaver, LangSmith |
| [ch09](chapters/ch09-llm-optimization.md) | LLM Optimization Techniques | Chinchilla, LoRA, QLoRA, PEFT, Prompt Tuning, Quantization |
| [ch10](chapters/ch10-emerging-applications.md) | Emerging Applications in Generative AI | DPO, KTO, RLAIF, Distillation, Hallucination, Agentic AI |
| [ch11](chapters/ch11-vaes.md) | Neural Networks Using VAEs | VAE, ELBO, Reparameterization Trick, β-VAE, IAF |
| [ch12](chapters/ch12-gans-image-generation.md) | Image Generation with GANs | Vanilla GAN, DC-GAN, cGAN, Progressive GAN, FID, Mode Collapse |
| [ch13](chapters/ch13-style-transfer-gans.md) | Style Transfer with GANs | Pix2Pix, U-Net, PatchGAN, CycleGAN, Cycle Consistency |
| [ch14](chapters/ch14-deepfakes.md) | Deepfakes | FACS, 3DMM, Facial Landmarks, Re-enactment, MTCNN |
| [ch15](chapters/ch15-diffusion-models.md) | Diffusion Models and AI Art | DDPM, Stable Diffusion, CLIP, CFG, VAE Latent, BPE |

## Topic Index

- **ADAM optimizer** → ch02
- **Alignment (LLM)** → ch05, ch10
- **Attention mechanism** → ch02, ch04
- **Autoencoder** → ch11
- **Backpropagation** → ch02
- **Bayes' Theorem** → ch01
- **BERT** → ch04
- **β-VAE** → ch11
- **BPE (Byte Pair Encoding)** → ch15
- **Chain-of-Thought** → ch07
- **Chinchilla / Scaling Laws** → ch09
- **CLIP** → ch15
- **CNN** → ch02, ch12
- **Conditional GAN** → ch12, ch13
- **CycleGAN** → ch13
- **DC-GAN** → ch12
- **Decoding strategies** → ch03, ch07
- **Deepfakes** → ch14
- **Diffusion models (DDPM)** → ch15
- **Discriminative vs. Generative** → ch01
- **DPO** → ch10
- **ELBO** → ch11, ch15
- **FACS** → ch14
- **FID (Fréchet Inception Distance)** → ch12
- **Fine-tuning** → ch04, ch05, ch09
- **GAN** → ch12, ch13, ch14
- **GloVe** → ch03
- **GPT** → ch04, ch05
- **GQA (Grouped Query Attention)** → ch06
- **Guidance scale** → ch15
- **Guardrails** → ch07
- **Hallucination** → ch07, ch10
- **Human-in-the-loop** → ch08
- **IAF** → ch11
- **InstructGPT** → ch05
- **KL Divergence** → ch05, ch11
- **Knowledge distillation** → ch10
- **KTO** → ch10
- **LangChain** → ch08
- **LangGraph** → ch08
- **LangSmith** → ch08
- **Latent Variable Z** → ch01, ch11, ch15
- **LLaMA** → ch06
- **LoRA** → ch09
- **LSTM** → ch02, ch03
- **Minibatch standard deviation** → ch12
- **Mixtral / MoE** → ch06, ch09
- **Mode collapse** → ch12
- **MTCNN** → ch14
- **Multi-head attention** → ch02, ch04
- **Nash Equilibrium** → ch12
- **Pix2Pix** → ch13, ch14
- **PEFT** → ch09
- **PatchGAN** → ch13
- **PPO** → ch05
- **Progressive GAN** → ch12
- **Prompt engineering** → ch07
- **QLoRA** → ch09
- **Quantization** → ch09
- **RAG** → ch08
- **ReAct** → ch07
- **Reparameterization trick** → ch11
- **RLHF** → ch05
- **RLAIF** → ch10
- **RMSNorm** → ch06
- **RoPE** → ch06
- **Self-attention** → ch04
- **Self-consistency** → ch07
- **SFT** → ch05
- **Skip-gram / Word2Vec** → ch03
- **Stable Diffusion** → ch15
- **SwiGLU** → ch06
- **Temperature** → ch03, ch07, ch15
- **Transformer** → ch02, ch04, ch05, ch06
- **U-Net** → ch13, ch15
- **VAE** → ch11, ch15
- **Vanishing gradient** → ch02
- **Vector database** → ch08
- **Xavier initialization** → ch02
- **Zero-shot prompting** → ch07
- **3DMM** → ch14

## Supporting Files

- [glossary.md](glossary.md) — all key terms with definitions (~80 entries)
- [patterns.md](patterns.md) — all techniques, architectures, and design patterns (~12 patterns)
- [cheatsheet.md](cheatsheet.md) — quick decision rules, parameter guides, diagnostic tables

---

## Scope & Limits

This skill covers the book content only (2nd edition, PyTorch focus). For hands-on implementation in your codebase, combine with project-specific tools. For topics beyond this book (e.g., GPT-4V API specifics, latest Stable Diffusion XL), check official docs or ask the agent directly.
