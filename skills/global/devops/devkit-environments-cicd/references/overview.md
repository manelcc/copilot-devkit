# devkit-environments-cicd — Skill Overview

## Workflow

```mermaid
flowchart TD
    U([User request]) --> A[devkit-devops-orchestrator\ndetects env need]
    A --> B{Project env skill\nexists?}
    B -->|Yes| C[Load project skill\ne.g. middleware-environments]
    B -->|No| D[Load devkit-environments-cicd]
    D --> E[Collect service details\nURLs, variables, branch names]
    E --> F[Generate project skill\n.github/skills/service-environments/]
    F --> C
    C --> G[Apply branch→environment\nmapping to pipeline]
    G --> H[Configure GitLab scoped\nvariables dev/stage/prod]
    H --> I([Done: env strategy\ndocumented and applied])
```

## Description

| Step | Description |
|---|---|
| Detect env need | Orchestrator checks whether any environment-related request is made |
| Check project skill | Search workspace for `<service>-environments` skill |
| Load global skill | Use `devkit-environments-cicd` as the canonical reference |
| Collect details | Service name, URLs per environment, variable taxonomy |
| Generate project skill | Produce a service-scoped environments skill for future use |
| Apply to pipeline | Inject branch rules and variable scopes into CI/CD pipeline |
