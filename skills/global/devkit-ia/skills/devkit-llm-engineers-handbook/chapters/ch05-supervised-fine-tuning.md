# Chapter 5: Supervised Fine-Tuning

## Core Idea
SFT performance is governed less by raw model choice and more by dataset quality, formatting discipline, and training configuration trade-offs.

## Frameworks Introduced
- **Instruction Dataset Quality Loop**
  - When to use: Building domain-capable assistants.
  - How: Curate, deduplicate, decontaminate, evaluate, augment.
- **PEFT Decision Framework (Full FT vs LoRA vs QLoRA)**
  - When to use: Resource-constrained adaptation.
  - How: Choose method by memory budget, target quality, and latency constraints.
- **Training Knob Prioritization**
  - When to use: Hyperparameter search with limited cycles.
  - How: Tune learning rate, batch strategy, sequence length, and epochs in controlled experiments.

## Key Concepts
- **SFT**: Supervised adaptation on instruction-response pairs.
- **Data curation**: Filtering to preserve relevance and quality.
- **Deduplication**: Removal of near-duplicate samples.
- **Decontamination**: Avoid train-eval overlap leakage.
- **LoRA / QLoRA**: Parameter-efficient tuning approaches.
- **Chat template**: Prompt formatting contract for dialogue models.

## Mental Models
Use **data quality before parameter count** as default priority. Treat hyperparameter tuning as **evidence-driven iteration**, not intuition.

## Anti-patterns
- **Blindly increasing epochs**: Often overfits weak data.
- **Ignoring instruction format consistency**: Causes unstable behavior at inference.

## Worked Example
A domain support bot SFT workflow:
1. Assemble seed instruction dataset from QA logs.
2. Remove duplicates and contaminated examples.
3. Normalize to a single chat template.
4. Train with QLoRA for memory efficiency.
5. Compare checkpoints on held-out task set before promotion.

## Key Takeaways
1. Data governance is central to SFT success.
2. PEFT methods enable practical adaptation on modest hardware.
3. Evaluation gates should decide promotion, not training loss alone.

## Connects To
- **Ch 6**: Preference alignment refines behavior after SFT.
- **Ch 8**: Quantization/inference constraints affect tuning choices.
