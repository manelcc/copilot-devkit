# Chapter 2: First Steps with LangChain

## Core Idea
LangChain's LCEL pipe syntax (`prompt | model | parser`) is the universal pattern for composing LLM applications — every component from any provider is interchangeable, enabling model-agnostic development without rewriting business logic.

## Frameworks Introduced

- **LCEL (LangChain Expression Language)**: Declarative pipe-based composition where any `Runnable` can be chained with `|`
  - When to use: whenever building any LLM-powered chain or workflow; preferred over manual orchestration
  - How: define prompt → connect with `|` to model → connect with `|` to parser; use `invoke()`, `stream()`, or `batch()`

- **RunnablePassthrough / RunnableParallel**: Tools for managing data flow in multi-step chains
  - When to use: need to pass original input forward while adding new keys, or run multiple chains simultaneously
  - How: `RunnablePassthrough.assign(key=chain)` adds results without losing prior state; `RunnableParallel(a=chain1, b=chain2)` runs concurrently

- **Local vs Cloud Model Decision Framework**: 5-factor evaluation for model deployment strategy
  - When to use: architecture scoping, cost analysis, privacy review
  - How: evaluate privacy constraints → cost sensitivity → latency requirements → hardware availability → model quality needed; local wins for all strict-privacy or high-volume-predictable scenarios

## Key Concepts

- **PromptTemplate**: Reusable, testable prompt definitions with variable substitution; separates template logic from business logic
- **ChatPromptTemplate**: Multi-role prompt structure `[("system", ...), ("user", "{var}")]` for chat models
- **MessagesPlaceholder**: Inserts a runtime list of messages (e.g., conversation history) into a `ChatPromptTemplate`
- **StrOutputParser**: Converts `AIMessage` to plain string; most common final step in text chains
- **JsonOutputParser / PydanticOutputParser**: Parses structured output into dict or Pydantic model; adds format instructions to prompt
- **Temperature**: Controls randomness: 0.0–0.3 for factual/consistent output; 0.7+ for creative generation
- **Top-p (Nucleus Sampling)**: Cumulative probability threshold for token selection; 0.9 = diverse, 0.5 = focused
- **Ollama**: Local model server for running open-source models without API keys; integrates via `ChatOllama`
- **HuggingFacePipeline**: Runs HuggingFace models locally via `transformers` pipeline; first run downloads model weights
- **Streaming**: `chain.stream(input)` yields tokens as generated; critical for responsive UIs
- **Extended Thinking (Claude)**: `thinking={"type": "enabled", "budget_tokens": 15000}` allocates tokens to chain-of-thought before the final answer

## Mental Models

- Think of LCEL as **Unix pipes for LLMs**: each component receives output from the previous, transforms it, passes it forward — any stage is independently swappable
- Use **`RunnablePassthrough.assign()`** when you need to "accumulate" context: add story, then add analysis of story, without losing the original topic
- Use **temperature as a dial**: 0.0 = deterministic/factual, 0.5 = balanced, 1.0 = creative/diverse; always start at 0.1 for task-specific LLM calls in production

## Anti-patterns

- **Hardcoding prompts as f-strings**: Makes them untestable, hard to maintain, hard to version; use `PromptTemplate` always
- **Committing API keys to git**: Use `config.py` + `.gitignore` or environment variables; never inline secrets in source
- **Reading model output as plain string without a parser**: Direct `AIMessage.content` access couples code to message format; always chain an output parser
- **Single temperature for all tasks**: Creative and factual tasks need different values; configure per chain, not globally

## Code Examples

```python
# Full LCEL chain with structured output
from langchain_openai import ChatOpenAI
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser

prompt = ChatPromptTemplate.from_messages([
    ("system", "You are a concise technical writer."),
    ("user", "Summarize in 2 sentences: {topic}")
])
model = ChatOpenAI(model="gpt-4o-mini", temperature=0.1)
chain = prompt | model | StrOutputParser()

# invoke: single call; stream: token-by-token; batch: parallel inputs
result = chain.invoke({"topic": "vector databases"})
for token in chain.stream({"topic": "vector databases"}): print(token, end="")
results = chain.batch([{"topic": "RAG"}, {"topic": "agents"}])
```
- **What it demonstrates**: Provider-agnostic LCEL chain with all three invocation modes

```python
# Multi-step chain with RunnablePassthrough.assign
from langchain_core.runnables import RunnablePassthrough

story_chain = prompt | model | StrOutputParser()
analysis_prompt = ChatPromptTemplate.from_template("Critique this: {story}")
analysis_chain = analysis_prompt | model | StrOutputParser()

pipeline = RunnablePassthrough.assign(story=story_chain).assign(
    analysis=analysis_chain
)
result = pipeline.invoke({"topic": "a rainy day"})
# result has keys: topic, story, analysis
```
- **What it demonstrates**: Accumulating keys across steps without losing prior state

```python
# Local model with Ollama (identical LCEL interface)
from langchain_ollama import ChatOllama
llm = ChatOllama(model="deepseek-r1:1.5b", temperature=0)
local_chain = prompt | llm | StrOutputParser()
```
- **What it demonstrates**: LCEL is model-agnostic — swap cloud model for local with one line

## Reference Tables

| Parameter | Range | Use Case |
|---|---|---|
| `temperature` | 0.0–2.0 (Gemini), 0.0–1.0 others | Low: factual; High: creative |
| `top_p` | 0.0–1.0 | 0.5 = focused; 0.9 = exploratory |
| `top_k` | 1–100 | 1–10 = deterministic; 50+ = diverse |
| `max_tokens` | model-specific | Cost control + length limits |
| `presence_penalty` | -2.0–2.0 | Reduce repetition in long text |

| Provider | Key Env Var | Free Tier |
|---|---|---|
| OpenAI | `OPENAI_API_KEY` | No |
| Anthropic | `ANTHROPIC_API_KEY` | No |
| Google AI | `GOOGLE_API_KEY` | Yes |
| HuggingFace | `HUGGINGFACEHUB_API_TOKEN` | Yes |
| Ollama (local) | None | Yes |

## Worked Example

**Building a two-stage analysis chain**

Goal: Given a topic, generate a story, then critique it — preserving all outputs.

```python
from langchain_openai import ChatOpenAI
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough

llm = ChatOpenAI(model="gpt-4o-mini", temperature=0.7)

story_prompt = ChatPromptTemplate.from_template("Write a short story about: {topic}")
critique_prompt = ChatPromptTemplate.from_template("Critique this story critically: {story}")

story_chain = story_prompt | llm | StrOutputParser()
critique_chain = critique_prompt | llm | StrOutputParser()

pipeline = RunnablePassthrough.assign(story=story_chain).assign(critique=critique_chain)
result = pipeline.invoke({"topic": "a lonely robot"})

# result = {"topic": "...", "story": "...", "critique": "..."}
```

This pattern scales to any number of stages: add `.assign(next_step=chain)` for each step. The topic never gets lost, each step can access all prior outputs via the accumulated dict.

## Key Takeaways

1. LCEL's `|` pipe is the universal composition primitive — use it for every chain, it gives you streaming, batching, and async for free
2. `ChatPromptTemplate.from_messages([("system",...), ("user","{var}")])` is the production-ready prompt pattern; `MessagesPlaceholder` inserts runtime conversation history
3. Set `temperature=0.1` for deterministic/factual calls; `temperature=0.7+` for creative generation — never share a single temperature across different task types
4. `RunnablePassthrough.assign(key=chain)` is the pattern for multi-step pipelines that need to accumulate context across calls
5. Local models (Ollama, HuggingFace) use the identical LCEL interface — swap providers by changing the model object, not the chain structure
6. Never commit API keys — use environment variables or a `.gitignore`d config file

## Connects To

- **Ch1**: LCEL is the practical implementation of the modular architecture described there
- **Ch3**: LangGraph extends beyond stateless chains — use it when you need state, cycles, or human-in-the-loop
- **Ch4**: RAG chains are built on LCEL: `retriever | prompt | model | parser`
- **Ch9**: Production deployment adds streaming, FastAPI, and cost management on top of these chains
