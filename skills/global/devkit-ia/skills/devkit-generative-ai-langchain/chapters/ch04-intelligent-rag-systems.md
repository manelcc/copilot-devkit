# Chapter 4: Building Intelligent RAG Systems

## Core Idea
RAG solves the core LLM limitation of static knowledge by dynamically retrieving relevant external documents at query time — transforming LLMs from closed-book generators into verifiable, knowledge-grounded responders. Use RAG when answers must be current, domain-specific, or verifiable.

## Frameworks Introduced

- **RAG Pipeline (2-stage)**: Indexing (offline: load → chunk → embed → store) + Query (online: retrieve → augment → generate)
  - When to use: any system requiring accurate, verifiable, or up-to-date answers from external documents
  - How: `document_loader.load()` → `text_splitter.split_documents()` → `embeddings.embed_documents()` → `vector_store.from_documents()` (indexing); then `retriever.invoke(query)` → format context → `llm.invoke(prompt + context)` (query)

- **Hybrid Retrieval (BM25 + Dense Vector)**: Combines sparse keyword search with dense semantic search; results are merged and re-ranked
  - When to use: technical domains with specific terminology (code, medical, legal), or when pure semantic search misses exact matches
  - How: `EnsembleRetriever([bm25_retriever, vector_retriever], weights=[0.5, 0.5])`

- **Advanced RAG Techniques Stack** (progressive complexity):
  - Query Transformation: rewrite/expand query before retrieval → fixes ambiguous user queries
  - HyDE (Hypothetical Document Embeddings): generate a fake answer, embed it, retrieve by its embedding
  - Multi-Query: LLM generates N versions of the query; merge all retrieved results
  - Re-ranking (Cohere/cross-encoder): re-score retrieved docs by relevance after initial fetch
  - MMR (Maximum Marginal Relevance): balance relevance vs diversity (`lambda_mult=0.5`)
  - Contextual Compression: extract only the relevant portion of each retrieved chunk
  - Source Attribution: cite sources inline `[1]`, `[2]`; include reference list
  - Self-Consistency Checking: second LLM call validates generated answer against retrieved context
  - CRAG (Corrective RAG): evaluate retrieved docs; if low quality, trigger web search fallback

- **Agentic RAG**: Agent orchestrates retrieval, tool calls, multi-step reasoning to answer complex queries; extends beyond single-vector-store lookup

## Key Concepts

- **Embedding**: Dense vector representation of text; semantically similar texts → nearby vectors; must use same model for indexing and querying
- **Vector Store**: Specialized database for high-dimensional vector similarity search (FAISS, Chroma, Pinecone, pgvector)
- **Chunking**: Splitting documents into retrievable units; `RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=200)` is the default
- **Chunk Overlap**: Ensures context isn't lost at chunk boundaries; typically 10–20% of chunk_size
- **Similarity Search**: `vector_store.similarity_search(query, k=4)` — returns k most similar document chunks
- **MMR**: `max_marginal_relevance_search(query, k=5, fetch_k=20, lambda_mult=0.5)` — 0=max diversity, 1=max relevance
- **Document Loader**: LangChain abstraction for ingesting text from any source (PyPDFLoader, WebBaseLoader, JSONLoader, CSVLoader, etc.)
- **Retriever**: `vector_store.as_retriever(search_type="similarity", search_kwargs={"k":4})` — Runnable interface for retrieval
- **RAGAS**: Framework for evaluating RAG systems on faithfulness, answer relevance, context precision, context recall
- **CRAG**: Corrective RAG — adds a document quality evaluator step that falls back to web search if retrieved docs score poorly
- **Source Attribution**: Attaching citation numbers to retrieved docs and requiring the LLM to reference them inline

## Mental Models

- Use **"library analogy"**: chunking = cataloguing → embedding = card catalog → vector store = organized shelves → retriever = librarian → generator = author synthesizing sources
- **When to choose RAG vs. fine-tuning**: RAG wins when knowledge changes frequently or needs attribution; fine-tuning wins for style/behavior adaptation on static knowledge
- **Progressive RAG complexity**: Start with naive RAG (similarity search only) → add hybrid search if vocabulary mismatch → add re-ranking if precision is low → add query transformation if users can't articulate well → add CRAG only when reliability is mission-critical
- **Chunk size selection**: smaller chunks (256–512) = better precision, worse context; larger chunks (1024–2048) = better context, higher cost; 1000 with 200 overlap = good default

## Anti-patterns

- **Using different embedding models for indexing vs querying**: Retrieval fails silently — vectors are incomparable across model versions
- **No chunk overlap**: Context at chunk boundaries is lost; answers become incomplete
- **Top-k too small (k=1 or 2)**: Single retrieved chunk misses relevant context; use k=4–6 and re-rank
- **Pure vector search on technical terminology**: Exact acronyms ("API v2.3") may have poor semantic neighbors; hybrid BM25 + vector is required
- **Trusting LLM to self-report hallucinations**: Self-consistency checking requires a second LLM call with a verification prompt — the same model that hallucinated cannot reliably detect it

## Code Examples

```python
# Complete naive RAG pipeline
from langchain_community.document_loaders import PyPDFLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_openai import OpenAIEmbeddings, ChatOpenAI
from langchain_community.vectorstores import FAISS
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough

# INDEXING
loader = PyPDFLoader("document.pdf")
docs = loader.load()
splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=200)
chunks = splitter.split_documents(docs)
vector_store = FAISS.from_documents(chunks, OpenAIEmbeddings())

# QUERY
retriever = vector_store.as_retriever(search_kwargs={"k": 4})
prompt = ChatPromptTemplate.from_template(
    "Answer based on context only.\nContext: {context}\nQuestion: {question}"
)
rag_chain = (
    {"context": retriever, "question": RunnablePassthrough()}
    | prompt | ChatOpenAI(temperature=0) | StrOutputParser()
)
answer = rag_chain.invoke("What is the main topic?")
```
- **What it demonstrates**: End-to-end RAG in LCEL with the retriever as a Runnable

```python
# Hybrid retrieval: BM25 + dense vectors
from langchain_community.retrievers import BM25Retriever
from langchain.retrievers import EnsembleRetriever

bm25 = BM25Retriever.from_documents(chunks, k=4)
dense = vector_store.as_retriever(search_kwargs={"k": 4})
hybrid = EnsembleRetriever(retrievers=[bm25, dense], weights=[0.5, 0.5])
```
- **What it demonstrates**: Hybrid search combining keyword and semantic retrieval

## Reference Tables

| Technique | When to Use | Complexity | Trade-off |
|---|---|---|---|
| Naive RAG | Quick prototyping | Low | Low precision |
| Hybrid BM25+Dense | Technical/exact terminology | Medium | Slower indexing |
| Re-ranking | Initial retrieval precision low | Medium | +Latency |
| Query Transformation | Ambiguous user queries | Medium | +LLM call |
| MMR | Diverse perspectives needed | Low | Slightly less relevant |
| Contextual Compression | Long docs, limited context | Medium | +Processing |
| Source Attribution | Legal/medical/educational | Medium | Less fluent |
| CRAG | Mission-critical accuracy | High | High complexity |
| Agentic RAG | Complex multi-step queries | Very High | Hard to debug |

## Worked Example

**Source attribution pipeline for a legal assistant**

Goal: Answer questions about contracts and cite the exact clause.

```python
from langchain_core.prompts import ChatPromptTemplate
from langchain_openai import ChatOpenAI, OpenAIEmbeddings
from langchain_community.vectorstores import FAISS
from langchain_core.output_parsers import StrOutputParser

def format_with_citations(docs):
    return "\n\n".join(
        f"[{i+1}] {doc.metadata.get('source','?')}, p.{doc.metadata.get('page','?')}\n{doc.page_content}"
        for i, doc in enumerate(docs)
    )

attribution_prompt = ChatPromptTemplate.from_template("""
You are a legal assistant. Answer using ONLY the provided sources.
For every claim, include a citation like [1] or [2].
End with a numbered reference list.

Sources:
{sources}

Question: {question}
""")

retriever = FAISS.from_documents(contract_chunks, OpenAIEmbeddings()).as_retriever(search_kwargs={"k":3})
llm = ChatOpenAI(model="gpt-4o", temperature=0)

def answer_with_attribution(question):
    docs = retriever.invoke(question)
    return (attribution_prompt | llm | StrOutputParser()).invoke({
        "sources": format_with_citations(docs),
        "question": question
    })
```

Result: "The termination clause [1] states 30 days notice is required. Payment terms [2] are Net-30. Reference: [1] Contract_v2.pdf, p.4; [2] Contract_v2.pdf, p.7."

## Key Takeaways

1. RAG = Indexing pipeline (offline) + Query pipeline (online) — always build both before deploying
2. Chunk size 1000 + overlap 200 is the safe default; adjust based on retrieval quality metrics
3. Always use hybrid retrieval (BM25 + vector) for technical/specialized domains — pure semantic search misses exact terminology
4. Re-ranking is the single highest-impact improvement to retrieval precision after basic setup
5. RAGAS metrics (faithfulness, answer relevance, context precision/recall) are the standard RAG evaluation suite
6. Naive RAG → add complexity progressively, only when a specific quality problem is diagnosed

## Connects To

- **Ch2**: RAG chains are LCEL chains; the retriever is a Runnable
- **Ch3**: Corrective RAG and Agentic RAG use LangGraph for the conditional/multi-step logic
- **Ch5**: Agentic RAG extends agents with retrieval tools
- **Ch6**: Multi-agent RAG distributes retrieval across specialized agents
- **Ch8**: RAGAS provides the evaluation framework for all RAG quality metrics
