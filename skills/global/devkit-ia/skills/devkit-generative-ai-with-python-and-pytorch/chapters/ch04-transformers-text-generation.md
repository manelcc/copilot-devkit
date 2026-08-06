# Chapter 4: NLP 2.0: Using Transformers to Generate Text

## Core Idea
Transformers replaced RNNs for NLP by replacing sequential recurrence with self-attention — a mechanism that computes relevance between all pairs of tokens simultaneously, enabling parallelization and capturing long-range dependencies that LSTMs miss. BERT (encoder-only) and GPT (decoder-only) are the two dominant transformer configurations for understanding vs. generation tasks.

## Frameworks Introduced

- **Self-Attention Mechanism**:
  - When to use: any sequence task requiring long-range context modeling.
  - How:
    1. Project input X into Query (Q), Key (K), Value (V) matrices: Q=XW_Q, K=XW_K, V=XW_V
    2. Compute attention scores: A = softmax(QKᵀ / √d_k)
    3. Weighted sum of values: output = A·V
  - √d_k scaling prevents dot products from growing too large (softmax saturation).
  - Multi-head attention: run h parallel attention heads, concatenate → linear project.

- **Positional Encoding**:
  - When to use: always in transformers (attention has no inherent notion of position).
  - How: add sinusoidal encodings PE(pos, 2i) = sin(pos / 10000^(2i/d)) to input embeddings.
  - Learned positional embeddings are an alternative (used in BERT).

- **Encoder-Only (BERT-style)**:
  - When to use: classification, NER, question answering — tasks needing bidirectional context.
  - How: all tokens attend to all other tokens (full bidirectional attention).
  - Pre-training: Masked Language Modeling (MLM) — predict masked tokens; Next Sentence Prediction (NSP).
  - Fine-tuning: add task head on top of [CLS] token or token representations.

- **Decoder-Only (GPT-style)**:
  - When to use: text generation — each token attends only to past tokens (causal/autoregressive).
  - How: masked self-attention (upper-triangular mask prevents attending to future tokens).
  - Generation: sample token t+1 from P(w_t+1 | w_1...w_t), append, repeat.

- **Encoder-Decoder (T5/BART-style)**:
  - When to use: seq2seq tasks — translation, summarization, conditional generation.
  - How: encoder processes input bidirectionally; decoder attends to encoder output + past decoder tokens via cross-attention.

- **NLP Benchmarks**:
  - GLUE / SuperGLUE: multi-task language understanding (classification, inference, similarity)
  - SQuAD: extractive question answering
  - Use to evaluate fine-tuned transformers on standard tasks.

## Key Concepts

- **Self-Attention**: mechanism scoring all pairwise token relationships; O(n²) complexity in sequence length
- **Multi-Head Attention**: h parallel attention heads, each learning different relationship types
- **Positional Encoding**: adds position information to token embeddings (sinusoidal or learned)
- **[CLS] Token**: special BERT token whose final representation encodes the full-sentence meaning
- **Masked Self-Attention**: causal mask preventing decoder from attending to future tokens
- **Cross-Attention**: decoder attending to encoder output; bridge in encoder-decoder architectures
- **MLM (Masked LM)**: BERT pre-training objective — predict randomly masked tokens (15% rate)
- **NSP**: Next Sentence Prediction — BERT pre-training task to model inter-sentence coherence
- **Causal LM**: GPT-style autoregressive objective — predict next token given all prior tokens
- **Fine-tuning**: continue training a pre-trained transformer on a smaller task-specific dataset

## Mental Models

- Think of attention as "looking up relevant context" — for each token, it queries all other tokens and retrieves their values weighted by relevance.
- BERT reads the whole book then answers questions. GPT writes the next word having only read up to the current page.
- Multi-head attention = "look at the sentence through multiple lenses simultaneously" — syntax, coreference, semantics.
- Fine-tuning = "give the expert a 1-day briefing" — the pre-trained weights already understand language; fine-tuning tunes them for your task.

## Anti-patterns

- **Using BERT for generation**: BERT is bidirectional — it sees future tokens during pre-training; this makes it unsuitable for autoregressive generation.
- **Ignoring positional encoding**: transformers without positional encoding treat input as a bag of tokens — word order is lost.
- **Fine-tuning without freezing layers**: for very small datasets, fine-tuning all layers leads to catastrophic forgetting; freeze lower layers first.
- **Long sequences with full attention**: O(n²) memory/compute — use efficient attention variants (Longformer, Flash Attention) for sequences > 1K tokens.

## Code Examples

```python
from transformers import pipeline

# GPT-2 text generation pipeline via Hugging Face
generator = pipeline("text-generation", model="gpt2")
result = generator(
    "The future of generative AI is",
    max_length=100,
    num_return_sequences=3,
    temperature=0.8,
    top_k=50
)
for seq in result:
    print(seq["generated_text"])
```
- **What it demonstrates**: a complete GPT-style generation pipeline in 5 lines via Hugging Face; temperature + top-k control output diversity.

```python
from transformers import BertTokenizer, BertForMaskedLM
import torch

# BERT masked language modeling
tokenizer = BertTokenizer.from_pretrained("bert-base-uncased")
model = BertForMaskedLM.from_pretrained("bert-base-uncased")

inputs = tokenizer("The capital of France is [MASK].", return_tensors="pt")
with torch.no_grad():
    logits = model(**inputs).logits

mask_idx = (inputs.input_ids == tokenizer.mask_token_id).nonzero()[0][1]
predicted_token = tokenizer.decode(logits[0, mask_idx].argmax(-1))
print(predicted_token)  # "paris"
```
- **What it demonstrates**: BERT's MLM head predicts masked tokens using bidirectional context.

## Reference Tables

| Model Type | Attention | Pre-training | Use Cases |
|---|---|---|---|
| BERT (encoder-only) | Bidirectional | MLM + NSP | Classification, QA, NER |
| GPT (decoder-only) | Causal (masked) | Causal LM | Text generation, completion |
| T5/BART (enc-dec) | Bidirectional enc + causal dec + cross-attn | Denoising / seq2seq | Translation, summarization |

| Benchmark | Task Type | Metric |
|---|---|---|
| GLUE / SuperGLUE | Multi-task NLU | Avg accuracy |
| SQuAD 1.1 | Extractive QA | F1, EM |
| WMT | Machine translation | BLEU |

## Worked Example

**Building a GPT-style text generation pipeline with Hugging Face:**

```python
from transformers import GPT2LMHeadModel, GPT2Tokenizer

tokenizer = GPT2Tokenizer.from_pretrained("gpt2")
model = GPT2LMHeadModel.from_pretrained("gpt2")
model.eval()

prompt = "Generative AI is transforming"
inputs = tokenizer(prompt, return_tensors="pt")

# Autoregressive generation: decode 50 new tokens
output_ids = model.generate(
    **inputs,
    max_new_tokens=50,
    do_sample=True,
    temperature=0.8,
    top_k=50,
    pad_token_id=tokenizer.eos_token_id
)
print(tokenizer.decode(output_ids[0], skip_special_tokens=True))
```

Key decisions made:
- `do_sample=True`: uses sampling (not greedy) — more natural output
- `temperature=0.8`: slightly conservative — reduces incoherence
- `top_k=50`: restrict sampling pool to top 50 tokens at each step

## Key Takeaways

1. Self-attention — Attention(Q,K,V) = softmax(QKᵀ/√d_k)·V — is the key operation replacing recurrence in transformers.
2. BERT = bidirectional encoder → understanding tasks. GPT = causal decoder → generation tasks. T5/BART = both → seq2seq tasks.
3. Hugging Face `pipeline` wraps tokenization, model inference, and decoding in a single API — the fastest path to production NLP.
4. Multi-head attention enables the model to simultaneously attend to different types of relationships (syntax, semantics, coreference).
5. O(n²) complexity in sequence length is the transformer's Achilles heel — addressed by efficient attention variants for long documents.

## Connects To

- **Ch 2**: transformer architecture built from attention + FFN blocks introduced in Ch 2
- **Ch 3**: replaces LSTM LM from Ch 3; same decoding strategies apply (temperature, top-k)
- **Ch 5–6**: BERT/GPT are the direct predecessors of modern LLMs (GPT-4, LLaMA)
- **Ch 8**: LangChain wraps transformer pipelines for agentic LLM applications
