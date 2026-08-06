# Chapter 13: Style Transfer with GANs

## Core Idea
Image-to-image translation uses GAN architectures to transform images from one domain to another — turning sketches into photos, aerial maps into satellite imagery, or horses into zebras. Pix2Pix (paired) and CycleGAN (unpaired) are the two foundational frameworks, differing in whether they require matching source-target image pairs at training time.

## Frameworks Introduced

- **Pix2Pix-GAN (Isola et al.) — Paired Style Transfer**:
  - When to use: image-to-image translation when you have paired training data (e.g., edge map + photo, label map + real image).
  - How: conditional GAN where G takes source image (not noise z) as input → generates target domain image; D takes (source, target) pair and classifies real/fake.
  - Key components:
    1. **U-Net Generator**: encoder-decoder with skip connections between i-th downsampling and (n-i)-th upsampling layer.
    2. **PatchGAN Discriminator**: classifies 70×70 overlapping patches as real/fake (not the full image) → better texture consistency.
    3. **Loss**: L1 reconstruction loss + adversarial loss. L1 ensures low-frequency structure; adversarial adds high-frequency sharpness.

- **U-Net Generator**:
  - When to use: whenever both low-level features (edges, textures) and high-level semantics must be preserved in generation.
  - How: skip connections between encoder layer i and decoder layer (n-i) concatenate feature maps → preserves spatial details that the bottleneck would otherwise compress away.
  - Alternative: plain encoder-decoder (no skip connections) loses fine-grained spatial structure.

- **PatchGAN Discriminator**:
  - When to use: style transfer, super-resolution, any task needing realistic local textures.
  - How: apply D as a fully convolutional network → output is N×N matrix of real/fake scores for N×N patches.
  - Advantage: enforces local texture consistency; fewer parameters than full-image D; translates to any image size.

- **CycleGAN (Zhu et al.) — Unpaired Style Transfer**:
  - When to use: domain translation without paired training data (horse→zebra, photo→Monet painting, summer→winter).
  - How: train two generators G_{A→B} and G_{B→A} simultaneously. Two discriminators D_A and D_B.
  - Three losses:
    1. **Adversarial loss**: G_{A→B}(a) should fool D_B; G_{B→A}(b) should fool D_A.
    2. **Cycle consistency loss**: G_{B→A}(G_{A→B}(a)) ≈ a (forward cycle); G_{A→B}(G_{B→A}(b)) ≈ b (backward cycle). λ=10.
    3. **Identity loss**: G_{A→B}(b) ≈ b (image already in target domain should stay unchanged). λ_identity=0.5.

## Key Concepts

- **Paired Style Transfer**: requires (source, target) image pairs at training time; Pix2Pix
- **Unpaired Style Transfer**: only needs a collection of images from each domain; CycleGAN
- **Cycle Consistency**: G_{B→A}(G_{A→B}(x)) ≈ x — the only constraint that prevents mode collapse without paired data
- **PatchGAN**: discriminator classifying image patches (not full image); forces local texture realism
- **U-Net**: encoder-decoder with skip connections; preserves spatial details lost in bottleneck
- **Bottleneck Feature**: compressed representation at the narrowest point of an encoder-decoder; may lose fine spatial detail
- **InstanceNorm vs BatchNorm**: Pix2Pix uses InstanceNorm in the generator for better style transfer (style statistics per image, not per batch)
- **Identity Loss**: encourages G to act as identity on images already in the target domain; prevents color distortion
- **L1 Loss (Pix2Pix)**: pixel-level reconstruction loss → ensures global structure; combined with adversarial loss for textures

## Mental Models

- Pix2Pix: "translation with a dictionary" — each source image has a known target; learn the exact mapping.
- CycleGAN: "translation without a dictionary" — no pair needed; the cycle consistency constraint prevents nonsensical translations.
- U-Net skip connections: "don't forget where you came from" — pass low-level features directly to the decoder, bypassing the bottleneck.
- PatchGAN: "local texture critic" — judges whether each patch of the image looks real, not the full composition.

## Anti-patterns

- **Using full-image discriminator for style transfer**: tends to miss texture inconsistencies; PatchGAN captures local texture quality better.
- **CycleGAN without identity loss**: G learns to generate plausible images in target domain but may incorrectly shift colors even when unnecessary; identity loss prevents this.
- **Pix2Pix without L1 loss**: adversarial loss alone makes images sharp but structurally incorrect; L1 anchors the overall layout.
- **CycleGAN for tasks requiring exact correspondence**: CycleGAN produces plausible but not pixel-accurate translations; use Pix2Pix if you have pairs.

## Code Examples

```python
# Pix2Pix: U-Net generator downsampling/upsampling blocks
class DownSampleBlock(nn.Module):
    def __init__(self, in_ch, out_ch, normalize=True):
        super().__init__()
        layers = [nn.Conv2d(in_ch, out_ch, 4, stride=2, padding=1, bias=False)]
        if normalize:
            layers.append(nn.InstanceNorm2d(out_ch))
        layers += [nn.LeakyReLU(0.2), nn.Dropout(0.5)]
        self.model = nn.Sequential(*layers)

class UpSampleBlock(nn.Module):
    def __init__(self, in_ch, out_ch):
        super().__init__()
        self.model = nn.Sequential(
            nn.ConvTranspose2d(in_ch, out_ch, 4, stride=2, padding=1, bias=False),
            nn.InstanceNorm2d(out_ch),
            nn.ReLU(True)
        )
```
- **What it demonstrates**: Pix2Pix U-Net building blocks. Stride=2 downsampling; ConvTranspose2d upsampling; InstanceNorm for per-image style normalization.

```python
# CycleGAN: three-component loss
lambda_cyc = 10.0      # cycle consistency weight
lambda_id = 0.5        # identity loss weight

# Adversarial losses
loss_G_AB = adversarial_loss(D_B(G_AB(real_A)), real_label)
loss_G_BA = adversarial_loss(D_A(G_BA(real_B)), real_label)

# Cycle consistency losses
rec_A = G_BA(G_AB(real_A))
rec_B = G_AB(G_BA(real_B))
loss_cycle = (F.l1_loss(rec_A, real_A) + F.l1_loss(rec_B, real_B)) * lambda_cyc

# Identity losses (generator should not change domain-correct images)
loss_id = (F.l1_loss(G_AB(real_B), real_B) + F.l1_loss(G_BA(real_A), real_A)) * lambda_id

loss_G = loss_G_AB + loss_G_BA + loss_cycle + loss_id
```
- **What it demonstrates**: CycleGAN full generator loss — adversarial + cycle consistency + identity, with their respective λ weights.

## Worked Example

**Pix2Pix trained on aerial map → satellite photo:**

Architecture:
- Generator: U-Net with 8 downsampling + 8 upsampling blocks, skip connections between each mirror pair
- Discriminator: PatchGAN (70×70 receptive field), 5-layer fully convolutional network
- Loss: λ_L1=100 × L1 + adversarial (non-saturating)

Training observations:
| Epoch | Discriminator Loss | Generator Loss | Visual Quality |
|---|---|---|---|
| 0 | ~0.7 (chance) | ~0.7 | Random noise |
| 50 | ~0.4 | ~0.3 | Rough color/structure |
| 200 | ~0.3 | ~0.15 | Road outlines, water bodies preserved |

Key result: roads, water bodies, and building outlines from the aerial map transfer correctly to the generated satellite photo — low-level spatial details are preserved via U-Net skip connections.

## Key Takeaways

1. Pix2Pix = conditional GAN for paired data; U-Net generator preserves spatial detail; PatchGAN discriminator enforces local texture quality.
2. CycleGAN = unpaired translation via cycle consistency; G_{B→A}(G_{A→B}(x)) ≈ x constrains training without paired data.
3. PatchGAN's key insight: judge local patches, not the full image → better texture, scales to any resolution.
4. CycleGAN's identity loss prevents color distortion on images already in the target domain; always include it (λ_id=0.5).
5. For tasks requiring exact pixel-level correspondence, use Pix2Pix (paired) over CycleGAN (unpaired).

## Connects To

- **Ch 12**: Pix2Pix extends conditional GAN from Ch 12; PatchGAN extends vanilla discriminator
- **Ch 14**: Deepfake face reenactment uses Pix2Pix as a key component
- **Ch 15**: Diffusion Models now achieve better unpaired image translation than CycleGAN on many benchmarks
