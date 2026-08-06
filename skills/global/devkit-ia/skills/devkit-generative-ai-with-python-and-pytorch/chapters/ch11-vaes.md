# Chapter 11: Neural Networks Using VAEs

## Core Idea
Variational Autoencoders (VAEs) solve image generation by learning a structured latent space where similar images cluster together. The key innovation is the **reparameterization trick** — which makes sampling from a Gaussian latent space differentiable — combined with the **ELBO loss** (reconstruction + KL divergence) that forces the latent space to be smooth and continuous.

## Frameworks Introduced

- **Autoencoder**:
  - When to use: dimensionality reduction, feature learning, anomaly detection.
  - How: encoder maps x → z (low-dim code); decoder maps z → x̂ (reconstruction). Train with reconstruction loss only (MSE or BCE).
  - Limitation: no guarantee z is continuous or structured → can't sample from z to generate new images.

- **Variational Autoencoder (VAE)**:
  - When to use: controllable image generation; learning a smooth, interpolable latent space.
  - How:
    1. Encoder outputs μ(x) and σ(x) — parameters of a Gaussian posterior q(z|x) ≈ N(μ, σ²).
    2. Sample z using the reparameterization trick: z = μ + σ·ε where ε ~ N(0, I).
    3. Decoder reconstructs x from z.
    4. Train with ELBO loss = Reconstruction loss + KL(q(z|x) || p(z)).
  - The KL term forces the posterior to stay close to the prior N(0,I) → smooth latent space.

- **ELBO (Evidence Lower BOund)**:
  - The VAE maximizes the ELBO (= lower bound on log P(x)):
    - ELBO = E[log P(x|z)] − KL(q(z|x) || p(z))
  - First term: reconstruction quality (maximize → low reconstruction loss).
  - Second term: KL divergence penalty (minimize → posterior stays near N(0,I)).
  - β-VAE: multiply KL term by β > 1 to enforce better disentanglement.

- **Reparameterization Trick**:
  - Problem: sampling z ~ N(μ, σ²) is non-differentiable → can't backpropagate through the sample.
  - Solution: z = μ + σ·ε where ε ~ N(0,I) — move the randomness to ε which has no trainable parameters.
  - Effect: gradients flow through μ and σ without issue.

- **Inverse Autoregressive Flow (IAF)**:
  - When to use: when the VAE posterior q(z|x) is too simple (single Gaussian) for complex data.
  - How: apply a sequence of invertible normalizing flow transformations to z to make the posterior more expressive.
  - Result: richer posterior approximation → better generated image quality.

- **PCA vs. Neural Autoencoder**:
  - PCA: linear decomposition of covariance matrix; codes for MNIST digits overlap.
  - Neural autoencoder: nonlinear transformation → clearly separated, clustered digit codes.
  - Use neural autoencoder when PCA codes are not separable in 2D.

## Key Concepts

- **Latent Space / Code**: low-dimensional embedding z that captures the essential structure of the input
- **Posterior q(z|x)**: encoder's approximation to the true posterior of z given x; modeled as N(μ(x), σ²(x))
- **Prior p(z)**: assumed simple distribution for the latent space, typically N(0, I)
- **KL Divergence**: KL(q||p) — measures how much the posterior deviates from the prior; penalized in ELBO
- **Reconstruction Loss**: how well the decoder reconstructs x from z; MSE for continuous, BCE for binary
- **β-VAE**: β-weighted KL penalty to disentangle latent factors (β=4–10); forces each z dim to control one independent factor
- **Disentangled Representation**: latent space where each z dimension independently controls one interpretable factor (e.g., rotation, brightness)
- **IAF (Inverse Autoregressive Flow)**: normalizing flow applied to VAE latent samples to enrich the posterior
- **CIFAR-10**: 60,000 32×32 color images in 10 classes; common VAE benchmark beyond MNIST
- **RBM (Restricted Boltzmann Machine)**: historical precursor to VAEs; first demonstrated useful image codes

## Mental Models

- Think of the VAE encoder as a "compressor with uncertainty" — instead of outputting a single code, it outputs a Gaussian distribution over codes.
- The reparameterization trick: "separate the signal (μ, σ) from the noise (ε)" — backprop flows through μ and σ, not through the random draw.
- ELBO = "how well do we reconstruct?" + "how well-behaved is our latent space?" — the two terms must be balanced.
- The KL penalty is a "regularizer on the latent space" — without it, the encoder learns to ignore the prior and the latent space becomes non-navigable.

## Anti-patterns

- **Using reconstruction loss alone (plain autoencoder)**: latent space will be irregular; new samples from z will produce garbage.
- **KL weight too high (β too large)**: posterior collapses — all inputs mapped to the same z; reconstruction degrades catastrophically.
- **KL weight too low (β ≈ 0)**: posterior becomes too expressive; loses the smooth latent space property; becomes a plain autoencoder.
- **Linear interpolation in pixel space**: interpolating between two images in pixel space produces a blurry average; interpolate in latent space instead.

## Code Examples

```python
import torch
import torch.nn as nn
import torch.nn.functional as F

class VAE(nn.Module):
    def __init__(self, input_dim=784, latent_dim=20):
        super().__init__()
        # Encoder: x → μ, log_σ²
        self.fc1 = nn.Linear(input_dim, 400)
        self.fc_mu = nn.Linear(400, latent_dim)
        self.fc_logvar = nn.Linear(400, latent_dim)
        # Decoder: z → x̂
        self.fc3 = nn.Linear(latent_dim, 400)
        self.fc4 = nn.Linear(400, input_dim)

    def encode(self, x):
        h = F.relu(self.fc1(x))
        return self.fc_mu(h), self.fc_logvar(h)

    def reparameterize(self, mu, logvar):
        # Reparameterization trick: z = μ + σ·ε, ε ~ N(0,I)
        std = torch.exp(0.5 * logvar)
        eps = torch.randn_like(std)
        return mu + eps * std

    def decode(self, z):
        h = F.relu(self.fc3(z))
        return torch.sigmoid(self.fc4(h))

    def forward(self, x):
        mu, logvar = self.encode(x.view(-1, 784))
        z = self.reparameterize(mu, logvar)
        return self.decode(z), mu, logvar

def vae_loss(recon_x, x, mu, logvar):
    # Reconstruction loss (BCE) + KL divergence
    recon_loss = F.binary_cross_entropy(recon_x, x.view(-1, 784), reduction='sum')
    kl_loss = -0.5 * torch.sum(1 + logvar - mu.pow(2) - logvar.exp())
    return recon_loss + kl_loss
```
- **What it demonstrates**: complete VAE implementation — encoder outputs μ/logvar, reparameterization trick for differentiable sampling, ELBO loss as reconstruction + KL.

## Worked Example

**VAE latent space interpolation between two MNIST digits:**

```python
# Encode two images to their latent codes
mu_7, logvar_7 = vae.encode(img_7)  # image of "7"
mu_3, logvar_3 = vae.encode(img_3)  # image of "3"

# Interpolate in latent space (10 steps)
for alpha in torch.linspace(0, 1, 10):
    z_interp = (1 - alpha) * mu_7 + alpha * mu_3
    generated = vae.decode(z_interp)
    # Shows smooth transition: 7 → morphs → 3
```

Why this works: because the KL penalty forces nearby z values to decode to similar images, the latent space is smooth and interpolatable. The same interpolation in pixel space would just produce a blurry average.

β-VAE experiment on CIFAR-10:
| β | Reconstruction quality | Disentanglement |
|---|---|---|
| 0 | Best (plain autoencoder) | None |
| 1 | Good (standard VAE) | Partial |
| 4 | Moderate | Better |
| 10 | Poor | Best |

## Key Takeaways

1. The reparameterization trick (z = μ + σ·ε) is the core insight that makes VAEs trainable end-to-end via backpropagation.
2. ELBO loss = reconstruction loss + KL divergence — reconstruction drives quality, KL enforces a smooth/navigable latent space.
3. The KL term is a "regularizer on the latent space" — it ensures you can sample z ~ N(0,I) and decode a meaningful image.
4. β-VAE (β > 1 on KL term) creates more disentangled representations at the cost of reconstruction quality.
5. IAF enriches the posterior beyond a simple Gaussian — better for complex data distributions where N(μ, σ²) is insufficient.

## Connects To

- **Ch 1**: VAE was introduced as one of three core generative model types; this chapter implements it
- **Ch 2**: encoder-decoder architecture built from CNN/MLP blocks introduced in Ch 2
- **Ch 12**: GANs as an alternative to VAEs for image generation — compare trade-offs
- **Ch 15**: Diffusion Models extend the VAE latent space concept with iterative denoising
