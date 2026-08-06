# Chapter 3: Building Workflows with LangGraph

## Core Idea
LangGraph replaces linear LCEL chains with stateful directed graphs — enabling cycles, conditional branching, persistence, and human-in-the-loop — making it the correct framework for any workflow that needs to remember, revisit, or wait.

## Frameworks Introduced

- **StateGraph Pattern**: Define state schema (TypedDict/Pydantic) → add nodes (Python functions) → add edges (direct or conditional) → compile → invoke
  - When to use: any multi-step workflow that needs shared mutable context, branching, or loops
  - How: `StateGraph(MyState)` → `add_node("name", fn)` → `add_edge(START, "name")` → `add_conditional_edges("name", condition_fn)` → `graph.compile()`

- **Reducer Pattern**: Control how node outputs are merged into state — replace (default), append (`Annotated[list, add]`), or custom reducer function
  - When to use: when nodes produce partial updates that should accumulate (e.g., message history, action lists)
  - How: annotate state field with `Annotated[list[str], add]` for append behavior; write custom reducer function for complex merge logic

- **Checkpointing (MemorySaver / SqliteSaver)**: Persist graph state between invocations to enable multi-turn conversations
  - When to use: chatbots, agentic workflows where state must survive across calls
  - How: `graph.compile(checkpointer=MemorySaver())`, then pass `config={"configurable": {"thread_id": "session_1"}}` to `invoke()`

- **Human-in-the-loop**: `interrupt_before=["node_name"]` pauses graph before a node, returns control to human, resumes with `graph.invoke(Command(resume=human_input))`
  - When to use: high-stakes actions requiring approval; uncertainty requiring human judgment

## Key Concepts

- **StateGraph**: LangGraph's core class; unlike DAGs, allows cycles and explicit state management
- **Node**: Python function `(state: MyState) -> dict` that returns a partial state update (keys to update, not full state)
- **Edge**: Direct connection (`add_edge`) or conditional connection (`add_conditional_edges`) between nodes
- **Conditional Edge**: Python function `(state) -> Literal["node_a", "node_b"]` that routes execution; must use `Literal` type hint or provide explicit destination list
- **Superstep**: A discrete execution iteration in LangGraph (from Pregel); can run multiple nodes in parallel; updates are merged atomically
- **START / END**: Built-in LangGraph reserved node names marking workflow entry and termination points
- **MessagesPlaceholder**: Used in `ChatPromptTemplate` to inject conversation history as a runtime list
- **Zero-shot Prompting**: Task description without examples — works when role + task + context + format is clear
- **Few-shot Prompting**: Providing input-output example pairs; works best for classification, extraction; hard to scale without example selectors
- **Dynamic Few-shot**: SemanticSimilarityExampleSelector chooses examples closest to current input at runtime
- **Partial Prompt**: `template.partial(a="fixed_value")` fixes some template variables ahead of time; rest filled at invoke time

## Mental Models

- Use **LangGraph when LCEL isn't enough**: need a cycle (retry loop), need shared state across multiple LLM calls, or need the workflow to pause and wait for human input
- Think of nodes as **pure functions**: they receive immutable state, return a partial update dict — they cannot mutate state directly (side-effect-free design)
- Use **conditional edges** (dotted lines in diagrams) for any routing decision: "if classification == error, go to error_handler; else go to responder"
- Think of **MemorySaver** as session-scoped memory, **SqliteSaver** as persistent cross-session memory — choose by whether state survives process restarts

## Anti-patterns

- **Using LangGraph for simple linear pipelines**: LCEL is faster and simpler when there's no branching or state sharing; LangGraph adds overhead without benefit
- **Forgetting `Literal` type hints on conditional edge functions**: LangGraph won't know possible destinations and will create edges to all nodes
- **Uncapped recursion in cyclic graphs**: Always set `recursion_limit` in `graph.invoke()` config; LLM non-determinism can create infinite loops
- **Using mutable state in node functions**: Don't mutate the input dict directly — return a new dict with only updated keys

## Code Examples

```python
# Minimal StateGraph with conditional edge
from typing import TypedDict, Literal
from langgraph.graph import StateGraph, START, END

class JobState(TypedDict):
    job_description: str
    is_suitable: bool
    application: str

def analyze(state: JobState) -> dict:
    return {"is_suitable": len(state["job_description"]) > 100}

def generate_application(state: JobState) -> dict:
    return {"application": "Dear Hiring Manager..."}

def route(state: JobState) -> Literal["generate_application", "__end__"]:
    return "generate_application" if state["is_suitable"] else END

builder = StateGraph(JobState)
builder.add_node("analyze", analyze)
builder.add_node("generate_application", generate_application)
builder.add_edge(START, "analyze")
builder.add_conditional_edges("analyze", route)
builder.add_edge("generate_application", END)
graph = builder.compile()

result = graph.invoke({"job_description": "Senior Python engineer role..."})
```
- **What it demonstrates**: Full StateGraph lifecycle with conditional routing

```python
# Persistent multi-turn conversation with MemorySaver
from langgraph.checkpoint.memory import MemorySaver

checkpointer = MemorySaver()
graph = builder.compile(checkpointer=checkpointer)

config = {"configurable": {"thread_id": "user-123"}}
graph.invoke({"messages": [("user", "Hello")]}, config=config)
# Next call resumes the same session automatically
graph.invoke({"messages": [("user", "What did I say before?")]}, config=config)
```
- **What it demonstrates**: Session-scoped memory via thread_id

```python
# Annotated reducer for accumulating a list
from typing import Annotated
from operator import add

class PipelineState(TypedDict):
    input: str
    actions: Annotated[list[str], add]  # new list is appended, not replaced
```
- **What it demonstrates**: Reducer pattern for accumulating node outputs

## Worked Example

**Building a job application workflow with human approval**

```
State: {job_description, is_suitable, draft_application, final_application, approved}
Nodes: analyze → draft → human_review → finalize
Conditional edges: after analyze → if suitable: draft, else: END
                   after draft → interrupt for human review
                   after human_review → if approved: finalize, else: draft (retry)
```

```python
from langgraph.graph import StateGraph, START, END
from langgraph.checkpoint.memory import MemorySaver
from langgraph.types import interrupt, Command

def analyze(state): return {"is_suitable": len(state["job_description"]) > 100}
def draft(state): return {"draft_application": "Dear Hiring Manager, ..."}
def human_review(state):
    decision = interrupt({"draft": state["draft_application"]})  # pauses here
    return {"approved": decision == "approve"}
def finalize(state): return {"final_application": state["draft_application"]}

builder = StateGraph(...)
builder.add_node("analyze", analyze)
builder.add_node("draft", draft)
builder.add_node("human_review", human_review)
builder.add_node("finalize", finalize)
builder.add_edge(START, "analyze")
builder.add_conditional_edges("analyze", lambda s: "draft" if s["is_suitable"] else END)
builder.add_edge("draft", "human_review")
builder.add_conditional_edges("human_review", lambda s: "finalize" if s["approved"] else "draft")
builder.add_edge("finalize", END)
graph = builder.compile(checkpointer=MemorySaver(), interrupt_before=["human_review"])
```

Key insight: the `interrupt()` call suspends execution and returns to the caller; the human sends `Command(resume="approve")` to continue from the same point.

## Key Takeaways

1. LangGraph allows **cycles** (retries, loops) — unlike simple DAGs; this is its core differentiator
2. Nodes are pure functions: receive immutable state, return partial update dict — never mutate state in place
3. `add_conditional_edges("node", condition_fn)` is the routing primitive; `condition_fn` must return a string matching a node name or `END`
4. `MemorySaver` + `thread_id` config turns any graph into a persistent multi-turn session
5. Human-in-the-loop uses `interrupt()` inside a node + `Command(resume=value)` from the caller — no special architecture needed

## Connects To

- **Ch2**: LangGraph nodes are themselves `Runnable` — LCEL chains can be used as node functions
- **Ch5**: Agents use LangGraph under the hood — tool calls become edges, tool results become state updates
- **Ch6**: Multi-agent systems extend this pattern: sub-graphs per agent with handoff edges between them
- **ReAct paper**: The reasoning-acting loop implemented natively in LangGraph agents
