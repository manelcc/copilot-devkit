# Chapter 1: Introduction to Generative AI: Drawing Data from Models

## Core Idea
Generative models learn the joint probability distribution P(X, Y) to generate new data samples, contrasting with discriminative models that learn P(Y|X) to classify existing data. Understanding Bayes' theorem is the conceptual bridge between the two paradigms.

## Frameworks Introduced

- **Discriminative vs. Generative Modeling**:
  - Discriminative: learn P(Y|X) — given data, predict label. Use for classification/regression.
  - Generative: learn P(X, Y) — model the data distribution itself. Use to generate new samples.
  - When to use generative: when you need to synthesize data, augment datasets, or model uncertainty.
  - How: via Bayes' theorem — P(Y|X) = P(X|Y) · P(Y) / P(X)

- **Latent Variable Z**:
  - Deep generative models learn P(X|Z) where Z is a latent (hidden) random vector.
  - Sampling Z from a simple distribution (Gaussian) and decoding it produces new data X.
  - Used by: VAEs (explicit latent space), GANs (implicit), Diffusion Models, LLMs.

- **Conditional Generation P(X|Y=y, Z=z)**:
  - When a label Y controls generation alongside latent noise Z.
  - Example: generate images of a specific class, text in a specific style.

## Key Concepts

- **Generative Model**: models P(X) or P(X, Y); can generate new samples from the distribution
- **Discriminative Model**: models P(Y|X); learns decision boundaries only
- **Bayes' Theorem**: P(Y|X) = P(X|Y)·P(Y) / P(X) — relates posterior to likelihood × prior
- **Latent Variable**: hidden variable Z that captures underlying structure; not directly observed
- **Posterior**: P(Y|X) — probability of label given observed data
- **Joint Distribution**: P(X, Y) — probability of both data and label together
- **Data Augmentation**: using generative models to expand small datasets with synthetic examples
- **Style Transfer**: mapping between image domains (e.g., horse→zebra) using GANs
- **VAE**: Variational Autoencoder — encodes images to latent Z, decodes back to generate
- **GAN**: Generative Adversarial Network — generator vs. discriminator adversarial game

## Mental Models

- Use **VAE** when you need a structured latent space you can interpolate and control.
- Use **GAN** when you need high-fidelity image generation and can tolerate training instability.
- Think of Z as a "creativity knob" — different Z values produce different but plausible outputs.
- Think of generative AI as "modeling the world" rather than "labeling the world."

## Anti-patterns

- **Confusing generative with discriminative scope**: don't use a classifier where you need to synthesize data — they solve different problems.
- **Ignoring dataset bias in generative models**: generative models amplify biases in training data; garbage in → garbage out (and generated).
- **Evaluating generation with classification metrics**: accuracy/loss don't capture image quality or diversity; need specialized metrics (FID, IS).

## Code Examples

```python
# Conceptual: sampling from a generative model's latent space
import torch

# Z ~ N(0, I) — sample random latent vector
z = torch.randn(1, 128)  # 128-dim latent vector
generated_image = decoder(z)  # decoder maps Z → image space
```
- **What it demonstrates**: how generation works by sampling Z from a simple prior and decoding it.

## Worked Example

**The Théâtre D'opéra Spatial case (Colorado State Fair 2022):**
1. Video game designer Jason Allen used Midjourney (a diffusion-based model) to generate a fantastical sci-fi landscape.
2. The model had been trained on vast image datasets, learning P(image | text_prompt).
3. Given the text prompt, it sampled from the learned distribution to synthesize the winning image.
4. The controversy: was it art? The generative model "drew data from a model" of human artistic style.

**The Picasso Hidden Painting recovery:**
- X-rays of "The Old Guitarist" revealed older paintings underneath.
- Researchers trained a neural style transfer model on Picasso's "blue period" paintings.
- Applied transfer: X-ray image → colorized reconstruction of the lost artwork.
- Key: P(colored_image | xray_image, style=picasso_blue_period)

## Key Takeaways

1. Generative models learn the data distribution P(X); discriminative models learn decision boundaries P(Y|X).
2. Bayes' theorem is the formal bridge: generative modeling gives you P(X|Y), from which you can recover P(Y|X).
3. Deep generative models use latent variables Z to compress and sample from complex distributions.
4. VAEs, GANs, Transformers, and Diffusion Models are four major deep generative architectures — each with distinct trade-offs.
5. Core challenges: range of variation, data heterogeneity, size, and rate of change in training data.
6. Fake news, deepfakes, and chatbots are real-world consequences of powerful generative models — ethical vigilance is required.

## Connects To

- **Ch 2**: Neural network building blocks required for all generative model implementations
- **Ch 11**: VAEs — the explicit latent variable model introduced here
- **Ch 12–13**: GANs — the adversarial generative framework introduced here
- **Ch 15**: Diffusion Models — newest paradigm for high-quality image generation
- **Bayes' theorem**: foundational probability concept underlying all generative modeling
