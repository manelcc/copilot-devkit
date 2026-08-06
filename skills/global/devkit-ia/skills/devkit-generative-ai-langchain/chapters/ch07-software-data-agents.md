# Chapter 7: Software Development and Data Analysis Agents

## Core Idea
LLMs as coding interfaces (natural language → code) are real but bounded — productivity gains are 4–22% in independent studies vs vendor-claimed 55%; the effective approach is hybrid: LLMs for boilerplate, exploration, and communication; humans for architecture, security, and complex analysis.

## Frameworks Introduced

- **Python REPL Agent**: Agent equipped with `PythonREPLTool` that can write and execute Python code in a live REPL environment, iterate based on output, and return final results
  - When to use: exploratory data analysis, ML model training, complex calculations that LLMs can't do natively
  - How: `create_python_agent(llm, tool=PythonREPLTool(), agent_type=AgentType.ZERO_SHOT_REACT_DESCRIPTION)` — agent writes Python, executes it, sees output, iterates

- **Pandas DataFrame Agent**: Specialized agent with access to pandas DataFrame operations; converts natural language questions to pandas operations
  - When to use: business analysts querying structured data without SQL/Python knowledge; exploratory analysis via chat
  - How: `create_pandas_dataframe_agent(llm, df, verbose=True)` → agent generates and executes pandas code to answer questions

- **Repository RAG**: RAG system over a codebase — chunk code files by function/class, embed with code-aware embeddings, retrieve relevant code context before generation
  - When to use: documentation Q&A, refactoring assistance, understanding unfamiliar codebases
  - How: load with `GenericLoader` + `LanguageSplitter`, embed with `OpenAIEmbeddings` (or code-specific model), standard RAG pipeline on top

- **Documentation RAG**: RAG over official library documentation to reduce hallucinations about API details and provide version-correct answers
  - When to use: any coding agent that needs accurate library/framework knowledge
  - How: index official docs → use as retriever tool in the agent's tool list

- **LLM-as-Judge for Code Validation**: Use a second LLM call to validate generated code against security, correctness, and style criteria before execution
  - When to use: production code generation; any time generated code may be executed
  - How: code → security_review_prompt | validator_llm → structured critique with pass/fail

## Key Concepts

- **PythonREPLTool**: `langchain_experimental.tools` — executes arbitrary Python with caller's permissions; CRITICAL SECURITY NOTE: never use in production without sandboxing
- **Code LLM Benchmarks**: HumanEval (function completion), MBPP (basic Python programming), SWE-Bench (software engineering tasks), SWE-Lancer (freelance tasks — top model scored 26.2%)
- **Three phases of Code LLM evolution**: Foundation (2021 - Codex), Expansion (2022 - ChatGPT), Diversification (2023+ - specialized models, open-source parity)
- **Vibe Coding**: Informal term for directing LLMs to generate code entirely from natural language descriptions, without writing any code yourself
- **Security Validation Framework**: 4-step process: (1) static analysis of generated code, (2) dependency security scan, (3) sandbox execution with resource limits, (4) output validation against expected behavior
- **Two-tier development future**: Natural language = high-level interface for design/prototyping; traditional code = precise implementation details (IDC projects 70% of new digital solutions will use natural language by 2028)
- **Text-to-SQL limitations**: Strong on simple Spider benchmark, weaker on realistic BIRD benchmark; accuracy drops with complex joins and implicit schema knowledge

## Mental Models

- **"LLMs excel at unstructured text; traditional methods excel at structured data"**: Use LLMs for narration, translation, code generation — use pandas/numpy/sklearn for actual numerical computation
- **"Boilerplate accelerator, not architect"**: LLMs save time on repetitive code patterns, import statements, test scaffolding; human judgment required for design decisions, security, and edge cases
- **Security sandwich for code agents**: validate input intent → execute in sandbox → validate output behavior → only then use the result
- **"Repository RAG beats fine-tuning"**: For codebase-specific Q&A, embedding the repo and retrieving context is faster, cheaper, and more accurate than fine-tuning

## Anti-patterns

- **Running `PythonREPLTool` in production without sandboxing**: Executes with full process permissions; arbitrary code injection → data exfiltration, system compromise; always use Docker/RestrictedPython/gVisor
- **Trusting LLM-generated code without review**: Studies show higher bug rates in AI-assisted code; always review security-sensitive code (auth, crypto, input validation)
- **Using general embeddings for code retrieval**: Semantic text embeddings don't capture code structure well; use code-specific models (CodeBERT, StarCoder embeddings) for repository RAG
- **Asking LLMs for complex numerical analysis**: LLMs can generate plausible-looking statistics that are mathematically wrong; always execute and verify computation outputs

## Code Examples

```python
# Python REPL agent for ML tasks (DEVELOPMENT ONLY - not production)
from langchain_experimental.agents.agent_toolkits.python.base import create_python_agent
from langchain_experimental.tools.python.tool import PythonREPLTool
from langchain_anthropic import ChatAnthropic
from langchain.agents.agent_types import AgentType

agent = create_python_agent(
    llm=ChatAnthropic(model='claude-3-7-sonnet-20240326'),
    tool=PythonREPLTool(),
    verbose=True,
    agent_type=AgentType.ZERO_SHOT_REACT_DESCRIPTION,
)

# Agent writes Python, executes it, sees output, iterates
result = agent.run("""
Train a single neuron neural network in PyTorch for y=2x.
Train for 1000 epochs, print loss every 100 epochs.
Return prediction for x=5.
""")
```
- **What it demonstrates**: Full Python REPL agent loop — write → execute → observe → iterate

```python
# Pandas DataFrame agent for natural language data analysis
import pandas as pd
from langchain_experimental.agents import create_pandas_dataframe_agent
from langchain_openai import ChatOpenAI

df = pd.read_csv("sales_data.csv")
agent = create_pandas_dataframe_agent(
    ChatOpenAI(model="gpt-4o", temperature=0),
    df,
    verbose=True,
    allow_dangerous_code=True  # explicit acknowledgment required
)

result = agent.invoke("What is the average revenue by region for Q4?")
# Agent translates to: df.groupby('region')['revenue'].mean()...
```
- **What it demonstrates**: Natural language → pandas operations via agent

```python
# Repository RAG for codebase Q&A
from langchain_community.document_loaders.generic import GenericLoader
from langchain_community.document_loaders.parsers import LanguageParser
from langchain.text_splitter import Language, RecursiveCharacterTextSplitter
from langchain_openai import OpenAIEmbeddings
from langchain_community.vectorstores import Chroma

# Load Python files from repo
loader = GenericLoader.from_filesystem("./src", glob="**/*.py",
    suffixes=[".py"], parser=LanguageParser())
docs = loader.load()

# Split by Python function/class boundaries  
splitter = RecursiveCharacterTextSplitter.from_language(
    language=Language.PYTHON, chunk_size=2000, chunk_overlap=200
)
chunks = splitter.split_documents(docs)
vector_store = Chroma.from_documents(chunks, OpenAIEmbeddings())
retriever = vector_store.as_retriever(search_kwargs={"k": 5})
```
- **What it demonstrates**: Code-aware chunking preserving function/class boundaries

## Reference Tables

| Tool | Task | Security | Use Case |
|---|---|---|---|
| `PythonREPLTool` | Arbitrary Python | CRITICAL RISK | Dev/demo only |
| `PandasDataFrameAgent` | DataFrame analysis | Medium | Data analysis |
| Documentation RAG | API queries | Safe | Reduce hallucinations |
| Repository RAG | Codebase Q&A | Safe | Code understanding |

| Code LLM Benchmark | What It Tests | Reality Check |
|---|---|---|
| HumanEval | Function completion | Easiest — basic functions |
| MBPP | Basic Python programming | Moderate difficulty |
| SWE-Bench | Real GitHub issues | Hard — system-level changes |
| SWE-Lancer | Freelance tasks | Best model: 26.2% completion |

## Worked Example

**Data science agent analyzing a sales dataset**

```python
import pandas as pd
from langchain_experimental.agents import create_pandas_dataframe_agent
from langchain_openai import ChatOpenAI

# Simulate realistic sales data
df = pd.DataFrame({
    'date': pd.date_range('2024-01-01', periods=90, freq='D'),
    'region': ['North', 'South', 'East'] * 30,
    'product': ['A', 'B', 'C'] * 30,
    'revenue': [1000 + i*10 + (i%7)*50 for i in range(90)],
    'units': [100 + i%20 for i in range(90)]
})

agent = create_pandas_dataframe_agent(
    ChatOpenAI(model="gpt-4o", temperature=0),
    df, verbose=True, allow_dangerous_code=True
)

# Natural language queries → pandas operations
q1 = agent.invoke("Which region had the highest average monthly revenue?")
# Generates: df.groupby([df['date'].dt.month, 'region'])['revenue'].mean().groupby('region').mean()

q2 = agent.invoke("Is there a correlation between units sold and revenue?")
# Generates: df[['units', 'revenue']].corr()

q3 = agent.invoke("Create a trend summary showing revenue growth per quarter by region")
# Generates: df.groupby([df['date'].dt.quarter, 'region'])['revenue'].sum().reset_index()
```

Key insight: the agent generates and executes correct pandas code for each question — the analyst gets SQL-like natural language querying without writing code.

## Key Takeaways

1. LLM productivity gains in coding are real but 4–22% in independent studies — not 55%; most value comes from boilerplate reduction and cognitive load relief
2. `PythonREPLTool` is development-only — never expose arbitrary code execution in production without Docker/RestrictedPython sandboxing
3. Repository RAG + code-aware chunking (`RecursiveCharacterTextSplitter.from_language(Language.PYTHON)`) is the right approach for codebase Q&A — better than fine-tuning
4. Pandas DataFrame agent translates natural language to pandas operations — democratizes data analysis; still needs human review of results
5. Generated code requires human review: security-sensitive code (auth, crypto, input validation) must always be reviewed before deployment
6. Use LLMs for text-heavy data tasks (narration, translation, classification); use traditional statistics for numerical analysis

## Connects To

- **Ch5**: Python REPL agent is a ReAct agent with a code execution tool
- **Ch4**: Documentation RAG and Repository RAG are RAG applications built on Ch4 patterns
- **Ch6**: Code agents become sub-agents in multi-agent software engineering workflows
- **Ch8**: Generated code requires trajectory evaluation and output validation from Ch8
- **SWE-Bench/SWE-Lancer benchmarks**: Canonical evaluations for software engineering agents
