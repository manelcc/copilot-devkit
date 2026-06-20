# Devkit Migrate XML To Compose Overview

Origen:
Migrada desde awesome-copilot: [link](https://github.com/github/awesome-copilot/tree/main/skills/migrate-xml-views-to-jetpack-compose)

## Flow

```mermaid
flowchart TD
  A[Select XML candidate] --> B[Analyze layout and dependencies]
  B --> C[Plan migration increments]
  C --> D[Enable Compose setup and minimal theme]
  D --> E[Implement stateless composables]
  E --> F[Integrate interoperability APIs]
  F --> G[Validate parity with previews and UI tests]
  G --> H[Replace usages and remove XML safely]
```

## Key notes
- Keep migrations incremental to avoid high-risk rewrites.
- Hoist state early to prevent tightly coupled composables.
- Remove XML only after reference checks and regression validation.
