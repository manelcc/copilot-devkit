# Cheatsheet

## Decision Rules
| If | Then | Because |
|---|---|---|
| Task has compliance risk | Use bounded autonomy + human checkpoint | Prevent unsafe irreversible actions |
| External action can change state | Enforce pre/post conditions | Reduce side-effect failures |
| Output uncertainty is high | Trigger reflection + evidence retrieval | Improve factual reliability |
| Work is multi-domain | Use CWD orchestration | Improves specialization and parallelism |
| Incident repeats | Add guardrail + regression test | Converts failures into controls |

## Quick Flow
| Step | Question | Action |
|---|---|---|
| 1 | Is goal measurable? | Define objective function + rubric |
| 2 | Are constraints explicit? | Add policy, risk, and cost limits |
| 3 | Is plan decomposed? | Build short, verifiable steps |
| 4 | Are tools safe? | Add tool gates and fallback path |
| 5 | Is output trustworthy? | Attach confidence + traceability |

## Trade-off Matrix
| Option | Reliability | Speed | Cost |
|---|---|---|---|
| Single-pass prompting | Low | High | Low |
| Plan-Act-Reflect | High | Medium | Medium |
| CWD multi-agent | High | Medium | Medium-High |
| Full human-in-loop | Very High | Low | High |

## Tells & Smells
- If the same failure appears twice, your control is policy-weak or test-weak.
- If outputs are fluent but unverifiable, confidence signaling is missing.
- If latency spikes with little quality gain, planning granularity is too fine.
