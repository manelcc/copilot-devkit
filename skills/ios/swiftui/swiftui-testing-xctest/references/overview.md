# SwiftUI Testing XCTest Overview

Official references:
- https://developer.apple.com/documentation/xctest

## Workflow

```mermaid
flowchart TD
  A[Define acceptance scenarios] --> B[Write unit tests for view model and domain]
  B --> C[Add async XCTest coverage]
  C --> D[Mock external dependencies]
  D --> E[Add UI tests for critical flows]
  E --> F[Run performance tests when needed]
  F --> G[Report and stabilize flaky tests]
```

## Notes
- Favor deterministic tests over integration-heavy tests.
- Keep UI tests focused on high-value user journeys.
