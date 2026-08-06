# Glossary — Generative AI with LangChain

**AgentBench** — Multi-domain agent benchmark (Liu et al. 2023); 8 interactive environments; GPT-4 vastly outperforms open-source on cross-domain tasks (Ch8)

**Agentic RAG** — RAG system where the LLM controls retrieval decisions, query generation, and reflection on retrieved chunks; requires LangGraph for the conditional loop (Ch4, Ch6)

**API Key** — Authentication credential for LLM provider APIs; always store in environment variables, never in source code (Ch2)

**Cascading Model Approach** — Try cheapest model first; escalate to better model only if quality check fails; optimizes cost vs quality (Ch9)

**ChatPromptTemplate** — LangChain class for multi-role prompt construction `[("system","..."), ("user","{var}")]`; production-standard prompt format (Ch2)

**Chinchilla Scaling Law** — DeepMind's compute-optimal scaling: match model size to dataset size; Chinchilla (70B) outperforms GPT-3 (175B) with same compute (Ch1)

**Chunk Overlap** — Number of tokens shared between adjacent chunks during text splitting; prevents context loss at boundaries; typically 10-20% of chunk_size (Ch4)

**Chunking** — Splitting documents into retrievable units before embedding; `RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=200)` is the default (Ch4)

**Conditional Edge** — LangGraph routing function `(state) -> Literal["node_a", "node_b"]`; must use `Literal` type hint for LangGraph to auto-discover destinations (Ch3)

**Consensus Mechanism** — Multi-agent pattern where N agents solve the same task in parallel; judge or voting selects best solution; improves quality at cost of N× tokens (Ch6)

**Context Precision** — RAGAS metric: what fraction of retrieved chunks were actually useful for the answer (Ch4, Ch8)

**Context Recall** — RAGAS metric: what fraction of needed information was retrieved from the knowledge base (Ch4, Ch8)

**CRAG (Corrective RAG)** — Advanced RAG with document quality evaluator; if retrieved docs score poorly, triggers web search fallback; for mission-critical accuracy (Ch4)

**create_react_agent** — LangGraph prebuilt function creating a full ReAct agent loop as a StateGraph; accepts `llm` + `tools` list (Ch5)

**Dense Vector** — Embedding where most dimensions are non-zero; captures semantic meaning; contrasts with sparse BM25 vectors (Ch4)

**Document Loader** — LangChain abstraction for ingesting text from any source; `PyPDFLoader`, `WebBaseLoader`, `JSONLoader`, `GenericLoader` etc. (Ch4)

**Embedding** — Dense vector representation of text; semantically similar texts produce nearby vectors; must use same model for indexing and querying (Ch4)

**Emergent Capabilities** — Qualitative new abilities (few-shot reasoning, complex instruction following) that appear discontinuously as models scale; not predicted by linear extrapolation (Ch1)

**EU AI Act** — 2024 EU regulation creating high-risk AI category with stringent requirements; caused deployment delays for some AI systems in European markets (Ch10)

**Evaluation Governance** — Cross-functional working group (technical + domain + users) defining criteria, ownership, and decision-making for LLM quality; essential before production (Ch8)

**Extended Thinking (Claude)** — `thinking={"type": "enabled", "budget_tokens": N}` allocates tokens for chain-of-thought before final answer; improves complex reasoning (Ch2)

**Faithfulness** — RAGAS metric: are all claims in the answer supported by the retrieved context? Score 0–1 (Ch4, Ch8)

**FastAPI** — Python async web framework; standard pattern for exposing LangChain/LangGraph chains as REST/streaming APIs in production (Ch9)

**Few-shot Prompting** — Providing N input-output examples in the prompt; improves performance on classification, extraction; hard to scale without example selectors (Ch3)

**Hallucination** — Model confidently stating false information; arises from statistical pattern completion without true understanding; "stochastic parrots" (Bender et al. 2021) (Ch1)

**Handoff** — `Command(goto="agent_name", update={...})` transfers LangGraph execution between agents with state payload (Ch6)

**Human-in-the-loop (HIL)** — `interrupt("question")` pauses LangGraph at node boundary; `Command(resume=answer)` continues; requires checkpointer (Ch3, Ch6)

**HyDE (Hypothetical Document Embeddings)** — Advanced RAG: generate a fake answer, embed it, retrieve by its embedding; bridges vocabulary gap between query and documents (Ch4)

**KM Scaling Law (Kaplan)** — Power-law relationship between LLM performance and (model size, dataset size, compute); implies bigger → better predictably (Ch1)

**LCEL (LangChain Expression Language)** — Declarative pipe syntax `prompt | model | parser` for composing chains; provides streaming, batching, and async for free (Ch1, Ch2)

**LangGraph** — LangChain framework for stateful directed graph workflows; unlike DAGs, allows cycles; recommended for agents, multi-turn conversations, human-in-the-loop (Ch3)

**LangGraph Platform** — Cloud deployment service for LangGraph agents with persistence, streaming, and monitoring (Ch9)

**LangSmith** — LangChain's observability and evaluation platform; zero-code tracing via env vars; dataset management for offline evaluation; experiment tracking (Ch8, Ch9)

**LiteLLM** — Universal interface for multiple LLM providers with usage-based routing, response caching, automatic failover, and retry logic (Ch9)

**LLM-as-Judge** — Using a second LLM to evaluate the first LLM's output against criteria; use a more capable or different model family than the one being evaluated (Ch8)

**Maximum Marginal Relevance (MMR)** — Retrieval strategy balancing relevance and diversity; `lambda_mult=0` = max diversity, `lambda_mult=1` = max relevance (Ch4)

**MemorySaver** — LangGraph in-memory checkpointer; enables multi-turn session persistence via `thread_id`; for development and single-process deployments (Ch3)

**MessagesPlaceholder** — `ChatPromptTemplate` component that inserts a runtime list of messages (e.g., conversation history) at a specified position in the prompt (Ch2, Ch3)

**Mixture of Experts (MoE)** — Model architecture where different "expert" sub-networks activate for different inputs; large total parameters but sparse activation → efficiency (Ch10)

**Model Context Protocol (MCP)** — Anthropic's open standard for connecting AI models to tools and data sources in a structured way; emerging production standard (Ch9)

**Multi-Query Retrieval** — Advanced RAG: LLM generates N versions of the user query; retrieve for each; merge results with reciprocal rank fusion; reduces vocabulary mismatch (Ch4)

**Node** — LangGraph component: Python function `(state: MyState) -> dict` that returns partial state update (keys to update, not full state) (Ch3)

**Ollama** — Local model server for running open-source models; integrates via `ChatOllama` with identical LCEL interface to cloud models (Ch2)

**Output Parser** — LangChain component converting `AIMessage` to desired format; `StrOutputParser`, `JsonOutputParser`, `PydanticOutputParser` (Ch2)

**PandasDataFrameAgent** — Specialized agent translating natural language questions to pandas operations and executing them (Ch7)

**Plan-and-Solve Agent** — Two-phase agent: first LLM generates a full plan, then executes each step; more structured than ReAct for complex tasks with known subtask structure (Ch5)

**Process-Supervised Learning** — RLHF variant rewarding correct intermediate reasoning steps, not just final answers; makes models better at multi-step math/logic (Ch10)

**PromptTemplate** — LangChain reusable prompt with variable substitution; separates template logic from business logic; mandatory for production apps (Ch2)

**PythonREPLTool** — `langchain_experimental.tools` — executes arbitrary Python; development-only; never in production without sandboxing (Ch7)

**RAGAS** — Framework with 4 specialized metrics for RAG quality: faithfulness, answer relevancy, context precision, context recall (Ch4, Ch8)

**RAG (Retrieval-Augmented Generation)** — Architecture: retrieve relevant external documents at query time, augment the prompt with them, generate grounded answer; solves LLM knowledge cutoff and hallucination (Ch4)

**ReAct (Reasoning + Acting)** — Agent pattern: interleaved Reason → Act → Observe loop; LLM reasons about current state, selects tool, incorporates result, repeats (Yao et al. 2022) (Ch5)

**Reducer** — LangGraph function defining how node outputs are merged into state; default = replace; `Annotated[list, add]` = append; custom function for complex merge (Ch3)

**Reflection Pattern** — Multi-agent: generator produces response; critic agent provides structured feedback; generator iterates until quality threshold met (Ch6)

**RLHF (Reinforcement Learning from Human Feedback)** — Training technique aligning models with human preferences via human-scored reward signals (Ch1)

**RunnablePassthrough** — LangChain Runnable that passes input through unchanged; `.assign(key=chain)` adds new keys without losing prior state (Ch2)

**Scaling Laws** — Empirical power-law relationships between LLM performance and model size / dataset size / compute; foundation for the "bigger is better" scaling era (Ch1, Ch10)

**Semantic Router** — Routes queries to appropriate specialized agent based on semantic similarity to route descriptions (not keyword matching) (Ch6)

**Source Attribution** — RAG pattern attaching citation numbers to retrieved docs, requiring LLM to reference them inline; critical for legal/medical/educational applications (Ch4)

**SqliteSaver** — LangGraph persistent checkpointer using SQLite; enables cross-session state persistence; use for production multi-turn applications (Ch3)

**StateGraph** — LangGraph's core class; unlike DAGs, allows cycles; manages shared mutable state across all nodes (Ch3)

**Streaming** — `chain.stream()` / `graph.stream(stream_mode="messages")` yields tokens as generated; critical for responsive UIs (Ch2, Ch6)

**Superstep** — Discrete LangGraph execution iteration (from Pregel); can run multiple nodes in parallel; updates are merged atomically (Ch3)

**Temperature** — LLM parameter controlling randomness; 0.0–0.3 = factual/deterministic; 0.7+ = creative/diverse (Ch2)

**Test-Time Compute** — Giving models variable thinking budget per problem; harder problems get more tokens for internal reasoning; o1/o3/extended thinking architecture (Ch10)

**Theory of Mind (ToM)** — Ability to model others' belief states; frontier models score 0-9% on challenging ToM scenarios — fundamental current limitation (Ch10)

**Tiered Model Selection** — Route queries to different models by complexity; cheap/fast for simple queries, expensive for complex; typical savings 70-90% on simple queries (Ch9)

**ToolMessage** — LangChain message type feeding tool execution results back to LLM; must match `tool_call_id` from the preceding `AIMessage` (Ch5)

**ToolNode** — Pre-built LangGraph node executing tool calls from `AIMessage.tool_calls`, returning results as `ToolMessage`; replaces manual tool dispatch (Ch5)

**Top-p (Nucleus Sampling)** — Token selection cumulative probability threshold; 0.5 = focused, 0.9 = diverse (Ch2)

**Tree of Thoughts (ToT)** — Reasoning pattern: explore multiple reasoning paths in a tree (DFS/BFS); use replanner to generate N candidates at each node; consensus selects best (Ch6)

**TypedDict** — Python type for defining LangGraph state schema; each key with its own type; also accepts Pydantic models or dataclasses (Ch3)

**Vector Store** — Specialized database for high-dimensional vector similarity search; examples: FAISS, Chroma, Pinecone, pgvector (Ch4)

**vLLM** — High-throughput LLM serving framework with PagedAttention; maximizes GPU memory efficiency; use for self-hosted model serving at scale (Ch9)

**Zero-shot Prompting** — Task description without examples; works when role + task + context + format is clearly specified in the prompt (Ch3)
