# Chapter 10: Inference Pipeline Deployment

## Core Idea
Deployment is a strategic choice between latency, throughput, data sensitivity, and operational complexity; architecture and scaling policies must reflect product constraints.

## Frameworks Introduced
- **Deployment Mode Selection (Online, Async, Batch)**
  - When to use: Mapping workloads to serving patterns.
  - How: Choose mode by user latency expectation and processing volume.
- **Monolith vs Microservices for Serving**
  - When to use: Defining service boundaries for inference systems.
  - How: Favor monolith for speed of iteration; microservices for independent scaling and isolation.
- **Autoscaling Policy Design**
  - When to use: Handling traffic spikes cost-effectively.
  - How: Configure targets, limits, and cooldown policies around observed demand.

## Key Concepts
- **Online inference**: Synchronous low-latency serving.
- **Async inference**: Deferred processing for long tasks.
- **Batch transform**: Offline high-throughput processing.
- **SageMaker endpoint**: Managed deployment surface.
- **Business microservice**: API layer (for example, FastAPI) around model endpoints.

## Mental Models
Use **workload-fit deployment** instead of one-size-fits-all serving. Treat autoscaling as **control systems tuning**, not a one-time setting.

## Anti-patterns
- **Defaulting to microservices too early**: Adds distributed complexity without clear need.
- **No scaling guardrails**: Leads to either outages or runaway cost.

## Worked Example
A customer-facing assistant with daytime traffic bursts:
1. Keep model serving on managed real-time endpoints.
2. Expose business API for auth, retries, and response shaping.
3. Add autoscaling with conservative min capacity and burst headroom.
4. Monitor p95 latency and scale-policy oscillations.

## Key Takeaways
1. Deployment strategy should follow product behavior and SLOs.
2. Keep service boundaries intentional and measurable.
3. Scaling policies require iterative calibration.

## Connects To
- **Ch 8**: Inference optimizations influence capacity planning.
- **Ch 11**: CI/CD and observability complete deployment maturity.
