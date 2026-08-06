# Chapter 12: Image Generation with GANs

## Core Idea
Generative Adversarial Networks (GANs) are a two-player minimax game: a Generator G creates fake images from noise z, and a Discriminator D tries to distinguish real from fake. Training drives G to produce images that fool D, reaching a Nash equilibrium where D(G(z)) ≈ 0.5. GANs produce sharper, more realistic images than VAEs but are notoriously harder to train.

## Frameworks Introduced

- **Vanilla GAN (Goodfellow et al., 2014)**:
  - Generator G: z ~ p_z → G(z) ∈ X (image space). Goal: make D(G(z)) → 1.
  - Discriminator D: x ∈ {real, fake} → D(x) ∈ [0,1]. Goal: D(x_real) → 1, D(G(z)) → 0.
  - Minimax objective: min_G max_D V(G,D) = E[log D(x)] + E[log(1 − D(G(z)))]
  - Optimal discriminator: D*(x) = p_data(x) / (p_data(x) + p_g(x))
  - Training: alternate 1 discriminator step per 1 generator step.

- **Non-Saturating Generator Loss**:
  - Problem: early in training, G is weak → D(G(z)) ≈ 0 → log(1−D(G(z))) saturates → near-zero gradient for G.
  - Fix: instead of minimizing log(1−D(G(z))), maximize log(D(G(z))) — same equilibrium, non-saturating gradient.
  - When to use: always use non-saturating loss for the generator; vanilla generator loss fails in practice.

- **DC-GAN (Deep Convolutional GAN)**:
  - When to use: image generation tasks; replaces MLP with CNN-based G and D.
  - Generator: ConvTranspose2d layers (upsampling) + BatchNorm + ReLU → Tanh output.
  - Discriminator: Conv2d + BatchNorm + LeakyReLU → Sigmoid output.
  - Rules: no pooling layers; use strided convolutions; BatchNorm in both G and D (not output/input layers).

- **Conditional GAN (cGAN)**:
  - When to use: controlled generation — specify what class to generate.
  - How: condition both G and D on label y. G(z, y) → image of class y; D(x, y) → real/fake given class y.
  - Implementation: concatenate one-hot label to z (generator input) and to image features (discriminator).

- **Progressive GAN (Karras et al.)**:
  - When to use: high-resolution image generation (256×256, 512×512, 1024×1024).
  - How: grow G and D from 4×4 → 8×8 → ... → target resolution. Fade-in new layers smoothly with α blend.
  - Key components:
    - **Progressive growth with smooth fade-in**: α blends old and new layers during transition.
    - **Minibatch standard deviation**: injects diversity information into D; reduces mode collapse.
    - **Equalized learning rate**: scale weights at runtime to keep all layers learning at the same speed.
    - **Pixelwise normalization**: normalize each pixel's feature vector to unit length in G.

## Key Concepts

- **Nash Equilibrium**: GAN training convergence point — G fools D with probability 0.5; D cannot distinguish real from fake
- **Mode Collapse**: G learns to generate a single mode (e.g., one MNIST digit) that always fools D; diversity collapses
- **Training Instability**: D becomes too strong → no gradient for G; D too weak → G doesn't improve
- **Minimax Objective**: min_G max_D V(G,D) — the formal game-theoretic formulation
- **Non-saturating Loss**: log D(G(z)) for generator instead of log(1−D(G(z))); avoids vanishing gradients early
- **Discriminator Saturation**: D outputs near 0 or 1 → gradient vanishes → training stalls
- **FID (Fréchet Inception Distance)**: primary GAN quality metric — compares statistics of real vs. generated image distributions; lower is better
- **Inception Score (IS)**: quality metric — generated images should be diverse AND classifiable; but doesn't capture distribution mismatch well
- **Progressive Growth**: incrementally increase G/D resolution during training; stabilizes high-res GAN training
- **Fade-in**: smooth transition between resolution stages using α ∈ [0,1] blend

## Mental Models

- Think of GAN training as "counterfeit money" — G is the counterfeiter, D is the detective; the counterfeiter improves until even the best detective is fooled 50% of the time.
- Non-saturating generator loss: "reward G for fooling D" instead of "punish G for failing" — mathematically equivalent at equilibrium, but gives much better gradients early.
- Progressive GAN: "learn to walk before you run" — train on 4×4 images first, gradually add resolution; each stage trains on manageable-complexity images.
- Minibatch std dev: "force G to generate diverse batches" — if the batch has low diversity, D detects it; G must spread output across modes.

## Anti-patterns

- **Using vanilla generator loss**: saturates early → training stalls. Always use non-saturating (maximize log D(G(z))).
- **Training D too many steps per G step**: D gets too strong; gradients for G vanish. Use 1:1 step ratio as default.
- **No BatchNorm in DC-GAN**: training becomes extremely unstable without it.
- **Using accuracy to measure GAN quality**: GAN discriminator accuracy is not informative about image quality. Use FID/IS.

## Code Examples

```python
import torch.nn as nn

# DC-GAN Generator: z → 64×64 image
class Generator(nn.Module):
    def __init__(self, latent_dim=100, ngf=64):
        super().__init__()
        self.net = nn.Sequential(
            # Input: z (latent_dim,) → 4×4
            nn.ConvTranspose2d(latent_dim, ngf*8, 4, 1, 0, bias=False),
            nn.BatchNorm2d(ngf*8), nn.ReLU(True),
            # 4×4 → 8×8
            nn.ConvTranspose2d(ngf*8, ngf*4, 4, 2, 1, bias=False),
            nn.BatchNorm2d(ngf*4), nn.ReLU(True),
            # 8×8 → 16×16
            nn.ConvTranspose2d(ngf*4, ngf*2, 4, 2, 1, bias=False),
            nn.BatchNorm2d(ngf*2), nn.ReLU(True),
            # 16×16 → 32×32
            nn.ConvTranspose2d(ngf*2, ngf, 4, 2, 1, bias=False),
            nn.BatchNorm2d(ngf), nn.ReLU(True),
            # 32×32 → 64×64
            nn.ConvTranspose2d(ngf, 3, 4, 2, 1, bias=False),
            nn.Tanh()  # output in [-1, 1]
        )
    def forward(self, z):
        return self.net(z.view(-1, z.shape[1], 1, 1))
```
- **What it demonstrates**: DC-GAN generator with ConvTranspose2d upsampling + BatchNorm + ReLU, Tanh output — the standard architecture pattern.

```python
# GAN training loop (alternating G and D updates)
criterion = nn.BCELoss()
real_label, fake_label = 1., 0.

for real_imgs in dataloader:
    # --- Train Discriminator ---
    optimizer_D.zero_grad()
    output_real = D(real_imgs)
    loss_D_real = criterion(output_real, torch.full_like(output_real, real_label))
    z = torch.randn(batch_size, latent_dim, device=device)
    fake_imgs = G(z).detach()  # detach: don't backprop through G
    output_fake = D(fake_imgs)
    loss_D_fake = criterion(output_fake, torch.full_like(output_fake, fake_label))
    (loss_D_real + loss_D_fake).backward()
    optimizer_D.step()

    # --- Train Generator (non-saturating: maximize log D(G(z))) ---
    optimizer_G.zero_grad()
    z = torch.randn(batch_size, latent_dim, device=device)
    output = D(G(z))
    loss_G = criterion(output, torch.full_like(output, real_label))  # non-saturating
    loss_G.backward()
    optimizer_G.step()
```
- **What it demonstrates**: alternating D/G training loop with non-saturating generator loss.

## Reference Tables

| GAN Variant | Architecture Change | Key Benefit |
|---|---|---|
| Vanilla GAN | MLP G + MLP D | Proof of concept |
| DC-GAN | CNN G + CNN D | Stable image generation |
| Conditional GAN | G(z,y) + D(x,y) | Class-controlled generation |
| Progressive GAN | Gradual resolution growth | High-res (1024×1024) generation |
| StyleGAN | Mapping network + AdaIN | Fine-grained style control |

| GAN Pathology | Symptom | Fix |
|---|---|---|
| Mode collapse | All G outputs look identical | Minibatch std dev; unrolled GAN |
| Training instability | Loss oscillates wildly | Gradient penalty; progressive training |
| Uninformative loss | BCE loss ↑ but quality ↑ too | Use FID as quality metric, not loss |

## Worked Example

**Progressive GAN 4×4 → 8×8 fade-in:**

```python
alpha = 0.  # fade-in factor: 0 = old resolution, 1 = new resolution

# During fade-in transition:
# old: 4×4 output upsampled to 8×8
old_out = F.interpolate(old_layer(x), scale_factor=2)  # simple upsample
# new: 8×8 from new conv layer
new_out = new_layer(x)
# blended output
output = (1 - alpha) * old_out + alpha * new_out

# alpha increases from 0 to 1 over training
alpha = min(1., alpha + alpha_step)
```
Progressive GAN trained on FFHQ (Flickr-Faces-HQ) dataset achieved FID ≈ 8.0 at 1024×1024 — vs. FID ≈ 20+ for DC-GAN at 64×64 — demonstrating the power of gradual resolution growth.

## Key Takeaways

1. GAN minimax objective: min_G max_D [E log D(x) + E log(1−D(G(z)))] — generator and discriminator have opposing objectives.
2. Always use non-saturating generator loss (maximize log D(G(z))) — vanilla loss saturates early and kills gradients.
3. DC-GAN rules: ConvTranspose2d (not MLP) for G; Conv2d for D; BatchNorm everywhere; no pooling.
4. Mode collapse and training instability are the two core GAN failure modes — addressed by minibatch std dev (diversity) and progressive training (stability).
5. FID (Fréchet Inception Distance) is the standard quality metric for GANs — not loss curves, not discriminator accuracy.

## Connects To

- **Ch 11**: VAEs vs. GANs — both generate images; VAE has explicit latent space + ELBO; GAN has implicit distribution + adversarial training
- **Ch 13**: Style Transfer builds on GAN framework (Pix2Pix, CycleGAN)
- **Ch 14**: Deepfakes use GAN-based face synthesis and reenactment
- **Ch 15**: Diffusion Models overtook GANs for image quality; compare trade-offs
