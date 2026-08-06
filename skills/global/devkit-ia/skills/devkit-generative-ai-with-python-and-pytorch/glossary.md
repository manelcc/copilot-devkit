# Glossary — Generative AI with Python and PyTorch

**Action Units (AUs)** — FACS building blocks for describing facial expressions; e.g., AU1+AU4+AU15 = sad; 44 AUs cover all possible human facial movements (Ch 14)

**Additive PEFT** — PEFT category that adds new trainable parameters (e.g., virtual tokens, adapters) while freezing the base model (Ch 9)

**AdaGrad** — adaptive gradient optimizer; early predecessor to ADAM (Ch 2)

**ADAM** — Adaptive Momentum Estimation optimizer; uses first (momentum) and second (variance) moment estimates for adaptive per-parameter learning rates; default for most deep generative models (Ch 2)

**Alignment** — ensuring LLM outputs match user intent and human values: helpful, harmless, and honest (Ch 5, Ch 10)

**Attention Mechanism** — computes relevance scores between all token pairs simultaneously; Attention(Q,K,V) = softmax(QKᵀ/√d_k)·V (Ch 4)

**Autoencoder** — encoder-decoder network that compresses input to a low-dimensional code then reconstructs it; basis of VAEs (Ch 11)

**Autoregressive Generation** — generate token t+1 by sampling from P(w_{t+1} | w_1...w_t); how GPT-style models produce text (Ch 3, Ch 4)

**Backpropagation** — algorithm computing gradients via chain rule through the computational graph; basis of all neural network training (Ch 2)

**Bag of Words (BoW)** — sparse vector representing text as counts or TF-IDF weights over a fixed vocabulary; loses word order (Ch 3)

**BatchNorm** — Batch Normalization; normalizes layer outputs across the batch to stabilize training (Ch 2)

**Bayes' Theorem** — P(Y|X) = P(X|Y)·P(Y) / P(X); the formal connection between discriminative and generative modeling (Ch 1)

**BERT** — Bidirectional Encoder Representations from Transformers; encoder-only transformer pre-trained with MLM + NSP; for understanding tasks (Ch 4)

**β-VAE** — VAE with β > 1 on the KL term; enforces better-disentangled latent representations at cost of reconstruction quality (Ch 11)

**BPE (Byte Pair Encoding)** — tokenization algorithm iteratively replacing common byte pairs with new tokens; used in CLIP, GPT tokenizers (Ch 15)

**CBOW (Continuous Bag of Words)** — Word2Vec variant; predicts center word from context window; better for frequent words (Ch 3)

**Causal LM** — GPT-style autoregressive training objective; predict next token given all prior tokens; masked self-attention (Ch 4)

**Chain-of-Thought (CoT) Prompting** — prompting technique adding "Let's think step by step" to elicit intermediate reasoning; improves multi-step tasks (Ch 7)

**Character-level LM** — language model operating at the character level; no OOV problem; trained with cross-entropy + LSTM (Ch 3)

**Chinchilla** — DeepMind model demonstrating that LLMs are undertrained; optimal ratio ≈ 20 tokens per parameter (Ch 9)

**Classifier-Free Guidance (CFG)** — diffusion model technique controlling prompt adherence: ε_guided = ε_uncond + scale × (ε_cond - ε_uncond) (Ch 15)

**CLIP** — Contrastive Language-Image Pre-training; joint image-text embedding; enables text-conditioned image generation in Stable Diffusion (Ch 15)

**CNN (Convolutional Neural Network)** — spatial data architecture with learned filters, weight sharing, and local receptive fields; basis of GAN generators/discriminators (Ch 2)

**Conditional GAN (cGAN)** — GAN conditioned on a label y; G(z,y) generates images of a specific class (Ch 12)

**Context Window** — maximum tokens the LLM can attend to in one call; GPT-4 = 128K; LLaMA3 = 8K–128K (Ch 5)

**CycleGAN** — unpaired image-to-image translation using two generators and cycle consistency loss (Ch 13)

**Cycle Consistency Loss** — G_{B→A}(G_{A→B}(x)) ≈ x; the constraint enabling CycleGAN without paired data (Ch 13)

**DC-GAN (Deep Convolutional GAN)** — GAN with CNN generator (ConvTranspose2d) and discriminator (Conv2d + BatchNorm + LeakyReLU) (Ch 12)

**DDPM** — Denoising Diffusion Probabilistic Models; train U-Net to predict noise ε at each step of a Markov noising process (Ch 15)

**Deepfake** — AI-generated synthetic media convincingly replacing a person's appearance, voice, or behavior (Ch 14)

**Decoding Strategy** — method for selecting the next token during generation: greedy, beam search, sampling, top-k (Ch 3)

**Delimiter** — marker (```, """, ###) separating instructions from context in a prompt; protects against prompt injection (Ch 7)

**Dense Representation** — low-dimensional embedding (Word2Vec, GloVe, FastText) where every dimension is non-zero (Ch 3)

**Discriminator D** — GAN component that classifies real vs. fake samples; drives generator improvement (Ch 12)

**Disentangled Representation** — latent space where each dimension independently controls one interpretable factor (Ch 11)

**DPO (Direct Preference Optimization)** — alignment technique treating preference data as supervised classification; no RL loop needed (Ch 10)

**ELBO (Evidence Lower BOund)** — E[log P(x|z)] − KL(q(z|x)||p(z)); training objective for VAEs; maximizing ELBO maximizes log P(x) (Ch 11)

**Embedding** — dense vector representation of a token or text; learned end-to-end or via Word2Vec/BERT/CLIP (Ch 3)

**Emergent Capabilities** — abilities (CoT, in-context learning) that appear abruptly as LLM scale increases (Ch 5)

**FACS (Facial Action Coding System)** — system decomposing facial expressions into 44 Action Units (AUs); used in deepfake re-enactment (Ch 14)

**FID (Fréchet Inception Distance)** — GAN quality metric comparing statistics of real and generated image distributions; lower = better (Ch 12)

**Few-shot Prompting** — providing 2–5 (input, output) examples before the actual query to guide format and style (Ch 7)

**Fine-tuning** — continue training a pre-trained model on a smaller task-specific dataset (Ch 4, Ch 5)

**Flash Attention** — IO-aware attention algorithm; reduces memory from O(n²) to O(n); speeds up transformer inference (Ch 9)

**FastText** — Word2Vec variant representing words as sums of character n-gram embeddings; handles OOV words (Ch 3)

**GAN (Generative Adversarial Network)** — two-player minimax game: generator G vs. discriminator D; invented by Goodfellow et al., 2014 (Ch 12)

**Generator G** — GAN component mapping noise z → synthetic data; trained to fool D (Ch 12)

**GloVe** — Global Vectors; word embeddings from global co-occurrence matrix factorization (Ch 3)

**GPT (Generative Pre-trained Transformer)** — decoder-only transformer; autoregressive causal LM; basis of ChatGPT, GPT-4 (Ch 4)

**GQA (Grouped Query Attention)** — attention variant grouping queries to share fewer K/V heads; reduces KV-cache memory (Ch 6)

**Guardrails** — safety filters (Llama Guard, NeMo Guardrails) blocking harmful LLM outputs (Ch 7)

**Guidance Scale** — CFG hyperparameter; 7–12 typical; higher = more prompt-faithful but less diverse (Ch 15)

**HumanEval** — coding benchmark measuring pass@k: % of k generated code samples passing unit tests (Ch 6)

**IAF (Inverse Autoregressive Flow)** — normalizing flow applied to VAE latent samples; enriches posterior beyond single Gaussian (Ch 11)

**Identity Loss** — CycleGAN term preventing generators from shifting images already in the target domain (Ch 13)

**InstructGPT** — 1.3B parameter GPT model with RLHF that outperforms unaligned GPT-3 (175B) on instruction following (Ch 5)

**KL Divergence** — KL(q||p); measures posterior deviation from prior; penalized in ELBO; constrained in RLHF PPO (Ch 5, Ch 11)

**KTO (Kahneman-Tversky Optimization)** — alignment from binary (good/bad) feedback, without pairwise preferences (Ch 10)

**KV-Cache** — cached key/value tensors for past tokens during generation; GQA reduces its size (Ch 6)

**LangChain** — Python framework for composing LLM applications via LCEL pipe syntax: `prompt | model | parser` (Ch 8)

**LangGraph** — LangChain extension for stateful agentic workflows as directed graphs with memory (Ch 8)

**LangSmith** — LangChain observability tool for tracing, debugging, and monitoring LLM chains (Ch 8)

**Language Model** — model assigning probability P(w_t | w_1...w_{t-1}) to the next token (Ch 3)

**Latent Variable Z** — hidden random variable encoding structure not directly observed; sampled to generate data (Ch 1, Ch 11)

**LCEL** — LangChain Expression Language; pipe-based composition `prompt | model | parser` (Ch 8)

**LLaMA** — Meta's open-source LLM family; decoder-only with RMSNorm, RoPE, SwiGLU, GQA innovations (Ch 6)

**LoRA (Low-Rank Adaptation)** — PEFT technique injecting low-rank update matrices A·B into frozen weights; r << min(d,k) (Ch 9)

**LSTM** — Long Short-Term Memory; RNN variant with forget/input/output gates; solves vanishing gradient for long sequences (Ch 2)

**Masked LM (MLM)** — BERT pre-training objective; predict randomly masked tokens using bidirectional context (Ch 4)

**MemorySaver** — LangGraph checkpointer persisting conversation state per thread_id across invocations (Ch 8)

**MoE (Mixture of Experts)** — architecture routing each token to k of N expert FFN blocks; Mixtral 8×7B, Gemini 1.5 (Ch 6, Ch 9)

**Mode Collapse** — GAN failure where G generates only one or few modes of the data distribution; prevented by minibatch std dev (Ch 12)

**Multi-head Attention** — h parallel attention heads each capturing different relationships; concatenated + projected (Ch 2, Ch 4)

**Nash Equilibrium** — GAN training convergence: D(G(z)) ≈ 0.5; D cannot distinguish real from fake (Ch 12)

**NF4 (Normal Float 4-bit)** — quantization format optimal for normally distributed weights; used in QLoRA (Ch 9)

**Non-saturating Generator Loss** — maximize log D(G(z)) instead of minimize log(1-D(G(z))); avoids vanishing gradient early in training (Ch 12)

**NSP (Next Sentence Prediction)** — BERT pre-training task; predicts whether two sentences are consecutive (Ch 4)

**PEFT (Parameter-Efficient Fine-Tuning)** — fine-tune <1% of parameters while achieving comparable performance to full fine-tuning (Ch 9)

**Perplexity** — exp(cross-entropy loss); standard language model evaluation metric; lower = better (Ch 3)

**PatchGAN Discriminator** — discriminator classifying N×N patches rather than the full image; better local texture quality (Ch 13)

**Pix2Pix** — conditional GAN for paired image-to-image translation with U-Net generator + PatchGAN discriminator (Ch 13)

**Pixelwise Normalization** — Progressive GAN technique normalizing each pixel's feature vector to unit length in G (Ch 12)

**Positional Encoding** — adds position information to token embeddings; sinusoidal (original) or learned (BERT) or RoPE (LLaMA) (Ch 4, Ch 6)

**PPO (Proximal Policy Optimization)** — RL algorithm used in RLHF; updates policy to maximize reward while bounding KL divergence (Ch 5)

**Progressive GAN** — generates high-res images by growing G and D from 4×4 to target resolution with smooth fade-in (Ch 12)

**Prompt Tuning (Soft Prompting)** — prepend learnable virtual tokens to input; only virtual tokens trained (0.002% params) (Ch 9)

**QLoRA** — LoRA + 4-bit NF4 quantization; enables fine-tuning 7B+ models on a single 24GB GPU (Ch 9)

**Quantization** — convert FP32/BF16 weights to INT8/INT4; reduces model size 2–4× with small accuracy trade-off (Ch 9)

**RAG (Retrieval-Augmented Generation)** — augment LLM context with retrieved document chunks from a vector database (Ch 8)

**ReAct** — prompting pattern alternating Thought → Action (external operation) → Observation; basis of agentic tool use (Ch 7)

**Reparameterization Trick** — z = μ + σ·ε where ε ~ N(0,I); makes VAE sampling differentiable for backpropagation (Ch 11)

**RLHF (Reinforcement Learning from Human Feedback)** — SFT + reward model + PPO; aligns LLM to human preferences (Ch 5)

**RLAIF** — RLHF with AI feedback instead of human annotation; scales alignment without human annotators (Ch 10)

**RMSNorm** — Root Mean Square Normalization; normalizes by RMS, not mean+variance; faster than LayerNorm; used in LLaMA (Ch 6)

**RoPE (Rotary Positional Embeddings)** — encodes relative positions via rotation of Q/K vectors; better extrapolation; used in LLaMA (Ch 6)

**Self-Attention** — attention where Q=K=V=input; all tokens attend to all others simultaneously; O(n²) complexity (Ch 4)

**SelfCheckGPT** — hallucination detection by sampling multiple LLM outputs and measuring consistency (Ch 10)

**Skip-gram** — Word2Vec variant predicting context words from center word; better for rare words (Ch 3)

**Stable Diffusion** — Latent Diffusion Model with VAE encoding + U-Net denoiser + CLIP text conditioning (Ch 15)

**SwiGLU** — activation function in LLaMA FFN; Swish-gated linear unit; outperforms ReLU/GELU (Ch 6)

**Temperature** — inference hyperparameter scaling logits before softmax; T<1 = sharper/conservative; T>1 = diverse/random (Ch 3, Ch 7)

**Top-k Sampling** — sample next token from only the k highest-probability candidates (Ch 3, Ch 7)

**Transformer** — attention-based architecture replacing recurrence; self-attention + FFN + residual + LayerNorm (Ch 2, Ch 4)

**U-Net** — encoder-decoder with skip connections; used in Pix2Pix (style transfer) and Stable Diffusion (denoiser) (Ch 13, Ch 15)

**VAE (Variational Autoencoder)** — generates images via structured latent space; encoder outputs μ,σ; reparameterization trick; ELBO training (Ch 11)

**Vanishing Gradient** — gradients shrink to zero in deep nets with sigmoid; solved by ReLU, skip connections, LSTMs (Ch 2)

**Vector Database** — stores dense embeddings; queried via cosine similarity for RAG retrieval (Ch 8)

**Word2Vec** — dense word embedding trained from co-occurrence (CBOW/skip-gram); captures semantic analogy (Ch 3)

**Xavier Initialization** — weight initialization scaling variance by 1/(fan_in+fan_out); prevents gradient vanishing/explosion for sigmoid/tanh (Ch 2)

**Zero-shot Prompting** — prompting an LLM for a task without any examples; works because LLMs learn from pre-training (Ch 7)
