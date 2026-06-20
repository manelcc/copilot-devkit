# SwiftUI Patterns Overview

Official references:
- https://developer.apple.com/documentation/swiftui
- https://developer.apple.com/documentation/swift/concurrency

## Workflow

```mermaid
flowchart TD
  A[Define UI states and intents] --> B[Assign state ownership: @State, @Binding, @ObservableObject]
  B --> C[Build routes with NavigationStack]
  C --> D[Load data in task lifecycle]
  D --> E[Render with List or LazyVStack]
  E --> F[Validate loading, error, empty and content states]
```

## Notes
- Prefer explicit state boundaries to avoid side effects.
- Use NavigationStack as default for SwiftUI navigation.
