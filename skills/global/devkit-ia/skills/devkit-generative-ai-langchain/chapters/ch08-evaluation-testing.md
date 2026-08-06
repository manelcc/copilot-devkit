# Chapter 8: Evaluation and Testing

## Core Idea
LLM evaluation is an organizational and technical challenge — there is no single metric, different stakeholders need different views, and evaluation must be built into the development lifecycle from day one, not bolted on before deployment.

## Frameworks Introduced

- **LLM Evaluation Stack**: 4 layers — (1) Automated: string/regex matching, LLM-as-judge, structured criteria; (2) Human-in-the-loop: annotation, preference ranking; (3) System-level: end-to-end task success, trajectory; (4) Offline benchmarking: RAGAS, LangSmith datasets, HuggingFace Evaluate
  - When to use: build all 4 layers; automated for CI/CD gates, human for production monitoring
  - How: start with automated LLM-as-judge; add trajectory tracking with LangSmith; offline benchmark periodically

- **LLM-as-Judge (Criteria Evaluator)**: Second LLM evaluates first LLM's output against criteria (correctness, conciseness, friendliness, etc.) — returns score (0/1) + reasoning chain
  - When to use: subjective quality dimensions that can't be captured by string matching
  - How: `load_evaluator("criteria", criteria={"conciseness": "..."}, llm=eval_llm)` → `evaluator.evaluate_strings(prediction=..., input=...)`

- **Trajectory Evaluation**: Compare actual sequence of agent steps against expected reference trajectory; partial credit for completing some steps correctly
  - When to use: complex agents where final answer correctness alone misses important failures (wrong tool used, unnecessary steps, missed tool calls)
  - How: record `trajectory = [node_name_1, tool_name, ...]` per run → `trajectory_subsequence(actual, expected)` scoring function → LangSmith `aevaluate()`

- **RAGAS (RAG Assessment)**: Framework with 4 specialized metrics for RAG quality
  - When to use: any RAG system before production release and ongoing monitoring
  - How: `from ragas.metrics import faithfulness, answer_relevancy, context_precision, context_recall` → `evaluate(dataset, metrics=[...])`

- **Stakeholder Matrix for Evaluation**: Map metrics to stakeholder groups — users (satisfaction, relevance, coherence), technical (latency, token cost, tool accuracy), business (KPIs, ROI), regulatory (compliance, bias, safety)
  - When to use: defining evaluation framework for a new project; resolving disputes about what "good" means
  - How: create cross-functional working group → weighted scoring matrix → governance committee for ongoing decisions

## Key Concepts

- **Task Performance Evaluation**: Does the agent correctly complete its intended task? Measures completion rate and output quality; foundation metric
- **Tool Usage Evaluation (T-Eval framework)**: Plan → Reason → Retrieve tool → Understand docs → Format call → Review result — 6 distinct measurable steps
- **Faithfulness (RAGAS)**: Is every claim in the answer supported by the retrieved context? Score 0–1
- **Answer Relevancy (RAGAS)**: Does the answer directly address the question? Score 0–1
- **Context Precision (RAGAS)**: What fraction of retrieved chunks were actually useful? Score 0–1
- **Context Recall (RAGAS)**: What fraction of needed information was retrieved? Score 0–1
- **LangSmith**: LangChain's evaluation and observability platform; creates datasets of examples, runs evaluators against them, tracks experiments over time
- **AgentBench / TaskBench**: Multi-domain agent benchmarks; GPT-4 ~80% single-tool, ~50% end-to-end task automation
- **JsonValidityEvaluator**: Built-in LangChain evaluator for validating JSON output structure; returns score 0/1 + error location
- **Evaluation Governance**: Cross-functional working group (technical + domain + users) defining criteria, ownership, and decision-making for LLM quality; prevents "evaluation drift"

## Mental Models

- **"Build consensus before building evaluations"**: Technical metrics alone miss stakeholder needs; invest in agreement on what "good" means before coding evaluation harness
- **Evaluate 3 dimensions in every agent**: Final output quality (did it answer correctly?) + trajectory quality (did it take the right path?) + efficiency (latency, tokens, tool calls)
- **"LLM-as-judge requires a better judge"**: The same model that generated the answer is a poor evaluator of it; use a more capable model or a different model family for evaluation
- **Offline benchmarking ≠ production monitoring**: Dataset benchmarks tell you about known failure modes; production monitoring catches new ones; run both

## Anti-patterns

- **Single-metric evaluation ("just check accuracy")**: Accuracy misses safety, hallucination, tool misuse, cost, and user satisfaction — use multi-dimensional evaluation always
- **Evaluating only final output, ignoring trajectory**: An agent that reaches correct answer via wrong tools (e.g., hallucinating tool results instead of calling the tool) will pass final-output evaluation but fail in production
- **Manual-only evaluation**: Doesn't scale; gates get skipped under deadline pressure; automate criteria evaluation in CI/CD, reserve human review for edge cases and periodic audits
- **Using the same LLM as both generator and judge**: Circular validation — the model has same biases; use a different model or family for evaluation

## Code Examples

```python
# LLM-as-Judge with built-in criteria
from langchain.evaluation import load_evaluator
from langchain_openai import ChatOpenAI

eval_llm = ChatOpenAI(model="gpt-4o", temperature=0)

# Built-in criteria: conciseness, harmfulness, misogyny, criminality, etc.
conciseness_evaluator = load_evaluator("criteria", 
    criteria="conciseness", llm=eval_llm)

result = conciseness_evaluator.evaluate_strings(
    prediction="A normal blood pressure is around 120/80 mmHg.",
    input="What is a normal blood pressure reading?"
)
# result = {'reasoning': '...', 'value': 'Y', 'score': 1}
```
- **What it demonstrates**: Automated quality gate using LLM-as-judge with reasoning

```python
# Custom criteria evaluator
custom_criteria = {
    "medical_accuracy": "Is the response medically accurate and does it avoid dangerous advice?",
    "appropriate_referral": "Does the response appropriately recommend consulting a doctor when needed?"
}

medical_evaluator = load_evaluator("criteria", criteria=custom_criteria, llm=eval_llm)
result = medical_evaluator.evaluate_strings(
    prediction=agent_response, input=user_question
)
```
- **What it demonstrates**: Domain-specific custom criteria for medical/regulated applications

```python
# RAGAS evaluation for RAG system
from ragas import evaluate
from ragas.metrics import faithfulness, answer_relevancy, context_precision, context_recall
from datasets import Dataset

# Build evaluation dataset
eval_data = {
    "question": ["What is RAG?", "How does LangChain work?"],
    "answer": [generated_answer_1, generated_answer_2],
    "contexts": [[retrieved_chunks_1], [retrieved_chunks_2]],
    "ground_truth": [reference_answer_1, reference_answer_2]
}
dataset = Dataset.from_dict(eval_data)
results = evaluate(dataset, metrics=[faithfulness, answer_relevancy, context_precision, context_recall])
print(results)  # DataFrame with per-metric scores
```
- **What it demonstrates**: Four-metric RAGAS evaluation suite for RAG quality

```python
# Trajectory evaluation with LangSmith
from langsmith import Client

def trajectory_subsequence(outputs: dict, reference_outputs: dict) -> float:
    """Score: fraction of expected steps actually taken in correct order."""
    ref = reference_outputs["trajectory"]
    actual = outputs["trajectory"]
    i = j = 0
    while i < len(ref) and j < len(actual):
        if ref[i] == actual[j]: i += 1
        j += 1
    return i / len(ref) if ref else 1.0

client = Client()
results = await client.aevaluate(
    run_agent_function,
    data="my-trajectory-dataset",
    evaluators=[trajectory_subsequence],
    experiment_prefix="healthcare-agent-v2"
)
```
- **What it demonstrates**: Custom trajectory evaluator and LangSmith experiment tracking

## Reference Tables

| RAGAS Metric | What It Measures | Failure Signal |
|---|---|---|
| Faithfulness | Claims supported by context | LLM fabricating beyond context |
| Answer Relevancy | Answer addresses the question | Off-topic responses |
| Context Precision | Retrieved chunks were useful | Retrieval returning noise |
| Context Recall | All needed info was retrieved | Missing relevant documents |

| Evaluator Type | When to Use | Cost |
|---|---|---|
| String/regex match | Exact format validation (JSON, code) | Low |
| LLM-as-judge (criteria) | Subjective quality (tone, accuracy) | Medium |
| Human annotation | Ground truth creation, edge cases | High |
| Trajectory evaluation | Complex multi-step agent correctness | Medium |
| Benchmark (AgentBench/RAGAS) | Periodic regression testing | High |

| Stakeholder | Key Metrics |
|---|---|
| End users | Satisfaction, relevance, coherence, response time |
| Technical | Latency p50/p99, token cost, tool accuracy, error rate |
| Business | Task completion rate, cost per query, ROI, user adoption |
| Regulatory | Bias scores, safety test pass rate, compliance audit trail |

## Worked Example

**Complete evaluation pipeline for a healthcare Q&A agent**

Scenario: Agent answers medical questions using a clinical knowledge RAG system.

```python
# Stage 1: Automated quality gate (runs in CI/CD)
from langchain.evaluation import load_evaluator
from langchain_openai import ChatOpenAI

eval_llm = ChatOpenAI(model="gpt-4o", temperature=0)
criteria = {
    "medical_accuracy": "Response is medically accurate, does not contradict evidence-based medicine",
    "safety": "Response does not give dangerous advice; recommends consulting doctor for serious symptoms",
    "clarity": "Response is written in plain language a patient can understand"
}

evaluator = load_evaluator("criteria", criteria=criteria, llm=eval_llm)

# Run against test set of 100 question-answer pairs
results = [evaluator.evaluate_strings(prediction=ans, input=q) 
           for q, ans in test_set]

# Gate: fail CI if any safety score < 1 or avg accuracy < 0.9
assert all(r["score"] == 1 for r in results if "safety" in r["criteria"])

# Stage 2: RAGAS for RAG quality
ragas_results = evaluate(dataset, metrics=[faithfulness, answer_relevancy, 
                                           context_precision, context_recall])
assert ragas_results["faithfulness"] > 0.85  # Less than 15% hallucination

# Stage 3: Trajectory check (did agent call MedicalDB tool before responding?)
def safety_trajectory(outputs, reference):
    return 1.0 if "MedicalDatabaseSearch" in outputs["trajectory"] else 0.0
```

Result: 3-layer evaluation ensures accuracy, RAG quality, and correct tool usage before deployment.

## Key Takeaways

1. Build evaluation consensus first — define what "good" means across user/technical/business/regulatory stakeholders before coding metrics
2. LLM-as-Judge via `load_evaluator("criteria", criteria=..., llm=eval_llm)` is the scalable path for subjective quality dimensions
3. RAGAS 4-metric suite (faithfulness + answer relevancy + context precision + context recall) is the standard evaluation for any RAG system
4. Always evaluate trajectory in addition to final output — wrong process to correct answer = silent production failure
5. Automate CI/CD evaluation gates; reserve human review for edge cases and regulatory audits
6. Use a different (ideally more capable) model family for evaluation than the one you're evaluating

## Connects To

- **Ch4**: RAGAS provides the evaluation framework for all RAG systems built in Ch4
- **Ch5/6**: Trajectory evaluation is especially critical for multi-tool agents and multi-agent systems
- **Ch9**: LangSmith combines evaluation (Ch8) with production observability; dataset evaluation feeds back into deployment monitoring
- **AgentBench paper**: Liu et al. 2023 — 8-environment agent evaluation framework; established baseline that proprietary models dominate
