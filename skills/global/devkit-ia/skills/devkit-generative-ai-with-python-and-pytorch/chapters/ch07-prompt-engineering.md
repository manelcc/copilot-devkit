# Chapter 7: Prompt Engineering

## Core Idea
Prompt engineering is the practice of designing inputs to LLMs to elicit specific, reliable, and high-quality outputs — without changing model weights. It spans from basic formatting (clear instructions, delimiters, system prompts) through advanced reasoning techniques (Chain-of-Thought, Tree-of-Thought, ReAct) and provides the fastest path to steering LLM behavior for a task.

## Frameworks Introduced

- **Zero-shot Prompting**:
  - When to use: when a capable LLM can likely solve the task without examples.
  - How: state the task clearly with no examples. "Summarize the following text: {text}"
  - Works because: large LLMs have seen enough task patterns during pre-training.

- **Few-shot Prompting**:
  - When to use: when zero-shot produces inconsistent format or quality.
  - How: provide 2–5 (input, output) examples before the actual query.
  - Pattern: `Q: {example1_input}\nA: {example1_output}\n...\nQ: {actual_input}\nA:`
  - Key insight: examples implicitly define output format, style, and scope.

- **Chain-of-Thought (CoT) Prompting**:
  - When to use: math reasoning, multi-step logic, causal inference.
  - How: append "Let's think step by step." to the prompt, or show worked reasoning in few-shot examples.
  - Why it works: forces the LM to generate intermediate reasoning steps, reducing errors from "shortcut" token prediction.
  - Zero-shot CoT: just add "Let's think step by step." to any prompt.

- **ReAct (Reasoning + Acting)**:
  - When to use: agentic tasks requiring external tool use (web search, code execution, database lookup).
  - How: alternate Thought (reasoning step) → Action (external operation) → Observation (operation result) in the prompt.
  - Pattern: `Thought: I need to look up X\nAction: Search[X]\nObservation: X = {result}\nThought: ...`

- **Tree of Thought (ToT)**:
  - When to use: complex problems benefiting from exploring multiple reasoning paths and backtracking.
  - How: prompt the model to generate k candidate next steps, evaluate each, continue promising paths, prune dead ends.
  - More compute than CoT; better for planning tasks (puzzles, multi-step strategies).

- **Self-Consistency / Majority Voting**:
  - When to use: improve reliability on reasoning tasks without extra training.
  - How: sample the model k times with temperature > 0, take the majority vote answer.
  - Why: different reasoning paths can reach the same correct answer; averaging reduces variance.

- **System Instructions**:
  - When to use: whenever you want a persistent persona, role, or behavioral constraint across a conversation.
  - How: set via the system message field: `{"role": "system", "content": "You are a..."}`
  - Effect: constrains all subsequent model responses; can change reading level, domain focus, or safety posture.

## Key Concepts

- **Prompt Design**: the full specification of a prompt — instruction + context + examples + output format hint
- **Delimiter**: markers (```, """, ###) separating instruction from context to prevent prompt injection
- **Temperature**: inference-time randomness control (0 = deterministic, 1+ = creative)
- **Top-p (nucleus sampling)**: sample from smallest token set whose cumulative probability exceeds p; alternative to top-k
- **Completion tokens**: max output tokens; controls cost when using token-priced LLM APIs
- **Guardrails**: safety filters (Llama Guard, NeMo Guardrails) applied to LLM outputs to block harmful content
- **Needle-in-a-Haystack test**: benchmark evaluating LLM's ability to retrieve a specific fact from a very large context
- **Hallucination**: model confidently generating false information; reduced by providing explicit context + CoT
- **Context window**: maximum tokens the model can attend to in one call; use chunking for longer documents

## Mental Models

- Use zero-shot first; if quality is poor, try few-shot; if reasoning fails, add CoT; if multiple steps needed, use ReAct.
- Think of system instructions as "setting the stage" — they define who the model is, not just what it does.
- Temperature is not the same as accuracy: low temperature = consistent but conservative; high = creative but unpredictable.
- Delimiters prevent the model from treating your context as instructions — always use them when including untrusted text.

## Anti-patterns

- **Vague instructions without context**: "Tell me about transformers" → ambiguous. Always specify scope and output format.
- **No delimiters around user-provided text**: exposes you to prompt injection attacks.
- **Over-relying on CoT for simple tasks**: adds latency and tokens without benefit for factual lookups or direct retrieval.
- **High temperature for factual tasks**: increases hallucination rate; use T≈0 for factual/retrieval, T≈0.7-0.9 for creative.

## Code Examples

```python
# Prompt engineering via Ollama-compatible OpenAI API
import openai
import os

client = openai.OpenAI(
  base_url="http://localhost:11434/v1",
  api_key=os.environ.get("OLLAMA_API_KEY", "local-dev")
)

def get_completion(prompt, system_instruction="You are a helpful assistant.", model="llama3"):
    response = client.chat.completions.create(
        model=model,
        messages=[
            {"role": "system", "content": system_instruction},
            {"role": "user", "content": prompt}
        ],
        temperature=0.7
    )
    return response.choices[0].message.content

# Zero-shot with delimiter to prevent injection
text = "How do I calculate the area of a circle?"
prompt = f"```{text}```\nProvide the formula and 2 worked examples."
print(get_completion(prompt))
```
- **What it demonstrates**: clean prompt structure with delimiter, system instruction, and Ollama local LLM via OpenAI-compatible API.

```python
# Chain-of-Thought: zero-shot CoT via "Let's think step by step"
cot_prompt = """
Q: A train travels 120km in 2 hours then 80km in the next hour. What is the average speed?
Let's think step by step.
"""
print(get_completion(cot_prompt))
# Model generates: Step 1: total distance = 120+80 = 200km; Step 2: total time = 3h; Step 3: avg = 200/3 ≈ 66.7 km/h
```
- **What it demonstrates**: zero-shot CoT forces intermediate reasoning, preventing the model from jumping to a wrong answer.

## Worked Example

**System instructions shifting reading level:**

```
system_instruction_1 = "You are an experienced teacher for primary school tasked with helping students with their questions"
system_instruction_2 = "You are an experienced teacher for high school tasked with helping students with their questions"

question = "What is quantum entanglement?"

# Primary school response: short, analogies, no jargon
# High school response: covers wave functions, non-locality, experimental evidence
```

Same model, same question, radically different responses — system instructions gate the model's knowledge presentation style. This is the foundation of persona-based chatbots and domain-scoped assistants.

**Prompting task comparison (summarization):**

| Strategy | Prompt | Output Quality |
|---|---|---|
| Vague | "Summarize this." | Too long or too short; wrong format |
| Clear + format | "Summarize in 3 bullet points, each ≤15 words." | Consistent, usable output |
| Few-shot | Show 2 example summaries before asking | Matches example style and length |
| CoT + format | "First identify key claims. Then condense each to ≤15 words." | Higher precision on complex texts |

## Key Takeaways

1. Prompt engineering = the fastest way to improve LLM output quality without changing weights — always try it before fine-tuning.
2. Escalation ladder: Zero-shot → Few-shot → CoT → ReAct/ToT. Move up only when quality at lower levels is insufficient.
3. CoT ("Let's think step by step") significantly improves multi-step reasoning at zero cost (just tokens).
4. System instructions set persistent persona and behavioral constraints; delimiters protect against prompt injection.
5. Self-consistency (majority vote over k samples) improves reasoning reliability at the cost of k× inference compute.

## Connects To

- **Ch 3**: decoding strategies (temperature, top-k, top-p) are the inference-time parameters controlled here
- **Ch 5**: instruction fine-tuning trained LLMs to respond to the structured prompt formats used here
- **Ch 8**: LangChain prompt templates and RAG build on prompt engineering fundamentals
- **Ch 10**: advanced prompting (ReAct, ToT) directly enables agentic AI patterns
