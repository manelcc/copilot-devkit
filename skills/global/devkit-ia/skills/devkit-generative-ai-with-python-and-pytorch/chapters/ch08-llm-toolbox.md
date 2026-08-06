# Chapter 8: LLM Toolbox

## Core Idea
Building production LLM applications requires more than just an API call. LangChain provides the ecosystem to wire LLMs into full applications: prompt templates, vector databases for RAG, LangGraph for stateful agentic workflows (with memory, tool use, and human-in-the-loop), and LangSmith for observability and debugging.

## Frameworks Introduced

- **LangChain**:
  - What: Python framework for composing LLM applications from modular components.
  - Core components: Models (ChatModel wrappers), Prompts (ChatPromptTemplate, SystemMessage, HumanMessage), Output Parsers (StrOutputParser), Chains (LCEL pipeline: `chain = prompt | model | parser`).
  - LCEL (LangChain Expression Language): pipe-based composition. `chain.invoke(inputs)` runs the full chain.

- **RAG (Retrieval-Augmented Generation)**:
  - When to use: when the LLM lacks domain knowledge or needs to answer from specific documents without full fine-tuning.
  - How (4-step pipeline):
    1. **Load**: ingest documents (GitLoader, PDFLoader, WebLoader)
    2. **Split**: chunk with `RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=200)`
    3. **Embed + Store**: embed chunks into a vector DB (InMemoryVectorStore, Chroma, Pinecone)
    4. **Retrieve + Generate**: `vector_store.similarity_search(query)` → prepend retrieved context to LLM prompt
  - Key parameter: `chunk_overlap=200` — ensures context isn't lost at chunk boundaries.

- **LangGraph**:
  - When to use: complex LLM applications requiring branching logic, memory, tool use, or human-in-the-loop.
  - How: define a state machine as a directed graph. Nodes are Python functions (retrieve, generate, action_step). Edges define transitions. `StateGraph.compile()` creates the runnable.
  - Memory: add `MemorySaver()` as checkpointer → conversation history persisted per thread_id.
  - Human-in-the-loop: add `interrupt_before=["tool_node"]` to pause for human approval before tool execution.

- **LangSmith**:
  - When to use: debugging prompt failures, tracing multi-step LangGraph executions, tracking token usage.
  - How: set `LANGCHAIN_TRACING=true` and `LANGCHAIN_API_KEY` → all chain/graph invocations are logged automatically.

## Key Concepts

- **LCEL (LangChain Expression Language)**: pipe syntax for composing chains — `prompt | model | parser`
- **Vector Database**: stores document embeddings; queries via cosine similarity to retrieve relevant chunks
- **Embedding**: dense vector representation of text (from `MistralAIEmbeddings`, `FastEmbedEmbeddings`, etc.)
- **chunk_size / chunk_overlap**: text splitting parameters — overlap prevents context loss at boundaries
- **StateGraph**: LangGraph's core abstraction — a directed graph of nodes (functions) and edges (transitions)
- **MemorySaver**: LangGraph checkpointer storing conversation state per thread_id across invocations
- **thread_id**: key for isolating different user sessions in LangGraph memory
- **Tool**: a callable function the LLM agent can invoke (search, code execution, database lookup)
- **Human interrupt**: LangGraph `interrupt_before` pauses graph execution for human approval before a node runs
- **AIMessage**: LangChain response object containing content, token usage, model metadata

## Mental Models

- Think of LangChain as LEGO for LLMs — each component (prompt, model, parser) snaps together via `|`.
- RAG = "give the LLM the textbook page before asking the exam question" — provides factual grounding without fine-tuning.
- LangGraph = "LLM state machine" — define what happens at each step and what the transitions are.
- MemorySaver thread_id = "user session" — switch thread_id to give each user their own memory context.

## Anti-patterns

- **RAG without chunking overlap**: chunk boundaries can cut sentences mid-thought, losing context; always set chunk_overlap ≥ 10% of chunk_size.
- **Skipping LangSmith in development**: hard to debug multi-step chain failures without traces; set up tracing from day 1.
- **Ignoring token usage in AIMessage**: LLM API costs compound quickly in multi-turn conversations; monitor via `usage_metadata`.
- **No human interrupt on high-stakes tool calls**: agents with write/delete/execute tools should always pause for human approval before acting.

## Code Examples

```python
from langchain_mistralai import ChatMistralAI
from langchain_core.messages import HumanMessage, SystemMessage

# Simple chain: translate to Italian
model = ChatMistralAI(model="mistral-large-latest")
messages = [
    SystemMessage(content="Translate the following from English into Italian"),
    HumanMessage(content="hi!")
]
response = model.invoke(messages)
print(response.content)
# Output: "Ciao!\n* Salve! (Formal)\n* Buongiorno!..."
# AIMessage also contains: token_usage, model, finish_reason
```
- **What it demonstrates**: basic LangChain LLM call; AIMessage structure with content + metadata.

```python
from langchain_core.vectorstores import InMemoryVectorStore
from langchain_text_splitters import RecursiveCharacterTextSplitter

# RAG: chunk + embed + store
text_splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=200)
all_splits = text_splitter.split_documents(code)
vector_store = InMemoryVectorStore(MistralAIEmbeddings(model="mistral-large-latest"))
vector_store.add_documents(all_splits)

# Retrieve at query time
retrieved_docs = vector_store.similarity_search(user_question)
context = "\n\n".join(doc.page_content for doc in retrieved_docs)
response = model.invoke(user_question + context)
```
- **What it demonstrates**: the complete RAG pipeline from splitting → embedding → storing → similarity search → augmented generation.

```python
from langgraph.graph import StateGraph, START, END
from langgraph.checkpoint.memory import MemorySaver
from typing import TypedDict, Annotated
from langgraph.graph.message import add_messages

class State(TypedDict):
    messages: Annotated[list, add_messages]
    context: list

# Build stateful RAG agent with memory
graph_builder = StateGraph(State)
graph_builder.add_node("retrieve", retrieve)
graph_builder.add_node("generate", generate)
graph_builder.add_edge(START, "retrieve")
graph_builder.add_edge("retrieve", "generate")
graph_builder.add_edge("generate", END)

memory = MemorySaver()
graph = graph_builder.compile(checkpointer=memory)

# Invoke with session thread
config = {"configurable": {"thread_id": "user-123"}}
result = graph.invoke({"messages": "What are LangChain StateGraph args?"}, config)
```
- **What it demonstrates**: LangGraph stateful RAG agent with memory — each thread_id maintains its own conversation context.

## Worked Example

**Building a RAG chatbot over the LangChain codebase:**

1. **Load**: `GitLoader` clones the langchain repo, filters `.py` files → Python source code as documents
2. **Split**: `RecursiveCharacterTextSplitter(1000, 200)` → overlapping chunks preserving function contexts
3. **Embed**: `MistralAIEmbeddings` converts each chunk to a dense vector
4. **Store**: `InMemoryVectorStore` indexes all embeddings for fast similarity search
5. **Graph**: LangGraph routes each query through `retrieve → generate`
6. **Memory**: `MemorySaver` persists conversation state per thread_id
7. **Human interrupt**: when user asks for a human expert, graph pauses before tool execution awaiting approval

Result: chatbot answers LangChain-specific questions with actual source code context, maintains conversation history per user, and can escalate to human review for uncertain answers.

## Key Takeaways

1. LangChain's LCEL (`prompt | model | parser`) is the fastest path from idea to deployed LLM chain.
2. RAG = the go-to approach for domain-specific knowledge without fine-tuning; chunking + overlap are critical parameters.
3. LangGraph enables stateful, multi-step agentic LLM workflows with branching, memory, and human-in-the-loop.
4. MemorySaver + thread_id provides per-user conversation persistence without an external database.
5. LangSmith traces are essential for debugging; enable from the start of development.

## Connects To

- **Ch 7**: prompt templates and system instructions from Ch 7 are used in LangChain chains
- **Ch 5**: RLHF-aligned LLMs (GPT, Mistral) are the models LangChain orchestrates
- **Ch 10**: LangGraph's agentic patterns are the infrastructure behind emerging agentic applications
- **Ch 9**: optimization techniques (quantization, LoRA) reduce the inference cost of models called in chains
