# Cheatsheet — Generative AI with Python and PyTorch

## Model Selection Decision Tree

```
What is your task?
├── Generate text
│   ├── Large-scale, aligned → LLM (GPT-4, LLaMA3) + RLHF/DPO
│   ├── Task-specific (classification, QA) → Fine-tune BERT/RoBERTa
│   └── Seq2seq (translation, summarization) → T5 / BART
├── Generate images
│   ├── From text prompt → Stable Diffusion (LDM)
│   ├── Paired image translation → Pix2Pix (U-Net + PatchGAN)
│   ├── Unpaired image translation → CycleGAN
│   ├── Controllable latent space → VAE / β-VAE
│   └── Fast adversarial generation → DC-GAN / Progressive GAN
└── Multimodal → LLaMA-Vision, GPT-4V, Gemini
```

---

## Architecture Decision Rules

| When… | Use… | Because… |
|---|---|---|
| Input has spatial structure (images) | CNN | Weight sharing + translation invariance |
| Input is ordered sequence (text, audio) | Transformer (not LSTM) | Parallelizable; captures full context |
| Need structured latent space | VAE | ELBO forces continuous, navigable latent |
| Need sharp, diverse images | GAN / Diffusion | Implicit distribution; adversarial sharpness |
| Need text-conditioned images | Stable Diffusion | CLIP + latent diffusion |
| Long-range dependencies matter | Transformer | Self-attention attends across full context |
| Very limited GPU (< 24GB) | QLoRA | 4-bit base + LoRA adapters |

---

## LLM Training Stage Thresholds

| Stage | When to stop here | Typical cost |
|---|---|---|
| Base LM (pre-training) | General language capability sufficient | $10M–$100M |
| SFT (instruction tuning) | Model follows instructions reasonably | $10K–$100K |
| RLHF / DPO | Alignment to human preferences needed | $1K–$50K |
| LoRA fine-tune | Domain adaptation with limited data | $10–$1K |
| RAG | Knowledge injection without behavior change | ~$0 (inference cost) |

**Chinchilla rule**: 20 tokens per parameter = compute-optimal. More parameters but fewer tokens = wasteful.

---

## PEFT Method Quick Selection

| Dataset size | GPU budget | Recommended |
|---|---|---|
| < 1K samples | Any | Prompt tuning |
| 1K–50K samples | ≥ 40GB | LoRA (r=8–16) |
| 1K–50K samples | < 24GB | QLoRA (r=16–64, 4-bit) |
| > 50K samples, small model | Any | Full fine-tuning |

**LoRA rank guide**: r=4 (very fast); r=8 (default); r=16–32 (complex tasks); r=64 (diminishing returns).  
**lora_alpha rule**: alpha = 2×r (e.g., r=16 → alpha=32) gives stable scaling.

---

## Prompt Engineering Decision Rules

| Symptom | Fix |
|---|---|
| Wrong format or length | Add explicit format instruction ("Respond in 3 bullet points") |
| Wrong style or domain | Add system instruction ("You are a senior Python engineer…") |
| Inconsistent quality | Add few-shot examples (2–5) |
| Multi-step reasoning fails | Add "Let's think step by step." (zero-shot CoT) |
| Tool use required | Use ReAct pattern: Thought → Action → Observation |
| High variance in answers | Self-consistency: sample 5×, majority vote |
| Hallucination in factual tasks | Add RAG context; lower temperature; add "only use the provided context" |

**Temperature guide**:
- T = 0.0–0.3: factual, code, deterministic tasks
- T = 0.5–0.8: balanced; most chat use cases
- T = 0.9–1.2: creative writing, poetry, brainstorming
- T > 1.5: usually incoherent — avoid

---

## GAN Training Diagnostic Tells

| Symptom | Diagnosis | Fix |
|---|---|---|
| D loss = 0, G loss = high | D too strong; G can't learn | Reduce D steps; add noise to real labels |
| G loss = 0, D loss = high | G collapsed (all outputs same) | Mode collapse; add minibatch std dev |
| Both losses oscillate | Training instability | Use gradient penalty or progressive growth |
| FID high despite low losses | Loss not informative | FID is the truth — use it, not BCE loss |
| G outputs all the same image | Mode collapse | Minibatch std dev; feature matching loss |

**FID thresholds**: < 10 = excellent; 10–30 = good; 30–100 = moderate; > 100 = poor.

---

## VAE Diagnostic Rules

| Symptom | Diagnosis | Fix |
|---|---|---|
| Blurry outputs, low KL loss | β too low; KL not enforcing structure | Increase β (try 4) |
| Very low reconstruction + high KL | β too high; posterior collapsed | Decrease β |
| Same z → very different outputs | Latent space not smooth | Increase KL weight; check reparameterization |
| Interpolation produces artifacts | Encoder not mapping to N(0,I) | Increase KL weight; more training |
| Can't disentangle factors | β=1 VAE insufficient | Use β-VAE (β=4–10) |

**ELBO formula**: ELBO = E[log P(x|z)] − KL(q(z|x)||N(0,I)). Both terms must improve together.

---

## Stable Diffusion Parameter Guide

| Parameter | Range | Rule |
|---|---|---|
| guidance_scale | 7–12 | 7.5 default; ↑ for better prompt adherence; >15 → artifacts |
| num_inference_steps | 20–50 | 50 for quality; 20 for speed (DDIM scheduler) |
| height/width | 512 (SD 1.x), 768 (SD XL) | Must be multiples of 64 |
| negative_prompt | Any text | Always include: "blurry, low quality, distorted, watermark" |
| seed | Any int | Fix for reproducible outputs during prompt iteration |
| scheduler | DDIM/PNDM | DDIM: fewer steps + deterministic; PNDM: stable default |

---

## Decoding Parameter Quick Reference

| Strategy | Parameters | Best for |
|---|---|---|
| Greedy | temperature=0, top_k=1 | Deterministic; factual tasks |
| Sampling | temperature=0.8, top_k=50 | General generation |
| Nucleus (top-p) | temperature=0.8, top_p=0.9 | Creative; controls diversity by probability mass |
| Beam search | num_beams=4–8 | High-quality deterministic text (translation, summarization) |
| Self-consistency | n=5, majority vote | Reasoning tasks; most reliable at cost of 5× compute |

---

## Open-Source LLM Selection Guide

| Need | Recommended | Why |
|---|---|---|
| Best open quality (general) | LLaMA3-70B | Best open-source benchmark performance |
| Fast inference, limited GPU | LLaMA3-8B | Competitive quality at 8B |
| High quality at low compute | Mixtral 8×7B | 46.7B params, 13B active (MoE) |
| Commercial use, simple setup | Dolly 2.0 | Apache 2.0 license; instruction-tuned |
| Research/reproducibility | LLaMA3-8B | Meta usage agreement + full weights |
| Coding tasks | LLaMA3-8B-Instruct | Best open pass@1 on HumanEval among 8B class |

**Evaluation order**: HellaSwag (reasoning) + MMLU (knowledge) + HumanEval (coding). Don't rely on a single benchmark.

---

## LangChain LCEL Composition Templates

```python
# Simple chain
chain = prompt | model | StrOutputParser()
result = chain.invoke({"topic": "attention mechanism"})

# RAG chain  
retrieval_chain = {"context": retriever, "question": RunnablePassthrough()} | prompt | model | parser

# Streaming
for chunk in chain.stream({"input": "explain VAEs"}):
    print(chunk, end="", flush=True)
```

**LangSmith**: set `LANGCHAIN_TRACING=true` before development — traces are invaluable for debugging multi-step chains.
