# Chapter 2: Building Blocks of Deep Neural Networks

## Core Idea
Modern generative models are built on a foundation of neural architectures — perceptrons, CNNs, RNNs/LSTMs, and Transformers — trained through backpropagation with PyTorch's automatic differentiation (autograd). Choosing the right architecture and optimizer is as important as choosing the generative model type.

## Frameworks Introduced

- **Backpropagation + Autograd**:
  - When to use: always — it's the universal training mechanism for neural networks.
  - How: compute forward pass → compute loss → call `loss.backward()` → gradients flow backward through the computational graph → optimizer updates weights.
  - PyTorch implements this via a dynamic computational graph (tape-based).

- **Convolutional Neural Networks (CNNs)**:
  - When to use: any spatial/grid-structured data (images, spectrograms).
  - How: apply learned filters across spatial positions (weight-sharing). Stack Conv→ReLU→Pool layers. Use skip connections (ResNet) for very deep nets.
  - Key insight: local receptive fields + weight sharing = translation invariance.

- **Recurrent Networks (RNNs/LSTMs)**:
  - When to use: sequential/temporal data where order matters (text, time series, audio).
  - How: maintain hidden state h_t = f(h_{t-1}, x_t). LSTMs add cell state and gates to control memory retention/forgetting.
  - Key insight: LSTMs solve vanishing gradient problem in long sequences via gated memory.

- **Transformers**:
  - When to use: any sequence task where long-range dependencies matter; now also images (ViT).
  - How: self-attention scores all pairwise token relationships simultaneously. Multi-head attention captures different relationship types. No recurrence → parallelizable.
  - Key equation: Attention(Q,K,V) = softmax(QKᵀ/√d_k)·V

- **ADAM Optimizer**:
  - When to use: default choice for deep generative models.
  - How: adaptive learning rate per parameter using first (momentum) and second (variance) moment estimates. Parameters: lr, β₁=0.9, β₂=0.999, ε=1e-8.

- **Xavier Initialization**:
  - When to use: when initializing weights for sigmoid/tanh activations.
  - How: W ~ Uniform(-√(6/(fan_in+fan_out)), +√(6/(fan_in+fan_out))). Keeps variance stable across layers.
  - For ReLU: use Kaiming/He initialization instead.

## Key Concepts

- **Perceptron / TLU**: single linear unit with threshold activation; basis of all neural networks
- **Activation Function**: non-linearity after linear transform — ReLU (default), Sigmoid, Tanh, GELU
- **Vanishing Gradient**: gradients shrink exponentially in deep nets with sigmoid; solved by ReLU + skip connections
- **Explaining Away**: deep couplings between parameters make inference intractable; addressed by careful architecture and normalization
- **Receptive Field**: region of input that influences a given neuron in a CNN
- **Weight Sharing**: same filter weights applied at every spatial position in a CNN
- **Hidden State**: RNN memory vector carrying information across time steps
- **Attention**: mechanism scoring relevance of all input tokens to each output position
- **Batch Normalization**: normalizes layer outputs to stabilize training of deep nets
- **Gradient Descent variants**: SGD → Momentum → RMSProp → ADAM (progressively more adaptive)

## Mental Models

- Use **CNN** when the input has spatial structure (images); use **RNN/LSTM** for ordered sequences; use **Transformer** for both (with sufficient data).
- Think of LSTM as a "leaky memory" with valves — forget gate decides what to discard, input gate decides what to store, output gate decides what to expose.
- ADAM = "gradient descent with GPS" — it adapts the learning rate per parameter based on recent gradient history.
- Xavier init: "give the network the best chance to start gradient flow" — neither saturated nor zeroed weights.

## Anti-patterns

- **Using sigmoid activations in deep nets**: causes vanishing gradients; prefer ReLU/GELU.
- **Ignoring initialization**: random initialization without Xavier/He can freeze or explode gradients before training starts.
- **Not retaining graph when needed**: calling `backward()` without `retain_graph=True` releases the computation graph; subsequent backward calls fail.
- **Stacking RNNs without LSTM/GRU for long sequences**: plain RNNs forget context beyond ~10-20 time steps.

## Code Examples

```python
import torch

# PyTorch autograd: compute and inspect gradients
x = torch.ones(2, 2, requires_grad=True)
y = x + 2
z = 3 * y**2
out = z.mean()
y.retain_grad()  # keep intermediate gradients
out.backward(retain_graph=True)

print("Gradient dz/dy:", y.grad)
# Output: tensor([[4.5000, 4.5000], [4.5000, 4.5000]])
```
- **What it demonstrates**: PyTorch's tape-based autograd — every operation is recorded; `backward()` computes all gradients simultaneously.

```python
import torch.nn as nn

# Transformer self-attention block
class SelfAttention(nn.Module):
    def __init__(self, d_model, n_heads):
        super().__init__()
        self.attn = nn.MultiheadAttention(d_model, n_heads, batch_first=True)
        self.norm = nn.LayerNorm(d_model)

    def forward(self, x):
        attn_out, _ = self.attn(x, x, x)  # Q=K=V=x (self-attention)
        return self.norm(x + attn_out)     # residual connection + layer norm
```
- **What it demonstrates**: self-attention scores all token pairs; residual + LayerNorm stabilizes deep transformer stacks.

## Reference Tables

| Architecture | Input Type | Key Mechanism | Parallelizable | Long-range Deps |
|---|---|---|---|---|
| MLP | Tabular/flat | Linear layers + activations | Yes | No |
| CNN | Spatial (images) | Learned spatial filters | Yes | Limited |
| RNN/LSTM | Sequential | Hidden state + gates | No | Moderate (LSTM) |
| Transformer | Any sequence | Self-attention | Yes | Full context |

| Optimizer | Adaptive LR | Momentum | Notes |
|---|---|---|---|
| SGD | No | Optional | Simple; needs LR schedule |
| Momentum SGD | No | Yes | Smooths oscillation |
| RMSProp | Yes (variance) | No | Good for RNNs |
| ADAM | Yes (1st+2nd moment) | Yes | Default for most deep nets |

## Worked Example

**AlexNet architecture** (first CNN to win ImageNet at scale):
```
Input: 224×224×3 image
Conv1: 96 filters, 11×11, stride 4 → 55×55×96  + ReLU + MaxPool
Conv2: 256 filters, 5×5, pad 2   → 27×27×256  + ReLU + MaxPool
Conv3: 384 filters, 3×3, pad 1   → 13×13×384  + ReLU
Conv4: 384 filters, 3×3, pad 1   → 13×13×384  + ReLU
Conv5: 256 filters, 3×3, pad 1   → 13×13×256  + ReLU + MaxPool
Flatten → FC 4096 → Dropout(0.5) → FC 4096 → Dropout(0.5) → FC 1000 → Softmax
```
Key innovations: ReLU (replaced sigmoid), Dropout (regularization), data augmentation, GPU training. This blueprint influenced all subsequent CNN-based generative models (DC-GAN, VAE encoders, etc.).

## Key Takeaways

1. PyTorch's autograd automatically computes gradients via a dynamic computational graph — always use `requires_grad=True` on learnable parameters.
2. CNN for spatial data; LSTM/RNN for sequences; Transformer for both — pick by data structure, not by trend.
3. ReLU + ADAM + Xavier init is a safe default starting configuration for most generative model experiments.
4. Vanishing gradients are the core training pathology — addressed by ReLU, skip connections (ResNet), and careful initialization.
5. Self-attention's key advantage: it sees the full context window at once, unlike RNNs which process tokens one at a time.

## Connects To

- **Ch 1**: architectures here are the "implementation" of the generative model types introduced there
- **Ch 3**: RNNs/LSTMs used for character-level language models and early text generation
- **Ch 4**: Transformers are the foundation of all subsequent NLP and LLM chapters
- **Ch 11**: VAE uses MLP/CNN encoder-decoder stacks built from these blocks
- **Ch 12–13**: GAN discriminators and generators are CNNs built from these primitives
