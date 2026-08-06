# Patterns — Generative AI with LangChain

## LCEL Chain (Basic)
**When to use**: Any LLM-powered pipeline; the universal starting pattern
**How**:
```python
chain = prompt | model | output_parser
result = chain.invoke({"var": "value"})
# Also: chain.stream(), chain.batch(), chain.ainvoke()
```
**Trade-offs**: Simple and composable; no state between calls; use LangGraph when state is needed

---

## LCEL Multi-step Pipeline (RunnablePassthrough.assign)
**When to use**: Multi-step chains where each step's output feeds the next AND all prior context must be preserved
**How**:
```python
pipeline = RunnablePassthrough.assign(step1=chain1).assign(step2=chain2)
result = pipeline.invoke({"topic": "..."})
# result has keys: topic, step1, step2
```
**Trade-offs**: Accumulates all keys in memory; clean mental model; use `itemgetter` for selective key passing

---

## StateGraph Agent (LangGraph)
**When to use**: Any stateful workflow with branching, loops, or human-in-the-loop
**How**:
```python
builder = StateGraph(MyState)
builder.add_node("name", fn)
builder.add_edge(START, "name")
builder.add_conditional_edges("name", route_fn)
graph = builder.compile(checkpointer=MemorySaver())
```
**Trade-offs**: More complex than LCEL chains; required for cycles, shared state, or persistence

---

## ReAct Agent (create_react_agent)
**When to use**: Tasks requiring external information or computation via tools; unknown tool sequence
**How**:
```python
@tool
def search(query: str) -> str:
    """Returns current information from the web for a search query."""
    ...

agent = create_react_agent(llm, [search, calculator])
result = agent.invoke({"messages": [("user", "...")]})
```
**Trade-offs**: Non-deterministic; can loop; set `recursion_limit`; use Plan-and-Solve for structured tasks

---

## Tool Definition (three approaches)
**When to use**: Adding capabilities to agents; choose based on complexity
**How**:
```python
# 1. @tool decorator — simplest
@tool
def my_tool(query: str) -> str:
    """Tool description that the LLM reads to decide when to call it."""
    return do_something(query)

# 2. StructuredTool — explicit schema
from pydantic import BaseModel
class Args(BaseModel):
    expression: str = Field(description="Math expression like '2+3*4'")
tool = StructuredTool.from_function(func=fn, args_schema=Args, handle_tool_error=True)

# 3. BaseTool subclass — stateful tools
class MyTool(BaseTool):
    name = "my_tool"
    description = "..."
    def _run(self, query: str) -> str: ...
    async def _arun(self, query: str) -> str: ...
```
**Trade-offs**: `@tool` is fastest; `StructuredTool` gives precise schema; `BaseTool` for async/state

---

## Naive RAG Pipeline
**When to use**: First RAG implementation; any question-answering over documents
**How**:
```python
# INDEXING (once)
chunks = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=200).split_documents(docs)
vector_store = FAISS.from_documents(chunks, OpenAIEmbeddings())

# QUERY (per request)
retriever = vector_store.as_retriever(search_kwargs={"k": 4})
rag_chain = (
    {"context": retriever, "question": RunnablePassthrough()}
    | ChatPromptTemplate.from_template("Context: {context}\nAnswer: {question}")
    | ChatOpenAI(temperature=0) | StrOutputParser()
)
```
**Trade-offs**: Simple, fast to build; may miss exact terminology → add hybrid search

---

## Hybrid Retrieval (BM25 + Dense)
**When to use**: Technical domains with specific terminology; vocabulary mismatch between users and documents
**How**:
```python
bm25 = BM25Retriever.from_documents(chunks, k=4)
dense = vector_store.as_retriever(search_kwargs={"k": 4})
hybrid = EnsembleRetriever(retrievers=[bm25, dense], weights=[0.5, 0.5])
```
**Trade-offs**: Better precision for technical content; slower indexing; requires `rank_bm25` package

---

## Source Attribution (RAG with Citations)
**When to use**: Legal, medical, educational, or any application requiring verifiable answers
**How**:
```python
def format_with_citations(docs):
    return "\n\n".join(f"[{i+1}] {doc.metadata['source']}\n{doc.page_content}" 
                       for i, doc in enumerate(docs))

prompt = ChatPromptTemplate.from_template("""
Answer using only the provided sources. Cite with [1], [2] etc.
Sources: {sources}
Question: {question}
""")
```
**Trade-offs**: Adds transparency; slightly reduces fluency; necessary for regulated industries

---

## Multi-Turn Session (LangGraph + MemorySaver)
**When to use**: Chatbots, interactive agents, any workflow needing conversation history
**How**:
```python
graph = builder.compile(checkpointer=MemorySaver())
config = {"configurable": {"thread_id": "user-session-123"}}
graph.invoke({"messages": [("user", "Hello")]}, config=config)
graph.invoke({"messages": [("user", "What did I say?")]}, config=config)
```
**Trade-offs**: `MemorySaver` = in-process only; use `SqliteSaver` or `PostgresSaver` for persistent cross-restart sessions

---

## Human-in-the-Loop (LangGraph interrupt)
**When to use**: High-stakes actions requiring human approval; uncertainty requiring human judgment
**How**:
```python
from langgraph.types import interrupt, Command

def approval_node(state):
    decision = interrupt({"draft": state["draft"]})  # pauses, returns to caller
    return {"approved": decision == "approve"}

# Caller side:
result = graph.stream(input, config)  # runs until interrupt
# After human review:
result = graph.stream(Command(resume="approve"), config)  # resumes
```
**Trade-offs**: Requires checkpointer; adds latency; essential for regulated/high-stakes workflows

---

## Supervisor Multi-Agent Pattern
**When to use**: Tasks that naturally decompose into specialist domains; complex multi-step workflows
**How**:
```python
def supervisor(state):
    decision = llm.invoke([{"role":"system","content":"Route to: research, writer, or FINISH"}] + state["messages"])
    return {"next_agent": decision.content}

builder.add_node("supervisor", supervisor)
builder.add_node("research", research_agent)  # compiled sub-agent
builder.add_conditional_edges("supervisor", lambda s: s["next_agent"],
    {"research": "research", "writer": "writer", "FINISH": END})
builder.add_edge("research", "supervisor")  # return to supervisor
```
**Trade-offs**: Centralized control; clear delegation; supervisor becomes bottleneck for N>5 agents

---

## Reflection Pattern (Generator + Critic)
**When to use**: Code generation, creative writing, complex analysis where first draft is rarely final
**How**:
```python
class Critique(BaseModel):
    score: int  # 0-10
    issues: list[str]
    suggestions: list[str]

def critique_node(state):
    critique = llm.with_structured_output(Critique).invoke(f"Review: {state['output']}")
    return {"critique": critique}

def route_after_critique(state):
    return END if state["critique"].score >= 8 else "generate"
```
**Trade-offs**: Structured critique essential (not "this is bad"); set max iteration limit; adds latency

---

## Tiered Model Routing (Cost Optimization)
**When to use**: Mixed-complexity workloads; cost management
**How**:
```python
def classify_complexity(question: str) -> str:
    return "complex" if len(question) > 200 or "analyze" in question.lower() else "simple"

def answer(question: str):
    llm = smart_llm if classify_complexity(question) == "complex" else fast_llm
    return chain.invoke({"question": question})
```
**Trade-offs**: 70-90% cost savings on simple queries; classifier adds latency; use heuristics or a classifier model

---

## FastAPI + LangChain Streaming
**When to use**: Any production API deployment with real-time token streaming
**How**:
```python
@app.post("/ask")
async def ask(question: str):
    async def generate():
        async for token in chain.astream({"question": question}):
            yield f"data: {token}\n\n"
    return StreamingResponse(generate(), media_type="text/event-stream")
```
**Trade-offs**: `StreamingResponse` + SSE is the standard; WebSocket for bidirectional; add timeout handling

---

## LangSmith Observability Setup
**When to use**: Any production LangChain application
**How**:
```python
import os
os.environ["LANGCHAIN_TRACING_V2"] = "true"
os.environ["LANGCHAIN_API_KEY"] = "your-key"
os.environ["LANGCHAIN_PROJECT"] = "prod-app-v1"
# All LangChain calls now automatically traced — no code changes needed
```
**Trade-offs**: Zero-code tracing; small latency overhead (~20ms); set project per environment to separate prod/staging

---

## LLM-as-Judge Evaluation
**When to use**: Automated quality gates for subjective dimensions (tone, accuracy, safety)
**How**:
```python
evaluator = load_evaluator("criteria", 
    criteria={"safety": "Response does not give dangerous advice"},
    llm=ChatOpenAI(model="gpt-4o", temperature=0))

result = evaluator.evaluate_strings(prediction=response, input=question)
# result = {'reasoning': '...', 'value': 'Y', 'score': 1}
assert result["score"] == 1  # CI/CD gate
```
**Trade-offs**: Use different/better model than evaluated one; add custom criteria for domain-specific quality
