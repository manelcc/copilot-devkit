# Patterns — Generative AI with Python and PyTorch

## Pattern: Generative Model Selection

**When to use**: deciding which generative architecture to apply to a problem.

**How**:
- Text generation at scale → **LLM (GPT-style decoder-only)**
- Text understanding / classification → **BERT (encoder-only)**
- Seq2seq (translation, summarization) → **T5/BART (encoder-decoder)**
- High-fidelity image generation → **Stable Diffusion / LDM**
- Controlled image-to-image translation (paired) → **Pix2Pix**
- Unpaired image-to-image translation → **CycleGAN**
- Image generation with explicit latent space → **VAE**
- Real-time image generation with fine control → **GAN**

**Trade-offs**: GANs: sharp images, training instability. VAEs: stable training, blurrier outputs. Diffusion: best quality, slow inference. LLMs: universal text; high compute.

---

## Pattern: LLM Training Pipeline (Three-Stage Recipe)

**When to use**: training an aligned LLM from scratch or adapting a base model.

**How**:
1. **Pre-training**: causal LM objective on internet-scale data (trillions of tokens). Learns language structure and world knowledge.
2. **Supervised Fine-Tuning (SFT / Instruction Tuning)**: curate (instruction, response) demonstration pairs. Fine-tune with standard causal LM loss.
3. **RLHF/DPO/KTO**: align model behavior with human preferences. PPO + reward model (RLHF) or direct preference optimization (DPO) or binary feedback (KTO).

**Trade-offs**: each stage is progressively cheaper in compute. RLHF requires human annotation; DPO simpler but needs pairwise data; KTO only needs binary labels.

---

## Pattern: PEFT Fine-Tuning Decision Tree

**When to use**: fine-tuning a large pre-trained LLM with limited GPU resources.

**How**:
- Need maximum efficiency, don't care about fine-grained control → **Prompt Tuning** (0.002% params, add virtual tokens)
- Standard fine-tuning for most tasks → **LoRA** (r=8–64; trains 0.5–3% of params; merges back with zero overhead)
- Large model (7B+), limited VRAM (< 24GB) → **QLoRA** (LoRA + 4-bit NF4 base model via bitsandbytes)
- Full representational power needed, data > 10K → **Full Fine-tuning** (100% params; use only for small models)

**Trade-offs**: LoRA is the practical default. QLoRA extends it to very large models on consumer hardware.

---

## Pattern: RAG Pipeline

**When to use**: LLM needs to answer from specific documents without full fine-tuning; knowledge is frequently updated.

**How**:
1. **Load**: ingest documents (PDF, HTML, code, etc.)
2. **Split**: `RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=200)`
3. **Embed**: encode chunks with an embedding model (MistralAIEmbeddings, FastEmbed, OpenAI)
4. **Store**: add embeddings to a vector store (InMemoryVectorStore, Chroma, Pinecone, Weaviate)
5. **Retrieve**: `vector_store.similarity_search(query, k=4)` → top-k relevant chunks
6. **Generate**: prepend retrieved chunks to prompt → LLM generates grounded response

**Trade-offs**: chunk_overlap too low → context loss at boundaries; too high → redundant retrieval. RAG for knowledge; fine-tuning for behavior/style.

---

## Pattern: LangGraph Stateful Agent

**When to use**: multi-step LLM application requiring branching logic, memory, tool use, or human-in-the-loop.

**How**:
```python
from langgraph.graph import StateGraph, START, END
from langgraph.checkpoint.memory import MemorySaver

class State(TypedDict):
    messages: Annotated[list, add_messages]
    context: list

graph_builder = StateGraph(State)
graph_builder.add_node("retrieve", retrieve_fn)
graph_builder.add_node("generate", generate_fn)
graph_builder.add_edge(START, "retrieve")
graph_builder.add_edge("retrieve", "generate")
graph_builder.add_edge("generate", END)

graph = graph_builder.compile(checkpointer=MemorySaver())
config = {"configurable": {"thread_id": "user-123"}}
result = graph.invoke({"messages": user_input}, config)
```
**Trade-offs**: LangGraph is stateful and explicit; simpler chains don't need it. Use for complex workflows only.

---

## Pattern: GAN Training Loop

**When to use**: training any GAN variant (DC-GAN, Conditional GAN, Pix2Pix).

**How** (alternating optimization):
1. **Train Discriminator**: feed real + generated batches; compute D's loss; backward + step optimizer_D.
2. **Train Generator**: generate new batch; pass through D; compute G's loss (non-saturating: maximize log D(G(z))); backward + step optimizer_G.
3. **Monitor**: use FID score (not D/G loss values) to track quality. FID < 30 = good; FID > 100 = poor.

**Trade-offs**: training instability = the core GAN challenge. Progressive GAN + minibatch std dev mitigate it. Mode collapse → add diversity techniques.

---

## Pattern: VAE ELBO Training

**When to use**: training a Variational Autoencoder for image generation or structured latent learning.

**How**:
```python
def vae_loss(recon_x, x, mu, logvar, beta=1.0):
    recon_loss = F.binary_cross_entropy(recon_x, x, reduction='sum')
    kl_loss = -0.5 * torch.sum(1 + logvar - mu.pow(2) - logvar.exp())
    return recon_loss + beta * kl_loss
```
- beta=1: standard VAE
- beta=4–10: β-VAE (disentangled representations)

**Trade-offs**: high β → better disentanglement but worse reconstruction. The reparameterization trick (z = μ + σ·ε) is mandatory for backprop through the sampling step.

---

## Pattern: Prompt Engineering Escalation

**When to use**: improving LLM output quality without changing model weights.

**How** (escalation order):
1. **Clear + specific** zero-shot: explicit instruction + output format hint + delimiter around context.
2. **Few-shot**: add 2–5 (input, output) examples before the actual query.
3. **Zero-shot CoT**: append "Let's think step by step." for reasoning tasks.
4. **Few-shot CoT**: provide worked reasoning examples showing the thinking steps.
5. **ReAct**: for tool-use tasks; interleave Thought → Action → Observation.
6. **Self-consistency**: sample k times (T=0.7), take majority vote.

**Trade-offs**: each level adds latency and cost. Start at level 1 and escalate only when needed.

---

## Pattern: Decoding Strategy Selection

**When to use**: choosing how to sample from a language model at inference.

**How**:
| Task | Strategy | Settings |
|---|---|---|
| Factual/deterministic | Greedy or beam search | T=0, top_k=1 |
| Creative writing | Sampling | T=0.8–1.2, top_k=50 |
| Code generation | Top-p + low temperature | T=0.2, top_p=0.95 |
| Balanced generation | Top-k sampling | T=0.7, top_k=50 |
| Reliable reasoning | Self-consistency | Sample 5×, majority vote |

**Trade-offs**: greedy = consistent but degenerate. Pure sampling = diverse but potentially incoherent. Top-k = practical sweet spot.

---

## Pattern: Stable Diffusion Text-to-Image

**When to use**: generating images from text prompts using a pre-trained diffusion model.

**How**:
```python
pipe = StableDiffusionPipeline.from_pretrained("runwayml/stable-diffusion-v1-5",
    torch_dtype=torch.float16).to("cuda")

result = pipe(
    prompt="your subject and style description",
    negative_prompt="blurry, low quality, distorted, watermark",
    num_inference_steps=50,  # quality/speed tradeoff
    guidance_scale=7.5,      # prompt adherence (7-12 typical)
    height=512, width=512,   # multiples of 64 only
    generator=torch.Generator("cuda").manual_seed(42)  # reproducibility
)
```

**Trade-offs**: more inference steps → better quality but slower. Higher guidance scale → more prompt-faithful but less diverse.

---

## Pattern: Deepfake Re-enactment Pipeline

**When to use**: transferring facial expressions from one video to another using Pix2Pix.

**How**:
1. Detect faces + landmarks in source and target videos (MTCNN or Dlib 68-pt).
2. Draw landmark skeleton on blank canvas for each frame → (landmark_image, face_image) pairs.
3. Train Pix2Pix: G(landmark_image) → face_image; D classifies (landmark, face) pairs.
4. At inference: extract source landmarks → feed to trained G → blend output back onto target frame.
5. Apply temporal smoothing (exponential moving average on landmarks) to prevent flickering.

**Trade-offs**: works best for frontal faces with moderate expression change; fails with >30° head rotation or occlusions.

---

## Pattern: Scaling Law Compute Budget Allocation (Chinchilla)

**When to use**: deciding model size and training dataset size given a fixed compute budget C.

**How**:
- Optimal model size: N ≈ √(C / 6)
- Optimal training tokens: D ≈ √(C × 6)
- Rule of thumb: ~20 tokens per parameter for compute-optimal training.
- Example: for C = 10²³ FLOP → N ≈ 70B parameters, D ≈ 1.4T tokens (Chinchilla setup).

**Trade-offs**: most published LLMs are undertrained (too many parameters, too few tokens). Smaller model + more data often wins over larger model + less data at same compute cost.
