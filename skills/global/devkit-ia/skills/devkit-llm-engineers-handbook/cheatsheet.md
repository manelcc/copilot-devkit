# LLM Engineer's Handbook Cheatsheet

## Decision Rules

| If this is true | Then do this | Because |
|---|---|---|
| You are starting a new LLM product | Design with FTI from day one | It prevents coupling between batch and online concerns |
| You need domain-specific behavior quickly | Start with RAG before SFT | Faster iteration and easier rollback |
| SFT quality is inconsistent | Improve dataset curation before tuning params | Data quality dominates outcome quality |
| Behavior is still off after SFT | Add preference alignment (DPO first) | It optimizes response preference directly |
| RAG answers are vague or off-topic | Add filtered retrieval + reranking | Precision and grounding usually improve |
| p95 latency misses SLO | Apply KV cache and continuous batching first | Highest-impact low-risk optimizations |
| Serving cost is too high | Evaluate quantization with regression suite | Memory/speed gains can be large if quality holds |
| Releases cause regressions | Enforce CI/CD/CT and prompt monitoring | Continuous checks reduce production risk |

## Deployment Choice Tree

| Question | Choice |
|---|---|
| Need immediate response to user? | Online inference |
| Can response be delayed and queued? | Async inference |
| Processing large offline jobs? | Batch transform |
| Team and product still early? | Start monolith |
| Need independent scaling/isolation? | Move to microservices |

## Fine-Tuning Selection Matrix

| Constraint | Preferred method | Notes |
|---|---|---|
| Highest quality, large budget | Full fine-tuning | Most expensive compute footprint |
| Balanced quality/cost | LoRA | Good default PEFT option |
| Tight memory budget | QLoRA | Strong efficiency for limited hardware |

## RAG Optimization Ladder

| Stage | First lever | Second lever | Failure smell |
|---|---|---|---|
| Pre-retrieval | Query expansion | Self-querying | User asks clear question, retrieval still misses topic |
| Retrieval | Metadata filters | Top-k tuning | Context is broad but irrelevant |
| Post-retrieval | Reranking | Context compression | Model cites weak/noisy passages |

## Thresholds and Defaults

| Domain | Practical default |
|---|---|
| Feature index refresh | At least daily, faster if source churn is high |
| Evaluation gating | Block release on task-critical regressions |
| Preference labeling | Prioritize label consistency over raw volume |
| Autoscaling policy | Conservative min, burst-aware max, explicit cooldown |
| Monitoring | Track quality, grounding, latency, and error rate together |

## Tells and Smells

| Smell | Likely root cause | First fix |
|---|---|---|
| Hallucinations despite RAG | Retrieval precision too low | Add filters/reranking and inspect chunks |
| Great benchmark score, poor UX | Domain/task mismatch | Build product-specific evaluation set |
| Training loss improves, behavior worsens | Data/template quality issue | Audit instruction format and dataset quality |
| Latency spikes at peak traffic | Under-tuned batching/scaling | Tune batching and autoscaling policy |
| Frequent prod surprises | Weak LLMOps controls | Add CI/CD/CT gates and monitoring alerts |
