# iOS Swift Concurrency Overview

Official references:
- https://developer.apple.com/documentation/swift/concurrency

## Workflow

```mermaid
flowchart TD
  A[Identify async boundaries] --> B[Refactor to async/await]
  B --> C[Run scoped work in Task]
  C --> D[Use TaskGroup for fan-out]
  D --> E[Isolate UI updates with MainActor]
  E --> F[Handle cancellation and failures]
  F --> G[Validate deterministic behavior in tests]
```

## Notes
- Keep actor isolation explicit.
- Use checked continuations to bridge legacy callbacks only when required.
