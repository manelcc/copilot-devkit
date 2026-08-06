# Chapter 15: Diffusion Models and AI Art

## Core Idea
Diffusion Models generate images by learning to reverse a Markov noise process: the forward process gradually corrupts an image with Gaussian noise until it becomes pure noise; the reverse process (parameterized by a U-Net) iteratively denoises random noise into a coherent image. Stable Diffusion improves efficiency by operating in latent space (using a VAE encoder/decoder) and conditions generation on text prompts via CLIP embeddings.

## Frameworks Introduced

- **DDPM (Denoising Diffusion Probabilistic Models — Ho et al., 2020)**:
  - Forward process q: x_0 → x_1 → ... → x_T (T steps of Gaussian noise addition)
    - q(x_t | x_{t-1}) = N(√(1-β_t)·x_{t-1}, β_t·I)
    - β_t controls noise schedule (linear or cosine); small β_t = gradual noise.
  - Reverse process p_θ: x_T → ... → x_1 → x_0 (learned denoising)
    - p_θ(x_{t-1} | x_t) = N(μ_θ(x_t, t), Σ)
    - μ_θ parameterized by a U-Net that predicts noise ε_θ(x_t, t).
  - Training objective: L = E[||ε − ε_θ(x_t, t)||²] — minimize MSE between true and predicted noise.
  - Sampling: start from x_T ~ N(0,I), apply T reverse denoising steps.

- **Latent Diffusion Models (LDM) / Stable Diffusion (Rombach et al., 2022)**:
  - Key insight: run diffusion in compressed latent space (not pixel space) → 4–8× fewer operations.
  - How: encode image x → z via VAE encoder; run DDPM on z; decode z̃ → x̃ via VAE decoder.
  - Text conditioning: CLIP text encoder converts prompt → embedding vector → cross-attention in U-Net.

- **Stable Diffusion Pipeline Components**:
  1. **Tokenizer**: converts text prompt to Byte Pair Encoding (BPE) token IDs (max 77 tokens).
  2. **CLIP Text Encoder**: 12-layer transformer; maps token IDs → 768-dim embedding vectors.
  3. **U-Net Denoiser**: predicts noise ε_θ at each denoising step; conditioned on text embedding via cross-attention.
  4. **Scheduler (PNDM/DDIM/DEIS)**: controls the denoising step sequence; fewer steps = faster generation.
  5. **VAE Decoder**: maps denoised latent z̃ → full-resolution output image.
  6. **Safety Checker**: scans generated images for potentially harmful content.

- **Classifier-Free Guidance (CFG)**:
  - When to use: always in text-to-image generation to strengthen prompt adherence.
  - How: run U-Net twice — once with text embedding (conditional), once with empty prompt (unconditional). Blend: ε_guided = ε_uncond + guidance_scale × (ε_cond − ε_uncond).
  - guidance_scale: typically 7–12. Higher → more prompt-faithful but less diverse.
  - guidance_scale=1 → no guidance (unconditional); guidance_scale=15 → heavily prompt-constrained.

- **Byte Pair Encoding (BPE)**:
  - How: iteratively replace the most common byte pair with a new token. Works on bytes (not characters) → handles any Unicode text including emojis.
  - Result: efficient tokenization that compresses commonly occurring patterns; basis of most modern LLM tokenizers.

## Key Concepts

- **Forward Process q**: Markov chain adding Gaussian noise; deterministic given β schedule
- **Reverse Process p_θ**: learned; U-Net predicts ε (noise) at each step; subtract to denoise
- **Noise Schedule β_t**: controls how quickly the image degrades; linear (original DDPM) or cosine (improved DDPM)
- **Guidance Scale**: CFG hyperparameter controlling prompt adherence vs. diversity trade-off
- **num_inference_steps**: number of denoising steps at inference (50 = high quality; 20 = fast); DDIM allows fewer steps than DDPM
- **CLIP**: Contrastive Language-Image Pre-training — joint image-text embedding model trained on image-caption pairs; key to text-conditioned generation
- **Latent Space (SD)**: 64×64×4 latent tensor vs. 512×512×3 pixel image; 192× fewer elements to denoise
- **Scheduler variants**: DDIM (faster, fewer steps), PNDM (stable), DEIS — all sample the reverse process differently
- **Safety Checker**: Stable Diffusion's CLIP-based content filter for NSFW outputs
- **BPE**: Byte Pair Encoding — tokenization algorithm compressing common byte patterns; used in GPT/CLIP/BERT

## Mental Models

- Think of DDPM as "teaching a neural network to be an art restorer" — given a progressively damaged image, learn to reverse the damage.
- Stable Diffusion: "sketch in low resolution (latent space), then fill in the details (VAE decoder)" — far more efficient than pixel-space diffusion.
- Guidance scale: "how literally should the model follow the prompt?" — low guidance = creative freedom; high guidance = strict prompt adherence.
- CLIP embedding: "translate words into visual concepts" — the CLIP encoder maps text to the same semantic space as images; the U-Net then uses this to guide denoising.

## Anti-patterns

- **High guidance_scale (> 20)**: artifacts and over-saturated images; stay in 7–12 range for most prompts.
- **Too few inference steps (< 15)**: image is under-denoised; blurry/incoherent. Use 20–50 steps.
- **Not encoding negative prompts**: Stable Diffusion supports negative prompts to guide away from unwanted content (e.g., "blurry, low quality"); always use them in production.
- **Running SD in pixel space**: unnecessary — latent diffusion is 8× faster with comparable quality.

## Code Examples

```python
from diffusers import StableDiffusionPipeline
import torch

# Load Stable Diffusion pipeline
pipe = StableDiffusionPipeline.from_pretrained(
    "runwayml/stable-diffusion-v1-5",
    torch_dtype=torch.float16,
    safety_checker=None  # disable for research use
)
pipe = pipe.to("cuda")

# Generate image from text prompt
result = pipe(
    prompt="a zombie in the style of Picasso",
    num_inference_steps=50,       # denoising steps
    guidance_scale=7.5,           # CFG scale: prompt adherence
    height=512, width=512,
    negative_prompt="blurry, low quality, distorted"  # avoid these attributes
)
image = result.images[0]
image.save("output.png")
```
- **What it demonstrates**: Stable Diffusion text-to-image generation with key parameters: inference steps, guidance scale, negative prompt.

```python
# Manual Stable Diffusion pipeline: inspect each component
from diffusers import StableDiffusionPipeline

pipe = StableDiffusionPipeline.from_pretrained("runwayml/stable-diffusion-v1-5")

# Step 1: Tokenize prompt → token IDs
tokens = pipe.tokenizer(["a zombie in the style of Picasso"],
                         padding="max_length", max_length=77, return_tensors="pt")

# Step 2: CLIP encode → 77 × 768 embedding
with torch.no_grad():
    text_embeddings = pipe.text_encoder(tokens.input_ids.to("cuda"))[0]
    # Also encode empty prompt for classifier-free guidance
    uncond_embeddings = pipe.text_encoder(
        pipe.tokenizer([""], padding="max_length", max_length=77, return_tensors="pt").input_ids.to("cuda")
    )[0]

# Step 3: Initialize random latent (64×64×4)
latents = torch.randn((1, 4, 64, 64), device="cuda", dtype=torch.float16)

# Steps 4-53: Denoising loop
for t in pipe.scheduler.timesteps:
    with torch.no_grad():
        noise_pred_cond   = pipe.unet(latents, t, text_embeddings).sample
        noise_pred_uncond = pipe.unet(latents, t, uncond_embeddings).sample
        # CFG: guided noise prediction
        noise_pred = noise_pred_uncond + 7.5 * (noise_pred_cond - noise_pred_uncond)
    latents = pipe.scheduler.step(noise_pred, t, latents).prev_sample

# Step 54: VAE decode latent → image
latents = latents / 0.18215  # undo VAE scaling
with torch.no_grad():
    image = pipe.vae.decode(latents).sample
```
- **What it demonstrates**: the full Stable Diffusion pipeline step-by-step — tokenization → CLIP → U-Net denoising loop with CFG → VAE decode.

## Reference Tables

| SD Parameter | Range | Effect |
|---|---|---|
| guidance_scale | 7–12 (typical) | 1 = uncond; higher = more prompt-faithful |
| num_inference_steps | 20–50 | Fewer = faster/blurrier; more = sharper |
| height/width | 512 (base) | 768+ for SD XL; multiples of 64 only |
| negative_prompt | text | Concepts to exclude from generation |
| seed | any int | Fixed seed = reproducible generation |

| Diffusion Model | Domain | Key Innovation |
|---|---|---|
| DDPM | Pixel space | First viable DDPM; 1000 steps |
| DDIM | Pixel space | Deterministic sampling; 50 steps |
| LDM / SD 1.5 | Latent space | 8× efficient; CLIP conditioning |
| SD XL | Latent space | Higher resolution; better prompting |
| DALL-E 3 | Latent space | OpenAI; top text-to-image quality |

## Worked Example

**Reproducing Théâtre D'opéra Spatial (the Colorado State Fair winner) with Stable Diffusion:**

```python
pipe = StableDiffusionPipeline.from_pretrained("stabilityai/stable-diffusion-2-1")
result = pipe(
    prompt="Theatre D'opera Spatial, fantastical sci-fi landscape, baroque opera house in space, dramatic lighting, digital painting, highly detailed",
    negative_prompt="blurry, low quality, amateur, watermark",
    num_inference_steps=50,
    guidance_scale=9.0,
    width=768, height=512
)
```

Prompt engineering decisions:
- "baroque opera house in space": combines art style (baroque) with sci-fi setting
- guidance_scale=9.0: higher than default (7.5) for more literal prompt adherence
- Adding style descriptors ("digital painting, highly detailed") improves artistic quality
- negative_prompt excludes quality-degrading attributes

Result: the same type of output Jason Allen won with at the Colorado State Fair — demonstrating that diffusion models have democratized AI art creation.

## Key Takeaways

1. DDPM = Markov noise process in both directions; train U-Net to predict added noise ε at each step; minimize ||ε − ε_θ||².
2. Stable Diffusion's key insight: run diffusion in compressed 64×64 latent space (VAE-encoded) → 8× fewer operations than pixel-space diffusion.
3. CLIP text encoder bridges language and vision — the same semantic space lets U-Net use text embeddings to guide denoising.
4. Classifier-Free Guidance controls prompt adherence: ε_guided = ε_uncond + scale × (ε_cond − ε_uncond); scale=7–12 is the practical sweet spot.
5. Diffusion models have largely superseded GANs for image quality — more stable training, better diversity, natural text conditioning.

## Connects To

- **Ch 1**: Théâtre D'opéra Spatial introduced as the motivating example — this chapter explains how it was generated
- **Ch 11**: VAE ELBO connects to diffusion model training objective; VAE encoder/decoder used in SD
- **Ch 4**: CLIP uses transformer architecture from Ch 4 for text encoding
- **Ch 12**: Diffusion models vs. GANs — diffusion wins on quality/diversity; GAN still faster at inference
