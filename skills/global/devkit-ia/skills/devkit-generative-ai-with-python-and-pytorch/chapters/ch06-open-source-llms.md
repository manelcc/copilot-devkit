# Chapter 6: Open-Source LLMs

## Core Idea
Open-source LLMs (LLaMA, Falcon, Mixtral, Dolly, Grok-1) expose the full model weights and architectural details that proprietary models hide, enabling independent analysis, fine-tuning, and on-premise deployment. LLaMA3 demonstrates that dataset quality and architectural improvements (RMSNorm, RoPE, GQA, SwiGLU) can achieve competitive performance vs. closed models at a fraction of the parameter count.

## Frameworks Introduced

- **LLaMA Architecture (Meta)**:
  - Decoder-only transformer with 4 key improvements over vanilla GPT:
    1. **RMSNorm on inputs** (not outputs): more efficient normalization, better gradient control
    2. **RoPE (Rotary Positional Embeddings)**: relative position via inner products; efficient to compute; extrapolates to longer sequences
    3. **SwiGLU activation**: gated linear unit variant outperforming ReLU/GELU in LLM benchmarks
    4. **Grouped Query Attention (GQA)**: queries grouped to share fewer key/value heads → faster inference, less memory
  - Open training data: CommonCrawl, Wikipedia, ArXiv, StackExchange
  - Sizes: 7B, 13B, 70B parameters (LLaMA3: 8B, 70B)

- **Grouped Query Attention (GQA)**:
  - Problem: standard multi-head attention (MHA) scales compute/memory with h² heads.
  - MQA (Multi-Query Attention): all queries share 1 key/value head — fast but less expressive.
  - GQA: groups of queries share key/value heads — balanced trade-off. Used in LLaMA2/3.
  - When to prefer GQA: inference-critical deployments where KV-cache memory is the bottleneck.

- **Evaluation Benchmarks**:
  - **HellaSwag**: common-sense reasoning (sentence completion)
  - **MMLU**: broad language/knowledge understanding (57 tasks)
  - **HumanEval**: functional code generation (pass@k metric)
  - When to use: always evaluate open-source LLMs on these before deploying.

- **Mixtral 8×7B (Mixture of Experts)**:
  - Architecture: 8 expert FFN blocks per layer; each token is routed to only 2 experts.
  - Effect: 46.7B total parameters but only 13B active per forward pass → matches 70B performance at 13B compute cost.
  - When to use: when you need high quality at inference-time compute constraints.

## Key Concepts

- **RMSNorm**: Root Mean Square normalization — normalizes by RMS, not mean+variance; faster, simpler than LayerNorm
- **RoPE**: Rotary Position Embeddings — encodes relative positions via rotation of Q/K vectors; better extrapolation than sinusoidal
- **SwiGLU**: SiLU gated linear unit — SwiGLU(x, W, V, b, c) = Swish(xW+b) ⊙ (xV+c); replaces standard FFN MLP in LLaMA
- **GQA**: Grouped Query Attention — m query groups per n total heads (MHA: m=n; MQA: m=1; GQA: 1<m<n)
- **KV-Cache**: stores key and value tensors for all past tokens during autoregressive generation; GQA reduces its size
- **Mixtral / MoE**: Mixture of Experts — only a subset of parameters active per token; scale model capacity without proportional compute
- **Dolly**: Databricks open-source LLM instruction-tuned on crowd-sourced Dolly-15k dataset; first fully open commercial-use LLM
- **Grok-1**: 314B parameter MoE model open-sourced by xAI (Elon Musk); largest openly released LLM as of 2024
- **HumanEval pass@k**: probability that at least 1 of k generated code samples passes unit tests; standard coding benchmark
- **HellaSwag score**: % correct sentence completions out of 10K/20K challenge questions

## Mental Models

- Think of GQA as "office hot-desking" — many query workers share fewer key/value desks, reducing space while barely reducing throughput.
- MoE = "specialist consultants" — route each token to its 2 best experts rather than asking all 46.7B parameters to process every token.
- Open-source ≠ free performance — LLaMA's biggest gains in LLaMA3 came from better dataset curation, not architecture changes.
- Prefer **LLaMA** for research/fine-tuning (rich ecosystem); **Mixtral** for production quality under compute constraints; **Dolly** for commercial use with minimal resources.

## Anti-patterns

- **Using a 70B model when 7B suffices**: LLaMA3-8B handles most NLP tasks; only upgrade for reasoning-heavy or multi-step tasks.
- **Not checking HumanEval pass@k for code tasks**: accuracy-style benchmarks don't predict code generation quality.
- **Ignoring license terms**: LLaMA models require accepting Meta's usage agreement; verify before commercial deployment.
- **Running full-precision 70B models without quantization**: requires ~140GB VRAM; use bfloat16 or GGUF 4-bit quantization for practical inference.

## Code Examples

```python
import transformers
import torch

# Load LLaMA3 8B via Hugging Face (requires HF token and model access approval)
model_id = "meta-llama/Meta-Llama-3-8B"
pipeline = transformers.pipeline(
    "text-generation",
    model=model_id,
    model_kwargs={"torch_dtype": torch.bfloat16},
    device_map="auto"  # auto-distributes across available GPUs
)

# Inspect model architecture
print(pipeline.model)
# LlamaForCausalLM: 32 layers, 4096-dim, 128256-token vocab
# Each layer: LlamaSdpaAttention (q: 4096, k: 1024, v: 1024) + LlamaMLP + RMSNorm
```
- **What it demonstrates**: loading LLaMA3 in bfloat16 with device_map="auto" for multi-GPU inference; output shows GQA (k/v projection smaller than q).

## Reference Tables

| Model | Params | Architecture | Key Innovation | License |
|---|---|---|---|---|
| LLaMA3 | 8B / 70B | Decoder-only | GQA + RoPE + SwiGLU + RMSNorm | Meta usage agreement |
| Mixtral 8×7B | 46.7B (13B active) | MoE decoder | Sparse expert routing | Apache 2.0 |
| Falcon2 | 11B | Decoder-only | Multi-query attention | Apache 2.0 |
| Dolly 2.0 | 12B | Decoder-only | Dolly-15k instruction tuning | Open (commercial) |
| Grok-1 | 314B | MoE | Largest open MoE | Apache 2.0 |

| Benchmark | Tests | Key Metric |
|---|---|---|
| HellaSwag | Common-sense reasoning | Accuracy % |
| MMLU | 57 academic subjects | Accuracy % |
| HumanEval | Python coding tasks | pass@k |

## Worked Example

**LLaMA3 8B on HumanEval (coding benchmark):**
```python
# HumanEval problem: implement a function that checks if a number is prime
prompt = '''
def is_prime(n: int) -> bool:
    """Return True if n is prime, False otherwise.
    >>> is_prime(6)
    False
    >>> is_prime(101)
    True
    """
'''
output = pipeline(prompt, max_new_tokens=150)[0]["generated_text"]
# Model completes the function body
# pass@1 measures if the first attempt passes the doctest
```
LLaMA3-8B achieves ~62% pass@1 on HumanEval — competitive with GPT-3.5-level coding ability at open-source weights.

## Key Takeaways

1. Open-source LLMs (LLaMA, Mixtral, Dolly) provide full weight access for fine-tuning, auditing, and on-premise deployment — critical for privacy-sensitive applications.
2. LLaMA3's key architectural improvements: RMSNorm + RoPE + SwiGLU + GQA — each addresses a specific bottleneck in the vanilla transformer.
3. GQA reduces KV-cache memory proportionally to the group size — critical for long-context inference.
4. Mixture of Experts (Mixtral) scales model capacity without proportional compute cost — 46.7B parameters, only 13B active.
5. Evaluate on HellaSwag + MMLU + HumanEval before selecting an open-source LLM for a task — benchmark numbers are not interchangeable.

## Connects To

- **Ch 4**: transformer architecture is the backbone of all models here
- **Ch 5**: same RLHF/instruction-tuning training paradigm applies to all open-source LLMs
- **Ch 7**: prompt engineering works the same way with open-source models via Ollama/Hugging Face
- **Ch 9**: quantization and efficient inference (LoRA, GGUF) reduce the cost of running these models
