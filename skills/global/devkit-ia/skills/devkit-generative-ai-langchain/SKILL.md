---
name: devkit-generative-ai-langchain
description: "Knowledge base for LangChain, LangGraph and LangSmith architecture: chains, RAG, agents, evaluation, and production LLM deployment."
triggers:
	- "diseña RAG con LangChain"
	- "usa LangGraph"
	- "evalúa un agente LLM"
non_triggers:
	- "diseñar la estrategia general de autonomía de agentes"
	- "entrenar, afinar o elegir un modelo PyTorch"
---

<!-- argument-hint: [topic, framework name, chapter number, or pattern] -->

# Generative AI with LangChain (2nd Edition)
**Author**: Ben Auffarth | **Pages**: ~481 | **Chapters**: 10 + Appendix | **Generated**: 2026-08-06

## Purpose

Guide framework-specific decisions for LangChain, LangGraph, LangSmith, RAG, LLM agents, evaluation, and production deployment.

## When to use

- Designing or implementing LCEL chains, LangGraph stateful workflows, RAG, or LangSmith evaluation and tracing.
- Choosing retrieval, agent, multi-agent, evaluation, or deployment patterns in the LangChain ecosystem.

## When NOT to use

- Defining technology-agnostic agent governance or safety architecture; use `devkit-building-agentic-ai-systems`.
- Choosing model training, fine-tuning, or image generation methods; use `devkit-generative-ai-with-python-and-pytorch`.

## Inputs

- Use case, data sources, scale, latency, privacy, model-provider, evaluation, and operating constraints.
- Existing backend and mobile integration contracts when applicable.

## Steps

1. Establish whether a simple chain, RAG workflow, stateful graph, or agent is justified.
2. Design retrieval, tool access, evaluation, observability, security, and deployment boundaries.
3. Consult the referenced chapters and patterns for the selected architecture.
4. Verify current framework APIs, package compatibility, provider behaviour, pricing, and security guidance in official online documentation before implementation advice.

## Expected outputs

- A framework-specific architecture decision with alternatives, trade-offs, and validation plan.
- Concrete requirements for retrieval quality, tracing, safety, cost, and tests.

## Validation

- Validate RAG grounding and agent trajectories with automated and human evaluation criteria.
- Check all version-sensitive guidance against current official online sources.

## Examples

- "¿Cuándo elegir LangGraph frente a una LCEL chain para un asistente con aprobaciones?"
- "Diseña un RAG con evaluación de fidelidad y observabilidad en producción."

## How to Use This Skill

- **Without arguments** — load core frameworks for reference
- **With a topic** — ask about `RAG`, `agents`, `evaluation`, `production`, or any indexed topic; I find and read the relevant chapter
- **With chapter** — ask for `ch04`, `ch09`, or a chapter title; I load that specific chapter
- **With a pattern** — ask "how do I implement [pattern]?"; I check patterns.md for the implementation
- **Browse** — ask "what chapters do you have?" to see the full index

When you ask about a topic not covered in Core Frameworks below, I will read the relevant chapter file before answering.

---

## Core Frameworks & Mental Models

### The LangChain Ecosystem Stack
- **LangChain**: Model integration + LCEL pipe composition for chains and workflows
- **LangGraph**: Stateful directed graphs with cycles, conditional branching, and persistence — for agents and multi-turn apps
- **LangSmith**: Observability, evaluation, and offline benchmarking — set `LANGCHAIN_TRACING_V2=true` to enable zero-code tracing

**When to use which**: LCEL for stateless chains → LangGraph when you need state, loops, or human-in-the-loop → LangSmith always in production.

### LCEL (LangChain Expression Language)
```python
chain = prompt | model | output_parser
result = chain.invoke({"var": "value"})  # or .stream(), .batch(), .ainvoke()
```
- Every LangChain component is a `Runnable` — composable with `|`
- Streaming, batching, and async come for free with any LCEL chain
- Multi-step: `RunnablePassthrough.assign(step1=chain1).assign(step2=chain2)`

### LangGraph State Machine
```python
builder = StateGraph(MyTypedDict)
builder.add_node("node_name", python_function)
builder.add_conditional_edges("node_name", route_fn)  # Literal return type required
graph = builder.compile(checkpointer=MemorySaver())
graph.invoke(input, config={"configurable": {"thread_id": "session-1"}})
```
- Nodes: pure functions `(state) -> dict` returning only updated keys
- Reducers: `Annotated[list, add]` for append behavior; default = replace
- `interrupt("question")` + `Command(resume=value)` for human-in-the-loop

### RAG Architecture
Two pipelines: **Indexing** (offline: load → chunk → embed → store) + **Query** (online: retrieve → augment → generate)

Retrieval strategy ladder:
1. Naive: `FAISS + as_retriever(k=4)` — start here
2. Hybrid: `EnsembleRetriever([BM25, dense], weights=[0.5, 0.5])` — when exact terminology matters
3. Re-ranking: Cohere/cross-encoder — when precision is low
4. Query transformation: multi-query, HyDE — when users phrase queries poorly
5. CRAG: document quality evaluator + web search fallback — mission-critical only

**Defaults**: chunk_size=1000, chunk_overlap=200, k=4, same embedding model for index and query.

### Agent Patterns
- **ReAct**: `create_react_agent(llm, tools)` → interleaved Reason→Act→Observe loop; for discovery tasks
- **Plan-and-Solve**: generate full plan → execute each step; for structured tasks with known subtask structure
- **Tool rules**: description IS the prompt; limit 5-15 tools per agent; `handle_tool_error=True` for external calls
- **ToolNode**: pre-built LangGraph node executing `AIMessage.tool_calls` → returns `ToolMessage`

### Multi-Agent Architectures
- **Supervisor**: coordinator delegates to compiled subgraph agents; return-to-supervisor loop
- **Consensus**: N agents solve in parallel; LLM-as-judge selects best; N× cost, better quality
- **Reflection**: generator → structured critic (score + issues + suggestions) → generator loop
- **Tree of Thoughts**: generate N candidate next steps; explore with DFS/BFS; vote on best path

### Evaluation Stack
- **LLM-as-Judge**: `load_evaluator("criteria", criteria={...}, llm=eval_llm)` — use different model family than evaluated
- **RAGAS**: faithfulness + answer relevancy + context precision + context recall — standard RAG evaluation suite
- **Trajectory**: record `[node_1, tool_call, node_2, ...]` per run; compare to reference; partial credit scoring
- **Rule**: automate criteria evaluation in CI/CD; human review for edge cases; always evaluate trajectory for complex agents

### Production Deployment
- **Security**: isolate system prompts; semantic input filtering; schema-enforced output; least-privilege tools; token budgets
- **Observability**: `LANGCHAIN_TRACING_V2=true` + `LANGCHAIN_PROJECT="prod"` — zero-code LangSmith tracing
- **Cost**: tiered model routing (70-90% savings on simple queries); response caching; output token limits
- **Infrastructure**: FastAPI + uvicorn for API; Kubernetes for scale; LangGraph Platform for managed agents

### Model Selection
| Task | Temperature | Model tier |
|---|---|---|
| Factual Q&A, classification | 0.0–0.1 | cheap (gpt-4o-mini) |
| Standard generation, code | 0.3 | standard (gpt-4o) |
| Complex reasoning, safety-critical | 0.0 | premium (o1, extended thinking) |

---

## Chapter Index

| # | Title | Key Frameworks |
|---|-------|----------------|
| [ch01](chapters/ch01-rise-of-generative-ai.md) | The Rise of Generative AI | LangChain Trifecta, LCEL, Scaling Laws, LLM Limitations |
| [ch02](chapters/ch02-first-steps-langchain.md) | First Steps with LangChain | LCEL chains, PromptTemplate, Temperature, Ollama, Streaming |
| [ch03](chapters/ch03-langgraph-workflows.md) | Building Workflows with LangGraph | StateGraph, Reducers, MemorySaver, Conditional Edges, HIL |
| [ch04](chapters/ch04-intelligent-rag-systems.md) | Building Intelligent RAG Systems | RAG Pipeline, Hybrid Retrieval, CRAG, RAGAS, Source Attribution |
| [ch05](chapters/ch05-intelligent-agents.md) | Building Intelligent Agents | ReAct, Tool Definition, ToolNode, Plan-and-Solve, Error Handling |
| [ch06](chapters/ch06-multi-agent-systems.md) | Advanced Multi-Agent Systems | Supervisor, Consensus, Reflection, ToT, Agent Memory, Handoffs |
| [ch07](chapters/ch07-software-data-agents.md) | Software Dev & Data Analysis Agents | PythonREPLTool, PandasAgent, Repository RAG, Code LLM Benchmarks |
| [ch08](chapters/ch08-evaluation-testing.md) | Evaluation and Testing | LLM-as-Judge, RAGAS, Trajectory Eval, LangSmith, Evaluation Governance |
| [ch09](chapters/ch09-production-deployment.md) | Production Deployment & Observability | FastAPI, LangSmith, Security, Tiered Routing, Kubernetes, LiteLLM |
| [ch10](chapters/ch10-future-generative-models.md) | Future of Generative Models | Scaling Limits, MoE, Process Supervision, ToT, Societal Impact |

---

## Topic Index

- **Agentic RAG** → ch04, ch06
- **Agent Memory** → ch06
- **Cascading Models** → ch09
- **ChatPromptTemplate** → ch02
- **Checkpointing (MemorySaver/SqliteSaver)** → ch03
- **Chunking** → ch04
- **Code Agents / PythonREPLTool** → ch07
- **Conditional Edges** → ch03, ch05
- **Consensus Mechanism** → ch06
- **CRAG** → ch04
- **create_react_agent** → ch05
- **DeepSeek / Extended Thinking** → ch02
- **Document Loaders** → ch04
- **Embeddings** → ch04
- **EU AI Act** → ch10
- **Evaluation Governance** → ch08
- **FAISS** → ch04
- **FastAPI deployment** → ch09
- **Hallucination** → ch01, ch04, ch09
- **Handoffs** → ch06
- **Human-in-the-loop** → ch03, ch06
- **Hybrid Retrieval** → ch04
- **HyDE** → ch04
- **Kubernetes** → ch09
- **LangGraph** → ch03, ch05, ch06
- **LangGraph Platform** → ch09
- **LangSmith** → ch08, ch09
- **LCEL** → ch01, ch02
- **LiteLLM** → ch09
- **LLM-as-Judge** → ch08
- **Local Models / Ollama** → ch02
- **MCP (Model Context Protocol)** → ch09
- **MemorySaver** → ch03
- **MessagesPlaceholder** → ch02, ch03
- **Mixture of Experts (MoE)** → ch10
- **Multi-Agent** → ch06
- **Multi-Query Retrieval** → ch04
- **Pandas DataFrame Agent** → ch07
- **Plan-and-Solve** → ch05
- **Prompt Injection** → ch09
- **PromptTemplate** → ch02
- **Python REPL Agent** → ch07
- **RAGAS** → ch04, ch08
- **RAG Pipeline** → ch04
- **ReAct** → ch05
- **Reducers** → ch03
- **Reflection Pattern** → ch06
- **Repository RAG** → ch07
- **Scaling Laws** → ch01, ch10
- **Security** → ch09
- **Semantic Router** → ch06
- **Source Attribution** → ch04
- **StateGraph** → ch03
- **Streaming** → ch02, ch06, ch09
- **Temperature** → ch02
- **Test-Time Compute** → ch10
- **Tiered Model Selection** → ch09
- **ToolNode** → ch05
- **Trajectory Evaluation** → ch08
- **Tree of Thoughts (ToT)** → ch06
- **Vector Stores** → ch04
- **vLLM** → ch09

---

## Supporting Files

- [glossary.md](glossary.md) — all key terms with definitions and chapter references
- [patterns.md](patterns.md) — all implementation patterns with code examples and trade-offs
- [cheatsheet.md](cheatsheet.md) — decision tables, anti-pattern tells, quick reference

---

## Scope & Limits

This skill covers the book "Generative AI with LangChain" (2nd edition, 2025) by Ben Auffarth. It targets LangChain v0.3 / LangGraph v0.2+ patterns. For hands-on implementation in your specific codebase, combine with project-specific tools. For topics beyond this book, check related skills (`generative-ai-with-python-and-pytorch`, `building-agentic-ai-systems`) or ask the agent directly.

**GitHub repo with all code examples**: https://github.com/benman1/generative_ai_with_langchain
