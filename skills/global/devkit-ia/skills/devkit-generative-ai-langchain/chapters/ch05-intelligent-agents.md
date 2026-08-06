# Chapter 5: Building Intelligent Agents

## Core Idea
Agents are LLMs given access to tools and the ability to decide when and how to use them — the ReAct (Reason + Act) loop is the foundational pattern; LangGraph provides the production-grade framework for running this loop reliably with error recovery and state persistence.

## Frameworks Introduced

- **ReAct (Reasoning + Acting)**: Interleaved Reason → Act → Observe loop; LLM reasons about current state, selects and calls a tool, incorporates result, repeats until it can respond
  - When to use: any task requiring external information (web search, APIs, databases) or computation (calculator, code)
  - How: `create_react_agent(llm, tools)` → wraps the ReAct loop as a LangGraph `StateGraph` with a conditional edge back to the tool call node

- **Tool Definition Methods** (choose by complexity):
  1. `@tool` decorator — simplest; inherits name/description/args from function docstring
  2. `StructuredTool.from_function(func, name, description, args_schema)` — explicit control over schema and description
  3. Subclass `BaseTool` — full control including async `_arun`; use when tool is stateful (e.g., maintains a DB connection)
  4. `convert_runnable_to_tool(runnable)` — wraps any LangChain `Runnable` as a tool

- **ToolNode (LangGraph)**: Pre-built LangGraph node that executes tool calls from `AIMessage.tool_calls`, formats results as `ToolMessage`, and returns them to state
  - When to use: building custom agent graphs with LangGraph; replaces manual tool dispatch loop
  - How: `ToolNode([tool1, tool2])` → add as a node → connect with conditional edge from LLM node

- **Plan-and-Solve Agent**: Two-phase strategy — first generate a complete plan (decompose task into subtasks), then execute each step sequentially
  - When to use: complex multi-step tasks where ReAct's step-by-step discovery is too fragile
  - How: first LLM call generates structured plan → iterate plan steps using executor LLM with tools

## Key Concepts

- **Tool**: A Python callable with an OpenAPI schema (title + description + parameters) that LLMs can request to be invoked; description quality directly determines LLM decision quality
- **`tool_calls`**: Field on `AIMessage` returned when LLM decides to use a tool; contains `[{name, args, id}]`
- **`ToolMessage`**: LangChain message type for feeding tool execution results back to LLM; must match `tool_call_id`
- **`llm.bind_tools([tools])`**: Creates a new LLM object with tools pre-bound — avoids repeating `tools=` on every `.invoke()` call
- **Controlled Generation (Structured Output)**: Force LLM to output a specific Pydantic schema via `llm.with_structured_output(MySchema)` — eliminates parsing errors
- **`handle_tool_error=True`**: `BaseTool`/`StructuredTool` flag; catches `ToolException` and returns error string to LLM instead of crashing, enabling auto-recovery
- **`StructuredTool.from_function`**: Easiest way to create a tool with explicit schema; `args_schema=MyPydanticModel` provides full parameter description
- **`@tool` decorator**: One-liner tool creation; LangChain reads name from function name, description from docstring, args from type hints

## Mental Models

- Think of an agent as **LLM + while-loop**: the loop continues until the LLM decides to respond (no more tool calls needed)
- The **tool description IS the prompt**: vague tool descriptions = wrong tool selections; invest the same effort in tool descriptions as in system prompts
- Use **ReAct for discovery tasks** (don't know in advance which tools you'll need); use **Plan-and-Solve for structured execution** tasks (know the steps, just need to execute)
- **Error handling = auto-recovery**: `handle_tool_error=True` lets the agent retry with a corrected call instead of crashing — always enable for external tool calls

## Anti-patterns

- **Vague tool descriptions**: "Useful for searching" → LLM can't decide when to use it; write "Returns live Google search results for a query about current events, news, or recent facts"
- **Using agents where chains suffice**: If the tool sequence is fixed and known, use an LCEL chain; agents add latency, cost, and unpredictability that's unnecessary for deterministic pipelines
- **No recursion limit on ReAct loop**: Uncapped loops can run 100+ times; always set `recursion_limit` in LangGraph config
- **Returning raw exceptions from tools**: Always return human-readable error messages to the LLM — it uses the error string to decide how to retry

## Code Examples

```python
# Create and run a ReAct agent with LangGraph
from langchain_openai import ChatOpenAI
from langchain_core.tools import tool
from langgraph.prebuilt import create_react_agent

@tool
def search(query: str) -> str:
    """Returns current news and facts from Google Search given a search query."""
    # ... actual search implementation
    return f"Search results for: {query}"

@tool  
def calculator(expression: str) -> str:
    """Evaluates a mathematical expression. Examples: '2+3', '(5*4)/2'."""
    import numexpr as ne
    return str(ne.evaluate(expression))

llm = ChatOpenAI(model="gpt-4o", temperature=0)
agent = create_react_agent(llm, [search, calculator])

result = agent.invoke({"messages": [("user", "What is 15% of the current bitcoin price?")]})
print(result["messages"][-1].content)
```
- **What it demonstrates**: Full ReAct agent with two tools; `create_react_agent` wraps the LangGraph loop

```python
# Manual tool binding and ToolNode in custom LangGraph agent
from langchain_core.tools import StructuredTool
from langgraph.prebuilt import ToolNode
from langgraph.graph import StateGraph, MessagesState, START, END
from typing import Literal

tools = [search, calculator]
llm_with_tools = llm.bind_tools(tools)
tool_node = ToolNode(tools)

def call_llm(state: MessagesState):
    return {"messages": [llm_with_tools.invoke(state["messages"])]}

def should_use_tools(state: MessagesState) -> Literal["tools", "__end__"]:
    last = state["messages"][-1]
    return "tools" if last.tool_calls else END

builder = StateGraph(MessagesState)
builder.add_node("llm", call_llm)
builder.add_node("tools", tool_node)
builder.add_edge(START, "llm")
builder.add_conditional_edges("llm", should_use_tools)
builder.add_edge("tools", "llm")  # loop back
agent = builder.compile()
```
- **What it demonstrates**: Custom agent graph with explicit ToolNode and loop-back edge

```python
# Tool with error handling and Pydantic schema
from pydantic import BaseModel, Field
from langchain_core.tools import StructuredTool

class CalculatorArgs(BaseModel):
    expression: str = Field(description="Math expression to evaluate, e.g. '(2+3)*4'")

def calculator(expression: str) -> str:
    """Evaluates a math expression."""
    import numexpr as ne
    return str(ne.evaluate(expression.strip()))

safe_calculator = StructuredTool.from_function(
    func=calculator, args_schema=CalculatorArgs, handle_tool_error=True
)
```
- **What it demonstrates**: Pydantic schema for precise arg descriptions + auto error recovery

## Reference Tables

| Tool Creation Method | When to Use |
|---|---|
| `@tool` decorator | Simple function with clear docstring; fastest option |
| `StructuredTool.from_function` | Need explicit `name`, `description`, `args_schema` |
| Subclass `BaseTool` | Stateful tool or custom async implementation |
| `convert_runnable_to_tool` | Wrapping an existing LangChain `Runnable` |

| Agent Pattern | Best For | Trade-off |
|---|---|---|
| ReAct | Discovery tasks, unknown tool sequence | Non-deterministic, can loop |
| Plan-and-Solve | Structured multi-step execution | More rigid, needs good planning LLM |
| Tool-calling LLM (single turn) | Simple lookups, one tool | No recovery, no iteration |

## Worked Example

**Building a research agent that searches and calculates**

```python
from langchain_openai import ChatOpenAI
from langchain_core.tools import tool
from langgraph.prebuilt import create_react_agent
from langchain_core.messages import HumanMessage

@tool
def web_search(query: str) -> str:
    """Search the web for current facts, prices, events. Returns top results."""
    # Use Tavily, SerpAPI, or DuckDuckGo in practice
    return f"[Mock] Search result for '{query}': Bitcoin price is $95,000."

@tool
def calculate(expression: str) -> str:
    """Evaluate a mathematical expression like '0.15 * 95000'. Returns numeric result."""
    import numexpr as ne
    return str(ne.evaluate(expression))

agent = create_react_agent(ChatOpenAI(model="gpt-4o", temperature=0), [web_search, calculate])

# Trace of execution:
# 1. LLM reasons: "I need current BTC price" → tool_call: web_search("bitcoin price")
# 2. ToolMessage returns "$95,000"  
# 3. LLM reasons: "Now calculate 15% of 95000" → tool_call: calculate("0.15 * 95000")
# 4. ToolMessage returns "14250.0"
# 5. LLM responds: "15% of the current Bitcoin price ($95,000) is $14,250."

result = agent.invoke({"messages": [HumanMessage(content="What is 15% of the current bitcoin price?")]})
```

Key insight: the agent calls tools in sequence, each tool result informs the next decision — this is the ReAct loop in action.

## Key Takeaways

1. Tools are Python functions with OpenAPI schemas — the description string is critical; it IS the prompt that tells the LLM when and how to call the tool
2. `@tool` decorator is the fastest path; `StructuredTool.from_function` gives full schema control; `BaseTool` subclass is for stateful tools
3. `create_react_agent(llm, tools)` is the one-liner for production-ready ReAct agents; builds a LangGraph loop internally
4. `ToolNode` in a custom LangGraph graph replaces manual tool dispatch; routes `AIMessage.tool_calls` → executes → returns `ToolMessage`
5. Always set `handle_tool_error=True` for external tool calls — LLMs can auto-recover from tool failures when they receive the error as a string

## Connects To

- **Ch3**: `create_react_agent` returns a LangGraph graph; all Ch3 patterns (checkpointing, human-in-the-loop) apply directly
- **Ch4**: Tools can include retrievers (RAG as a tool); this is Agentic RAG
- **Ch6**: Multi-agent systems build on top of single-agent patterns with handoffs between agents
- **ReAct paper**: Yao et al. 2022, arxiv.org/abs/2210.03629 — the theoretical foundation
