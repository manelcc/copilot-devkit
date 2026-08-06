# Chapter 6: Advanced Applications and Multi-Agent Systems

## Core Idea
Complex tasks benefit from multiple specialized agents coordinating rather than one omniscient agent — LangGraph's subgraph composition, streaming, and handoff mechanisms are the foundation for building scalable multi-agent systems with controllable autonomy.

## Frameworks Introduced

- **Supervisor Pattern**: A coordinator agent decomposes tasks and delegates to specialized sub-agents; each sub-agent is a LangGraph subgraph compiled independently
  - When to use: tasks that naturally decompose into distinct specialist domains (research + writing + review)
  - How: `builder.add_node("research_agent", research_agent)` — pass compiled subgraph as callable node

- **Consensus Mechanism**: N agents solve the same task in parallel; a judge selects the best solution
  - When to use: high-stakes decisions where quality matters more than cost; hallucination-sensitive tasks
  - How: `RunnableParallel(agent1=chain1, agent2=chain2)` for parallel execution → judge node with LLM-as-a-judge or majority voting

- **Reflection Pattern**: One agent generates a response; a critic agent provides structured feedback; generator iterates
  - When to use: creative tasks, code generation, complex analysis where first draft is rarely final
  - How: generator node → critic node (returns structured feedback) → conditional edge: if "approved" → END, else → generator (loop with state carrying critique)

- **Tree of Thoughts (ToT)**: Explore multiple reasoning paths in a tree structure (DFS/BFS); use replanner to generate N candidates for next step; consensus selects best final path
  - When to use: complex planning tasks where greedy single-path reasoning fails; olympiad-level problems
  - How: planner generates N branches → execute each branch → replanner adds children → vote at leaf nodes; uses `TreeNode` data structure tracking parent/children

- **Agent Memory Model**: Cache (in-context, ephemeral) + Store (persistent, cross-session vector/key-value)
  - When to use: agents that need to remember past interactions, user preferences, or learned facts
  - How: `MemorySaver` for in-session; `InMemoryStore` or external vector store for cross-session retrieval

- **Semantic Router**: Routes queries to the appropriate specialized agent based on semantic similarity to route descriptions (not keyword matching)
  - When to use: multi-agent systems where different agents handle different domains
  - How: embed route descriptions → embed incoming query → select closest route → dispatch to that agent

## Key Concepts

- **Agentic RAG**: Promotes retrieval decisions to the LLM — it decides when to retrieve, what query to use, how to filter chunks; requires LangGraph for the conditional loop
- **Handoffs**: `Command(goto="agent_name", update={...})` transfers execution between agents with state payload; replaces manual routing logic
- **LangGraph Streaming**: `graph.stream(input, stream_mode="updates")` yields node-by-node updates; `stream_mode="messages"` yields individual message tokens for real-time UX
- **Human-in-the-Loop (HIL)**: `interrupt("question")` pauses graph at node boundary; `Command(resume=answer)` continues — requires checkpointer
- **LangGraph Platform**: Cloud deployment for LangGraph agents with persistent storage, monitoring, and autoscaling; local development via LangGraph CLI
- **Subgraph composition**: Compile child agents as graphs, pass as callable nodes in parent — `builder.add_node("child", child_agent.invoke)` — parent state keys flow down, child updates matching keys flow up

## Mental Models

- **"Limit tools per agent to 5–15"**: LLMs degrade with too many tool choices; specialized agents with focused toolsets outperform general agents with 30 tools
- **Parallel execution increases quality, not just speed**: Running N agents on the same task and consensus-selecting best output reduces variance; the cost is N× tokens
- **Reflection = structured feedback loop**: Not "retry with same prompt" — critique must be structured (what's wrong + why) for the generator to improve meaningfully
- **ToT is greedy-search + non-determinism**: Increase temperature slightly to get diverse branches; MCTS pruning keeps cost manageable by cutting low-value branches early

## Anti-patterns

- **Passing all tools to one mega-agent**: Context window gets polluted, tool selection degrades, errors compound; decompose into specialists
- **Reflection without structured critique**: "This is bad" → generator repeats same response; critique must specify what's wrong and why
- **No max_candidates bound on ToT**: Unbounded branching creates exponential token cost; always cap with `max_candidates=2-3`
- **HIL without checkpointer**: `interrupt()` fails without a checkpointer — always compile with `MemorySaver` when using HIL

## Code Examples

```python
# Supervisor multi-agent with subgraph composition
from langgraph.graph import StateGraph, MessagesState, START, END
from langgraph.prebuilt import create_react_agent
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(model="gpt-4o")

# Specialized sub-agents
research_agent = create_react_agent(llm, [web_search, arxiv_search])
writer_agent = create_react_agent(llm, [write_file, format_markdown])

# Supervisor graph
class SupervisorState(MessagesState):
    next_agent: str

def supervisor(state: SupervisorState):
    decision = llm.invoke([{"role": "system", "content": 
        "You are a supervisor. Route to 'research' or 'writer' or 'FINISH'"},
        *state["messages"]])
    return {"next_agent": decision.content.strip()}

def route(state: SupervisorState):
    return state["next_agent"]

builder = StateGraph(SupervisorState)
builder.add_node("supervisor", supervisor)
builder.add_node("research", research_agent)
builder.add_node("writer", writer_agent)
builder.add_edge(START, "supervisor")
builder.add_conditional_edges("supervisor", route, 
    {"research": "research", "writer": "writer", "FINISH": END})
builder.add_edge("research", "supervisor")
builder.add_edge("writer", "supervisor")
graph = builder.compile()
```
- **What it demonstrates**: Supervisor pattern with delegation and return-to-supervisor loop

```python
# Handoffs between agents
from langgraph.types import Command

def research_node(state):
    result = research_agent.invoke(state)
    # Hand off to writer with research results
    return Command(goto="writer", update={"research_output": result["messages"][-1].content})
```
- **What it demonstrates**: Explicit handoff with state payload

```python
# LangGraph streaming for real-time UX
for chunk in graph.stream({"messages": [("user", "Research quantum computing")]},
                           stream_mode="messages"):
    if chunk[1]["langgraph_node"] == "writer":
        print(chunk[0].content, end="", flush=True)
```
- **What it demonstrates**: Node-filtered streaming for progressive UI display

## Reference Tables

| Pattern | Agents | Communication | Best For |
|---|---|---|---|
| Supervisor | 1 supervisor + N workers | Centralized via supervisor | Clear task decomposition |
| Network | N peer agents | Decentralized peer-to-peer | Collaborative creative tasks |
| Consensus (parallel) | N parallel agents | Merge at judge node | High-stakes quality decisions |
| Reflection | Generator + Critic | Sequential with critique | Iterative quality improvement |
| Pipeline | A → B → C | Sequential handoffs | Known ordered subtasks |

| Memory Type | Scope | LangGraph Impl | Use Case |
|---|---|---|---|
| In-context | Single turn | `messages` state key | Conversation history |
| Session (cache) | Single thread | `MemorySaver` | Multi-turn chatbot |
| Cross-session (store) | All threads | `InMemoryStore` / vector store | User preferences, learned facts |

## Worked Example

**Reflection pattern for code generation**

```
Generator → produces initial code solution
Critic → evaluates: correctness, edge cases, style (returns structured feedback)
Loop condition: if score >= 8/10 or iterations >= 3 → done
```

```python
from pydantic import BaseModel

class CodeCritique(BaseModel):
    score: int  # 0-10
    issues: list[str]
    suggestions: list[str]

class CodeState(MessagesState):
    code: str
    critique: CodeCritique | None
    iteration: int

def generate_code(state: CodeState):
    prompt = f"Write code for: {state['messages'][0].content}"
    if state.get("critique"):
        prompt += f"\n\nPrevious issues to fix: {state['critique'].issues}"
    code = llm.invoke(prompt).content
    return {"code": code, "iteration": state.get("iteration", 0) + 1}

def critique_code(state: CodeState):
    critique = llm.with_structured_output(CodeCritique).invoke(
        f"Review this code critically:\n{state['code']}"
    )
    return {"critique": critique}

def should_continue(state: CodeState):
    if state["critique"].score >= 8 or state["iteration"] >= 3:
        return END
    return "generate_code"
```

Key insight: the critique is **structured** (issues list + score) so the generator has actionable feedback on each iteration, not vague "this is bad."

## Key Takeaways

1. Specialize agents: limit each to 5–15 tools; group tools by domain; specialized agents outperform general ones on complex tasks
2. Supervisor pattern: coordinator node decides which specialist to invoke; specialists return to supervisor via conditional edges
3. Reflection requires structured critique (score + issues + suggestions) — vague feedback leads to no improvement
4. `Command(goto="agent", update={...})` is the handoff primitive for transferring execution and state between agents
5. ToT extends Plan-and-Solve by generating N candidate next steps at each node; effective for complex reasoning where greedy fails
6. Agent memory: `MemorySaver` for session, `InMemoryStore` or external vector store for cross-session persistent memory

## Connects To

- **Ch3**: All multi-agent patterns are LangGraph subgraphs; Ch3 patterns (checkpointing, HIL, streaming) compose directly
- **Ch4**: Agentic RAG promotes RAG decisions to the LLM; requires LangGraph for the conditional retrieval loop
- **Ch5**: Each sub-agent is a `create_react_agent` or custom LangGraph agent from Ch5
- **Ch7**: Code generation and data analysis agents from Ch7 are specialized agents meant to be composed into multi-agent systems
