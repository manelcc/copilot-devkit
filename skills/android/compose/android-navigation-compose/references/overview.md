# Android Navigation Compose Overview

Origen de referencia:
- Android Skills repository: `navigation/navigation-3`

## Workflow

```mermaid
flowchart TD
  A[Define route contracts and arguments] --> B[Create NavController and root NavHost]
  B --> C[Implement composable destinations]
  C --> D[Parse and validate destination arguments]
  D --> E[Add deep link URI contracts]
  E --> F[Implement top-level multiple back stacks]
  F --> G[Enable saveState and restoreState]
  G --> H[Validate back/up/deeplink behavior]
```

## Notes
- Keep route definitions centralized and explicit.
- Prefer stable destination contracts to avoid broken links.
- Validate behavior for tab switching and deep link re-entry.