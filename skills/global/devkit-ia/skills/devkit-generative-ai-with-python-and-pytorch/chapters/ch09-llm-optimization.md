# Chapter 9: LLM Optimization Techniques

## Core Idea
Training and serving LLMs at scale is prohibitively expensive ($11M+ for LLaMA3.1-405B on A100s). This chapter covers the full optimization stack: scaling laws to right-size models, PEFT techniques (LoRA, QLoRA, prompt tuning) to fine-tune with minimal parameters, and inference optimizations (quantization, MoE, efficient attention) to deploy at practical cost.

## Frameworks Introduced

- **Scaling Laws (Kaplan et al., 2020 / Chinchilla / Hoffmann et al., 2022)**:
  - Model performance depends on N (parameters), D (dataset size), and C (compute).
  - Kaplan: every 8× increase in model size → only 5× more data needed.
  - **Chinchilla insight**: most LLMs are undertrained — optimal is N parameters trained on ~20×N tokens.
  - Decision rule: when budget is fixed, prefer smaller model + larger dataset over larger model + smaller dataset.

- **PEFT (Parameter-Efficient Fine-Tuning)**:
  - When to use: fine-tuning a large LLM with limited GPU budget; prevents catastrophic forgetting.
  - Category 1 — **Additive PEFT**: add new trainable parameters, freeze base model.
  - Category 2 — **Reparameterization PEFT (LoRA)**: inject low-rank update matrices.
  - Category 3 — **Selective PEFT**: selectively unfreeze specific layers.

- **Prompt Tuning (Soft Prompting)**:
  - When to use: lowest compute cost PEFT; multi-task settings.
  - How: prepend learnable virtual tokens to input embeddings; only virtual tokens are trained (0.002% of parameters).
  - Trade-off: less flexible than LoRA; works best for classification/generation with clear task definition.

- **LoRA (Low-Rank Adaptation)**:
  - When to use: fine-tuning large LLMs with minimal GPU memory; standard go-to PEFT method.
  - How: for weight matrix W, compute update ΔW = A·B where A ∈ ℝ^{d×r}, B ∈ ℝ^{r×k}, r << min(d,k).
  - Only A and B are trained (r×(d+k) parameters vs. d×k); original W stays frozen.
  - Key hyperparameters: r (rank, typically 4–64), lora_alpha (scaling factor), lora_dropout.
  - At inference: merge W + α/r × A·B back into original weight — zero inference overhead.

- **QLoRA (Quantized LoRA)**:
  - When to use: fine-tuning large models (7B+) on consumer GPUs (24GB VRAM or less).
  - How: load base model in 4-bit NF4 quantization (bitsandbytes) → add LoRA adapters in bfloat16.
  - Result: fine-tune a 7B model on a single A100; 65B on a 2×A100 setup.

- **Quantization**:
  - When to use: inference optimization — reduces model size 4–8× with minimal accuracy loss.
  - How: convert FP32/BF16 weights → INT8 or INT4 representations.
  - Types: post-training quantization (PTQ, no retraining) vs. quantization-aware training (QAT).
  - GGUF format: CPU-friendly quantized LLM format used by llama.cpp / Ollama.

## Key Concepts

- **N, D, C (Scaling Law variables)**: parameters, dataset size, compute — the three axes of LLM performance
- **Chinchilla optimal**: N parameters trained on ~20·N tokens for compute-optimal training
- **PEFT**: fine-tune <1% of parameters while achieving comparable performance to full fine-tuning
- **LoRA rank r**: bottleneck dimension of the low-rank update; r=8–64 covers most tasks
- **lora_alpha**: scaling factor for LoRA updates; effective learning rate scales with alpha/r
- **NF4 quantization**: 4-bit Normal Float — optimal for normally distributed weights; used in QLoRA
- **double_quant**: quantize the quantization constants themselves for additional memory savings
- **Linformer**: efficient attention variant that inspired LoRA; approximates full attention matrix with low-rank projection
- **MoE (Mixture of Experts)**: sparse routing — only k of N expert FFN blocks activated per token; Gemini 1.5, Mixtral
- **Flash Attention**: IO-aware attention algorithm; reads/writes HBM memory efficiently; reduces memory from O(n²) to O(n)

## Mental Models

- LoRA intuition: "fine-tuning doesn't change the full matrix, it adds a low-rank correction" — most of the weight update lives in a low-dimensional subspace.
- Chinchilla: "a smaller model trained longer beats a larger model undertrained" — compute budget matters more than raw parameter count.
- QLoRA: "compress the freezer, fine-tune the fridge" — load the frozen base model in 4-bit; train only the LoRA adapters at full precision.
- Quantization trade-off: INT4 uses 4× less memory than FP16 but loses ~1-2% accuracy on benchmarks; often worthwhile for inference.

## Anti-patterns

- **Fine-tuning all layers for small datasets**: catastrophic forgetting; use LoRA with r=8–16 instead.
- **Setting LoRA rank too high (r=256+)**: diminishing returns; training more parameters defeats the purpose of PEFT.
- **Ignoring Chinchilla scaling**: training a 70B model on 1T tokens is less compute-efficient than a 35B on 1.4T tokens.
- **PTQ without validation**: post-training quantization can silently degrade accuracy on specific tasks; always evaluate the quantized model.

## Code Examples

```python
from peft import LoraConfig, get_peft_model
from transformers import BitsAndBytesConfig, AutoModelForCausalLM
import torch

# QLoRA setup: 4-bit base model + LoRA adapters
bnb_config = BitsAndBytesConfig(
    load_in_4bit=True,
    bnb_4bit_quant_type="nf4",          # NF4: best for normally distributed weights
    bnb_4bit_compute_dtype=torch.bfloat16,
    bnb_4bit_use_double_quant=True,     # quantize the quantization constants
    bnb_4bit_quant_storage=torch.bfloat16
)

lora_config = LoraConfig(
    r=64,           # rank: bottleneck dim of low-rank update
    lora_alpha=16,  # scaling: effective update = alpha/r × A·B
    lora_dropout=0.1,
    bias="none",
    task_type="CAUSAL_LM"
)

model = AutoModelForCausalLM.from_pretrained(
    "meta-llama/Llama-3.2-1B",
    quantization_config=bnb_config,
    device_map="auto"
)
model = get_peft_model(model, lora_config)
model.print_trainable_parameters()
# trainable params: ~33M || all params: 1B || trainable%: ~3%
```
- **What it demonstrates**: QLoRA pipeline — loads LLaMA in 4-bit NF4, wraps with LoRA adapters. Only ~3% of parameters train.

```python
from peft import PromptTuningConfig, PromptTuningInit, get_peft_model

# Soft prompting: 0.002% of parameters trained
peft_config = PromptTuningConfig(
    task_type="CAUSAL_LM",
    prompt_tuning_init=PromptTuningInit.TEXT,
    num_virtual_tokens=20,
    prompt_tuning_init_text="Classify if the user_input is toxic or non toxic.\n",
    tokenizer_name_or_path=MODEL,
)
soft_model = get_peft_model(base_model, peft_config)
soft_model.print_trainable_parameters()
# trainable params: 12,288 || all params: 559,226,880 || trainable%: 0.0022
```
- **What it demonstrates**: prompt tuning — 12,288 parameters trained vs 559M frozen; lowest compute PEFT option.

## Reference Tables

| PEFT Method | Trainable Params | Compute | Best For |
|---|---|---|---|
| Prompt Tuning | ~0.002% | Minimal | Multi-task classification |
| LoRA (r=16) | ~0.5–2% | Low | Most fine-tuning tasks |
| QLoRA (r=64, 4-bit) | ~1–3% | Low (small GPU) | Large models on consumer hardware |
| Full Fine-tuning | 100% | High | Small models, large datasets |

| Quantization | Bits | Memory vs FP16 | Accuracy Loss |
|---|---|---|---|
| FP16 / BF16 | 16 | 1× | None |
| INT8 | 8 | 2× | ~0.5% |
| NF4 (QLoRA) | 4 | 4× | ~1–2% |

## Worked Example

**Cost calculation for LLaMA3.1-405B training:**
```
Parameters: 405B
Dataset: 15T tokens
FLOPS required = 405e9 × 15e12 × 1 = 6.075e24 FLOPs

A100 GPU (80GB):
  - Peak FLOPS: 312 TFLOPS (bfloat16)
  - GPU efficiency: 25% (realistic multi-GPU)
  - Effective FLOPS: 78 TFLOPS

GPU hours = 6.075e24 / (78e12 × 3600) ≈ 1.08e7 GPU-hours
Cost at $1.10/GPU-hour → ~$11.9M
```
Chinchilla comparison: A 200B model trained on 4T tokens (Chinchilla-optimal ratio) achieves equivalent performance at ~60% of the compute cost.

## Key Takeaways

1. Chinchilla scaling law: optimal compute allocation favors smaller models + larger datasets over larger models + smaller datasets.
2. LoRA trains only A and B (low-rank update matrices); original weights stay frozen; zero inference overhead after merging.
3. QLoRA = LoRA + 4-bit NF4 quantization — fine-tune 7B+ models on a single GPU with <24GB VRAM.
4. Prompt tuning (0.002% trainable params) is the most compute-efficient PEFT; LoRA (0.5–2%) provides better flexibility.
5. Quantization (INT8/INT4) reduces serving memory 2–4× with 0.5–2% accuracy trade-off — usually worthwhile for inference.

## Connects To

- **Ch 5**: RLHF fine-tuning from Ch 5 can be made efficient with LoRA/QLoRA
- **Ch 6**: open-source LLMs (LLaMA) are the primary targets for these optimization techniques
- **Ch 10**: LoRA-optimized models underpin the efficient serving of models in emerging applications
- **Ch 4**: Flash Attention is an efficiency improvement to the self-attention mechanism from Ch 4
