# Chapter 8: Inference Optimization

## Core Idea
Efficient LLM serving is a systems optimization problem balancing latency, throughput, memory footprint, and quality.

## Frameworks Introduced
- **Latency-Throughput Optimization Ladder**
  - When to use: Serving cost or response time is too high.
  - How: Apply KV cache, batching, decoding optimizations, and parallelism in sequence.
- **Parallelism Strategy Matrix**
  - When to use: Scaling across hardware resources.
  - How: Select data, pipeline, or tensor parallelism by model and infra constraints.
- **Quantization Decision Framework**
  - When to use: Need memory and speed gains with acceptable quality loss.
  - How: Choose quantization format and validate on task-critical metrics.

## Key Concepts
- **KV cache**: Reuse attention states across autoregressive decoding.
- **Continuous batching**: Dynamic request packing.
- **Speculative decoding**: Faster decoding via draft-and-verify patterns.
- **Tensor parallelism**: Split compute across devices.
- **GGUF / GPTQ / EXL2**: Model quantization formats/approaches.

## Mental Models
Treat inference tuning as **Pareto optimization**: improve one metric while tracking trade-offs. Optimize the **hot path first** before infrastructure expansion.

## Anti-patterns
- **Quantize-first without evaluation**: Can silently break critical behaviors.
- **Scale hardware before software tuning**: Increases cost without guaranteed gains.

## Worked Example
A service misses latency SLO at peak traffic:
1. Enable KV cache and continuous batching.
2. Profile tail latency and GPU memory.
3. Test 4-bit quantized candidate against baseline on regression set.
4. Deploy if latency target is met and quality drop is within acceptable threshold.

## Key Takeaways
1. Inference performance requires iterative measurement.
2. Parallelism and quantization choices depend on workload shape.
3. Guard quality with regression checks for every optimization.

## Connects To
- **Ch 10**: Deployment topology constrains optimization options.
- **Ch 7**: Quality regression testing is mandatory after tuning.
