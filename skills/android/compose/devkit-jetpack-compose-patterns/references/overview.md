# Jetpack Compose Patterns Overview

Origen de referencia:
- Android Skills repository: `jetpack-compose/adaptive`
- Android Skills repository: `jetpack-compose/migration/migrate-xml-views-to-jetpack-compose`

## Workflow

```mermaid
flowchart TD
  A[Model UI state and events] --> B[Hoist state to Route/ViewModel boundary]
  B --> C[Choose remember or rememberSaveable]
  C --> D[Render lists with LazyColumn and stable keys]
  D --> E[Apply side effects with LaunchedEffect and DisposableEffect]
  E --> F[Use custom Layout only when required]
  F --> G[Tune with derivedStateOf and immutable models]
  G --> H[Validate previews, behavior, and recomposition]
```

## Notes
- Keep composables mostly stateless and pass callbacks downward.
- Side effects should be lifecycle-aware and cancelable.
- Stable immutable models are key to predictable recomposition.