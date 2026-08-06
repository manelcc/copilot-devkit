# Cheatsheet — Generative AI with LangChain

## Architecture Decision Rules

| If you need... | Use... | Why |
|---|---|---|
| Single LLM call | LCEL chain (`prompt \| model \| parser`) | Simpler, no overhead |
| Multi-step with shared context | `RunnablePassthrough.assign()` pipeline | Accumulates keys without losing input |
| State between calls | LangGraph `StateGraph` | Designed for persistent state + cycles |
| Agent with tools | `create_react_agent(llm, tools)` | Wraps ReAct loop as LangGraph graph |
| Structured multi-step agent | Plan-and-Solve | When tool sequence is predictable |
| Multi-turn conversation | LangGraph + `MemorySaver` + `thread_id` | Session persistence per user |
| Human approval before action | LangGraph `interrupt()` + `Command(resume=)` | Pauses, awaits input, continues |
| Multiple specialists | Supervisor pattern + subgraphs | Specialization > generalization |
| Iterative quality improvement | Reflection pattern (generator + structured critic) | First draft rarely final |

---

## RAG Strategy Selection

| Situation | Strategy |
|---|---|
| Quick prototype, simple Q&A | Naive RAG: `FAISS + as_retriever(k=4)` |
| Technical terminology misses | Hybrid: `EnsembleRetriever([BM25, dense], weights=[0.5,0.5])` |
| Initial retrieval imprecise | Add re-ranking (Cohere, cross-encoder) |
| Users phrase queries poorly | Query transformation / multi-query expansion |
| Long docs, limited context | Contextual compression |
| Legal/medical/regulated | Source attribution with inline citations `[1]` |
| Mission-critical accuracy | CRAG (evaluate docs quality, fallback to web search) |
| Complex multi-step retrieval | Agentic RAG with LangGraph |

**Defaults that work**: chunk_size=1000, chunk_overlap=200, k=4, same embedding model for indexing and querying

---

## Tool Design Rules

1. **"The description IS the prompt"** — Write tool descriptions as if training the LLM when to call it
   - Bad: `"Searches for information"`
   - Good: `"Returns live Google search results for queries about current events, news, prices, or real-time facts. Not for historical information available in training data."`
2. **Use `handle_tool_error=True`** on all external tool calls — enables auto-recovery
3. **Limit each agent to 5–15 tools** — more than 15 degrades LLM tool selection accuracy
4. **Add `@tool` as first choice** — upgrade to `StructuredTool` when you need explicit `args_schema`, to `BaseTool` when you need async or state

---

## Temperature Decision Guide

| Task Type | Temperature |
|---|---|
| Factual Q&A, classification, structured extraction | 0.0 |
| Code generation, tool selection | 0.1 |
| Summarization, balanced responses | 0.3 |
| Creative writing, brainstorming | 0.7–0.9 |
| Maximum diversity (data augmentation) | 1.0+ |

**Rule**: Never share one temperature across different task types in the same application

---

## Model Tier Selection

| Query Type | Model | Cost |
|---|---|---|
| Routing, classification, simple Q&A | gpt-4o-mini / claude-haiku | ~$0.15/1M |
| Standard generation, code | gpt-4o / claude-sonnet | ~$2.50/1M |
| Complex reasoning, math, safety-critical | o1 / claude-sonnet extended thinking | ~$15/1M |

**Decision rule**: Start cheap, escalate on quality failure. Route by: query length > 200 OR contains "analyze/compare/strategy" keywords → complex tier

---

## LangGraph State Design

| Need | Pattern |
|---|---|
| Replace value | Default: `field: str` |
| Append to list | `field: Annotated[list[str], add]` |
| Custom merge | `field: Annotated[T, my_reducer_fn]` |
| Multi-turn history | `messages: Annotated[list[AnyMessage], add_messages]` |

**Critical**: Nodes return `dict` with only keys they update — never mutate the full state

---

## Agent Memory Selection

| Scope | Implementation | Persistence |
|---|---|---|
| Single turn | `messages` state key | Dies with request |
| Session (same thread) | `MemorySaver()` | Dies with process |
| Cross-session (SQLite) | `SqliteSaver(conn)` | Survives restarts |
| Cross-session (Postgres) | `PostgresSaver(pool)` | Production-grade |
| Semantic long-term | `InMemoryStore` + vector retrieval | Search by meaning |

---

## Evaluation Decision Tree

```
Always run:
├── String/JSON validation → catches format failures
├── LLM-as-Judge (criteria) → catches quality failures
└── RAGAS (for RAG) → catches retrieval failures

For complex agents, also run:
└── Trajectory evaluation → catches wrong-path failures

Periodically:
└── Benchmark on curated dataset → catches regression
```

**LLM-as-Judge rule**: Use different model (or at minimum different model family) than the one being evaluated

---

## Security Checklist (Pre-Production)

- [ ] API keys in environment variables / secret manager (never in code)
- [ ] System prompt isolated from user text in separate context partition
- [ ] Input semantic filtering (not regex) for injection patterns
- [ ] Output schema enforcement (JSON contracts, not freeform)
- [ ] Tool/API access limited to minimum required (least privilege)
- [ ] Per-user token budget and rate limiting configured
- [ ] `PythonREPLTool` sandboxed (Docker/RestrictedPython) or removed
- [ ] LangSmith tracing enabled with separate prod/staging projects
- [ ] Adversarial test prompts run before first production traffic

---

## Production Deployment Quick Reference

| Start | Scale | Regulated |
|---|---|---|
| Cloud API + FastAPI | Kubernetes + vLLM | Private cloud / on-premises |
| `LANGCHAIN_TRACING_V2=true` | LangGraph Platform | HIPAA/GDPR compliance contract |
| `MemorySaver` | `PostgresSaver` | Data sovereignty verification |

**LiteLLM pattern** for multi-provider resilience:
`Router(model_list=[primary, fallback], routing_strategy="usage-based-routing-v2", cache_responses=True, num_retries=3)`

---

## Scaling Laws Mental Models

| Situation | Apply |
|---|---|
| Choosing model size | Chinchilla: match model size to dataset size; data efficiency > raw scale |
| Justifying smaller model | phi / Textbooks Are All You Need: data quality reshapes the curve |
| Hard reasoning task | Test-time compute: `reasoning_effort="high"` or Claude extended thinking |
| Architecture choice | Beyond 2025: MoE, SSMs, process supervision > just adding parameters |

---

## Common Anti-pattern Tells

| You see... | Problem | Fix |
|---|---|---|
| `temperature=0.7` on all chains | Same temp for factual + creative | Set per-task temperature |
| Tool description: `"Useful for X"` | Vague → wrong tool selection | Rewrite with when/what/not-for |
| `k=1` or `k=2` in retriever | Misses context → wrong answers | Use k=4-6 + re-ranking |
| Same LLM evaluating itself | Circular validation | Use different model family as judge |
| LCEL chain with 8+ steps | Complexity without state benefits | Migrate to LangGraph |
| `PythonREPLTool` in production | Arbitrary code execution risk | Sandbox or replace with safe alternatives |
| No `recursion_limit` in agent | Infinite loop risk | `config={"recursion_limit": 10}` |
| One agent with 30+ tools | Tool selection degrades | Split into specialist agents (5-15 tools each) |
