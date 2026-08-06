# Chapter 9: Production-Ready LLM Deployment and Observability

## Core Idea
Production LLM deployment requires three simultaneous concerns: security (prompt injection, data leakage), scalability (containerization, Kubernetes, serverless), and observability (LangSmith tracing, hallucination detection, cost tracking) — MLOps for LLMs is not optional.

## Frameworks Introduced

- **LLM Security Hardening Framework** (OWASP Top 10 for LLMs):
  - Isolate system prompts from user text in separate context partitions
  - Semantic input filtering (embedding-based, not regex)
  - Schema-enforced output validation (strict JSON contracts)
  - Least-privilege tool/API access per agent
  - Continuous adversarial red-teaming
  - When to use: any production deployment — these are the minimum viable security controls

- **FastAPI Deployment Pattern**: Expose LangChain/LangGraph agents as REST APIs with health endpoints, streaming support, and async handling
  - When to use: standard web API deployment; integrates with any client
  - How: `@app.post("/invoke")` → `await chain.ainvoke(...)` → `StreamingResponse` for real-time tokens

- **Tiered Model Selection (Cost Optimization)**: Route queries to different models by complexity — fast/cheap model for simple queries, expensive model only for complex ones
  - When to use: mixed-complexity workloads; cost management is a priority
  - How: classifier LLM (or heuristic) routes to GPT-4o-mini vs GPT-4o; saves 70-90% on simple queries

- **Cascading Model Approach**: Try cheapest model first; escalate to better model only if confidence is low or quality check fails
  - When to use: quality-sensitive tasks where most inputs are actually simple
  - How: try gpt-4o-mini → if `quality_score < threshold`: retry with gpt-4o → return best result

- **LangSmith Observability Stack**: Trace every LLM call, tool invocation, and chain step; tag runs with metadata; create dashboards for latency/cost/quality; feed traces back to evaluation datasets
  - When to use: any production LangChain application; set `LANGCHAIN_TRACING_V2=true` to enable
  - How: set env vars → automatic tracing; `@traceable` decorator for custom Python functions

## Key Concepts

- **Prompt Injection**: Attacker embeds instructions in user input to override system prompt behavior (e.g., "ignore previous instructions and..."); #1 OWASP LLM risk
- **Data Leakage**: LLM inadvertently reveals information from system prompt or other users' context; prevented by context isolation
- **LiteLLM Router**: Unified interface for multiple LLM providers with usage-based routing, response caching, automatic failover, and retry logic
- **vLLM**: High-throughput LLM serving with PagedAttention — dramatically improves GPU memory efficiency; use for self-hosted model serving
- **Ray Serve**: General-purpose scalable serving framework with LangChain integration; use for distributed LLM deployments requiring autoscaling
- **Model Context Protocol (MCP)**: Anthropic's open standard for connecting AI models to tools and data sources in a structured, composable way; emerging production standard
- **Serverless Deployment**: Deploy LangGraph agents on AWS Lambda, Google Cloud Run, or Azure Functions — pay-per-request, no infrastructure management
- **Quantization**: Reduce model weights from 16-bit to 8-bit or 4-bit; cuts memory 50-75%; 4-bit quality loss typically acceptable for most tasks
- **LangGraph Platform**: LangChain's cloud service for deploying and scaling LangGraph agents with persistence, streaming, and monitoring
- **LangGraph CLI**: Local development server for LangGraph agents; `langgraph dev` starts local server with API compatible with LangGraph Platform
- **Hallucination Detection**: Post-generation check comparing LLM claims against retrieved context or ground truth; can use another LLM call or factual verification tools
- **Output Token Optimization**: Prompt engineering to reduce verbose responses; ask for JSON instead of prose; set `max_tokens` appropriately

## Mental Models

- **"Treat LLM as untrusted component"**: System prompts ≠ safe; users can extract them; outputs can be manipulated; apply standard web security principles (input validation, output encoding, least privilege)
- **Deployment decision tree**: Data regulated? → self-host or private cloud. Spiky load? → serverless. Steady high volume? → Kubernetes + vLLM. Just starting? → cloud API + FastAPI
- **Cost = tokens × price/token**: Every optimization reduces tokens (shorter prompts, caching, tiered routing) or price (smaller models, open-source serving)
- **Observability ≠ logging**: Logging captures individual events; observability lets you ask questions about behavior you didn't anticipate; LangSmith provides the latter

## Anti-patterns

- **Hardcoding API keys**: Always use environment variables, Kubernetes Secrets, or secret managers; never in source code or container images
- **No rate limiting or token budgets**: Prompt injection via resource exhaustion is a DoS vector; enforce per-user token caps and request throttling
- **Using input validation regex for security**: Clever rephrasing bypasses all regex; use semantic/embedding-based detectors
- **No cost monitoring until the bill arrives**: LLM costs can spike 100× in hours; set up token usage tracking and cost alerts before going live
- **Samsung rule — no proprietary data in third-party LLMs**: LLM conversations may be used for training; for proprietary code/data, use private deployments or contractual guarantees

## Code Examples

```python
# FastAPI + LangChain streaming deployment
from fastapi import FastAPI
from fastapi.responses import StreamingResponse
from langchain_openai import ChatOpenAI
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser

app = FastAPI()
chain = (
    ChatPromptTemplate.from_template("Answer: {question}")
    | ChatOpenAI(model="gpt-4o-mini")
    | StrOutputParser()
)

@app.post("/ask")
async def ask(question: str):
    async def generate():
        async for token in chain.astream({"question": question}):
            yield f"data: {token}\n\n"
    return StreamingResponse(generate(), media_type="text/event-stream")

@app.get("/health")
async def health(): return {"status": "healthy"}
```
- **What it demonstrates**: Production FastAPI endpoint with streaming and health check

```python
# Tiered model selection for cost optimization
from langchain_openai import ChatOpenAI
from langchain_core.output_parsers import StrOutputParser

fast_llm = ChatOpenAI(model="gpt-4o-mini", temperature=0)  # ~$0.15/1M tokens
smart_llm = ChatOpenAI(model="gpt-4o", temperature=0)        # ~$5/1M tokens

def classify_complexity(question: str) -> str:
    """Simple heuristic: 'complex' if question is long or contains multi-step keywords"""
    if len(question) > 200 or any(w in question.lower() for w in ["compare", "analyze", "strategy"]):
        return "complex"
    return "simple"

def answer(question: str) -> str:
    tier = classify_complexity(question)
    llm = smart_llm if tier == "complex" else fast_llm
    return (ChatPromptTemplate.from_template("{q}") | llm | StrOutputParser()).invoke({"q": question})
```
- **What it demonstrates**: Tiered routing to reduce cost on simple queries

```python
# LangSmith observability setup
import os
os.environ["LANGCHAIN_TRACING_V2"] = "true"
os.environ["LANGCHAIN_API_KEY"] = "your-langsmith-key"
os.environ["LANGCHAIN_PROJECT"] = "prod-langchain-app"

# All LangChain calls are now automatically traced
# Add metadata for better filtering
from langchain_core.callbacks import LangChainTracer

tracer = LangChainTracer(project_name="prod-langchain-app", tags=["v2.0", "prod"])
result = chain.invoke({"question": "..."}, config={"callbacks": [tracer]})
```
- **What it demonstrates**: Zero-code LangSmith tracing with project tagging

```python
# LiteLLM with automatic failover and caching
from langchain_litellm import ChatLiteLLMRouter
from litellm import Router

router = Router(
    model_list=[
        {"model_name": "primary", "litellm_params": {"model": "gpt-4o", "api_key": "..."}},
        {"model_name": "fallback", "litellm_params": {"model": "claude-3-5-sonnet-20241022", "api_key": "..."}},
    ],
    routing_strategy="usage-based-routing-v2",
    cache_responses=True,
    num_retries=3
)
llm = ChatLiteLLMRouter(router=router, model_name="primary")
```
- **What it demonstrates**: Multi-provider failover and response caching via LiteLLM

## Reference Tables

| Deployment Option | When | Cost | Expertise |
|---|---|---|---|
| Cloud API + FastAPI | Prototyping, spiky load, fast start | Per-token | Low |
| Kubernetes + vLLM | Self-hosted, high steady volume, regulated | Infrastructure | High |
| Serverless (Cloud Run, Lambda) | Intermittent load, managed scale | Per-request | Medium |
| LangGraph Platform | LangGraph agents, managed persistence | Platform fee | Low |
| On-premises GPU | Complete data sovereignty, $50K-$300K setup | Fixed + ops | Very High |

| Security Control | What It Prevents |
|---|---|
| Context partitioning | Prompt injection across users |
| Semantic input filtering | Jailbreaks that bypass regex |
| Schema-enforced outputs | Malicious content in structured responses |
| Least-privilege tools | Blast radius of compromise |
| Token budgets | DoS via resource exhaustion |
| Adversarial red-teaming | Unknown injection patterns |

| Cost Optimization | Typical Savings |
|---|---|
| Tiered model routing | 70-90% on simple queries |
| Response caching | 40-60% on repeated queries |
| Output token limits | 20-30% via concise prompts |
| Cascading models | Variable; depends on quality threshold |
| Batch processing (non-urgent) | 50% via lower-priority pricing |

## Worked Example

**Production deployment decision walkthrough**

A healthcare startup needs to deploy a medical Q&A RAG agent:

1. **Security first**: Medical data is HIPAA-regulated → **self-hosted** or contractually bound private cloud; no third-party LLM training on patient queries
2. **Architecture**: FastAPI + RAG chain → LangGraph with MemorySaver (session persistence) → Kubernetes for scaling
3. **Model**: GPT-4o via Azure OpenAI (HIPAA BAA available) for high-quality medical answers; gpt-4o-mini for session management and routing
4. **Security hardening**: Input: semantic injection detector; Output: JSON schema validation with source citations required; Tools: read-only medical DB access only
5. **Observability**: LangSmith with HIPAA-compliant workspace; custom hallucination detector comparing answer claims against retrieved context; token cost dashboard by department
6. **Cost control**: Tiered routing (gpt-4o-mini for trivial queries, gpt-4o for clinical); response caching for common questions; per-department token budgets

Result: HIPAA-compliant, observable, cost-controlled deployment at ~$0.03/query average (vs $0.15 if always using gpt-4o).

## Key Takeaways

1. **Security is architecture**: Separate system prompts from user text; validate inputs semantically, not with regex; enforce output schemas; apply least-privilege tools — treat LLM as untrusted
2. FastAPI + async chains + `StreamingResponse` is the minimal viable production pattern; add Kubernetes for scale
3. Set `LANGCHAIN_TRACING_V2=true` immediately — LangSmith zero-code tracing is the single highest-ROI observability action
4. **Tiered model routing is the fastest cost reduction**: 70-90% savings by routing simple queries to cheaper models
5. LiteLLM Router provides multi-provider failover, response caching, and retry logic in one library — essential for high-availability production
6. Start with cloud APIs → prove the product → migrate to self-hosting when volume justifies infrastructure cost

## Connects To

- **Ch2**: FastAPI deployment wraps LCEL chains from Ch2
- **Ch3/6**: LangGraph Platform is the production deployment for LangGraph agents
- **Ch8**: LangSmith connects production monitoring (Ch9) with evaluation datasets (Ch8) — same platform
- **OWASP Top 10 for LLMs**: https://owasp.org/www-project-top-10-for-large-language-model-applications/ — the reference for LLM security
