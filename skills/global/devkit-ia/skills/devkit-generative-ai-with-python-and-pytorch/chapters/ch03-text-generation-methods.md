# Chapter 3: The Rise of Methods for Text Generation

## Core Idea
Text generation requires representing words numerically (embeddings) and modeling sequential probabilities (language models). This chapter builds from sparse BoW representations to dense Word2Vec/GloVe embeddings to LSTM-based character language models, establishing the decoding strategies (greedy, beam search, sampling, top-k) still used in modern LLMs.

## Frameworks Introduced

- **Bag of Words (BoW)**:
  - When to use: baseline text classification; when word order doesn't matter.
  - How: (1) define vocabulary V, (2) choose occurrence metric (binary/count/TF-IDF), (3) represent each document as a |V|-dim vector.
  - Limitations: loses word order and context; extremely sparse; vocabulary-bound.

- **Word2Vec (Mikolov et al.)**:
  - When to use: when you need dense semantic embeddings to capture word similarity.
  - Two architectures:
    - **CBOW**: predict center word from context window — better for frequent words.
    - **Skip-gram**: predict context words from center word — better for rare words.
  - Training signal: maximize cosine similarity of co-occurring words in latent space.
  - Result: king − man + woman ≈ queen (linear algebraic structure in embedding space).

- **GloVe (Global Vectors)**:
  - When to use: when Word2Vec misses global co-occurrence statistics.
  - How: factorizes the global word co-occurrence matrix; combines local context (Word2Vec) with corpus-wide statistics.

- **FastText**:
  - When to use: languages with rich morphology, or when OOV words are common.
  - How: represents words as sums of character n-gram embeddings → handles unseen words at inference.

- **Contextual Representations (ELMo/BERT-style)**:
  - When to use: tasks where the same word has different meanings in context ("bank").
  - How: deep bidirectional LM; each word's embedding is a function of its full sentence context.

- **Character-Level Language Model (LSTM)**:
  - When to use: unconstrained text generation; morphologically creative outputs.
  - How: tokenize at char level → embed → LSTM → softmax over vocab → train with cross-entropy → sample at inference.

- **Decoding Strategies**:
  - **Greedy**: always pick argmax P(w_t | context). Fast; repetitive.
  - **Beam Search**: keep top-k sequences at each step; better quality; still deterministic.
  - **Sampling**: sample w_t ~ P(w_t | context). Diverse; can be incoherent.
  - **Temperature**: scale logits by 1/T before softmax. T<1 → sharper (more confident); T>1 → flatter (more random).
  - **Top-k Sampling**: sample from only the top-k tokens; best of sampling + beam search.

## Key Concepts

- **Sparse Representation**: BoW vector with |V| dimensions, mostly zeros
- **Dense Representation**: Word2Vec/GloVe/FastText embedding, typically 50–300 dims, all non-zero
- **TF-IDF**: term frequency × inverse document frequency — weights rare-but-discriminative words higher
- **Embedding Matrix**: V × D learnable lookup table; each row is a word's embedding
- **Language Model**: model that assigns probability P(w_t | w_1,...,w_{t-1}) to the next token
- **Perplexity**: exp(cross-entropy loss) — standard LM evaluation metric; lower is better
- **Vanishing Gradient (sequence)**: RNN fails to learn dependencies beyond ~10-20 steps; LSTM solves with gates
- **Temperature**: hyperparameter controlling sharpness of probability distribution at decoding
- **Top-k Sampling**: restrict next-token candidates to k highest-probability tokens before sampling
- **Character-level LM**: LM operating on characters rather than words; no OOV problem

## Mental Models

- Use **skip-gram** when you have limited data (rare words); use **CBOW** when you have large data (common words).
- Think of Word2Vec as "meaning from company" — a word's embedding is shaped by the words it appears with.
- Temperature is a "creativity dial": 0.5 = conservative/predictable, 1.0 = neutral, 2.0 = wild/random.
- Greedy decoding = always pick the most likely word; sampling = pick words probabilistically like a human would.

## Anti-patterns

- **BoW for sequence tasks**: loses word order entirely — don't use for generation or sentiment where order matters.
- **Greedy decoding for creative generation**: always produces the same output; leads to degenerate repetition ("The cat sat on the cat sat on...").
- **Very high temperature**: produces incoherent gibberish; keep T ≤ 1.5 for most tasks.
- **Word-level LM for morphologically rich languages**: high OOV rate; prefer character or subword tokenization.

## Code Examples

```python
from gensim.models import word2vec
import nltk

# Train skip-gram Word2Vec
tokenized_corpus = [nltk.word_tokenize(doc) for doc in norm_corpus]
w2v_model = word2vec.Word2Vec(
    tokenized_corpus,
    size=32,           # embedding dimensions
    window=20,         # context window size
    min_count=1,       # minimum word frequency
    sg=1,              # 1=skip-gram, 0=CBOW
    sample=1e-3,       # downsample frequent words
    iter=200
)

# Query semantic similarity
print(w2v_model.wv['sun'])          # 32-dim embedding vector
print(w2v_model.wv.most_similar(positive=['god']))  # closest words
```
- **What it demonstrates**: training a skip-gram Word2Vec model and querying semantic neighbors.

```python
# Greedy vs. sampling decoding in a character-level LM
def generate_text(n_chars, model, dataset, prompt_text="Hello",
                  mode="sampling", temperature=1.0):
    logits, h, c = model(input_ints, h, c)
    if mode == "greedy":
        next_char = dataset.vocab[torch.argmax(logits[0], dim=-1)]
    elif mode == "sampling":
        probs = F.softmax(logits[0] / temperature, dim=0).detach().cpu().numpy()
        next_char = np.random.choice(dataset.vocab, p=probs)
    return next_char
```
- **What it demonstrates**: the same model produces deterministic (greedy) or probabilistic (sampling) outputs depending on the decoding strategy.

## Worked Example

**Character-level LSTM language model trained on Kafka's "The Metamorphosis":**

Setup:
- Input: raw text, tokenized at character level
- Vocabulary: ~70 unique characters (letters, punctuation, spaces)
- Model: LSTM (embedding → 2-layer LSTM 256 units → linear → softmax)
- Training: predict next character given all previous characters; loss = cross-entropy

Prompt: `"What's happened to me?" he thought. It wasn't a dream. His`

Decoding comparison:
| Strategy | T | Output character sequence |
|---|---|---|
| Greedy | — | `...the the the the...` (degenerate repetition) |
| Sampling | 1.0 | `...room, but he was very strange...` (coherent, varied) |
| Sampling | 0.5 | `...he was very tired...` (safe, predictable) |
| Sampling | 2.0 | `...xQz!k, lm... ` (incoherent) |

Key lesson: Holtzman et al. showed humans don't select the highest-probability word at every step — real language has intrinsic randomness. Sampling + temperature matches human behavior better than greedy/beam search.

## Key Takeaways

1. Progress from BoW (sparse, orderless) → Word2Vec (dense, semantic) → Contextual (BERT-style) reflects the evolution of NLP representation.
2. Word2Vec's skip-gram trains by predicting context words from a center word — the embedding geometry captures analogy structure (king−man+woman=queen).
3. Language models assign P(w_t | w_1...w_{t-1}); LSTMs parameterize this with recurrent hidden state.
4. Decoding strategy is a critical choice: greedy = deterministic, sampling = stochastic, temperature controls the trade-off between coherence and diversity.
5. Top-k sampling is the practical sweet spot for generation: bounded randomness, no degenerate repetition.

## Connects To

- **Ch 2**: LSTM architecture from Ch 2 is applied here to language modeling
- **Ch 4**: Transformers replace LSTMs for NLP; attention mechanism overcomes LSTM's sequence length limits
- **Ch 5–6**: LLMs (GPT, LLaMA) generalize the language model framework to massive scale
- **Ch 7**: Prompt engineering builds on decoding intuitions from this chapter
