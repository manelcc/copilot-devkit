# Branching Flow — MCP Server ShareResources

## Flujo de ramas

```mermaid
gitGraph
   commit id: "initial"
   branch develop
   checkout develop
   commit id: "develop base"

   branch feature/MCP-42-slug
   checkout feature/MCP-42-slug
   commit id: "feat(MCP-42): step 1"
   commit id: "test(MCP-42): unit tests"
   checkout develop
   merge feature/MCP-42-slug id: "merge(MCP-42)" type: REVERSE

   branch fix/MCP-17-slug
   checkout fix/MCP-17-slug
   commit id: "fix(MCP-17): correction"
   checkout develop
   merge fix/MCP-17-slug id: "merge(MCP-17)" type: REVERSE
```

## Reglas visuales

```
develop
  │
  ├── feature/MCP-<ticket>-<slug>
  │     ├── feat(MCP-XX): commit atómico 1
  │     ├── feat(MCP-XX): commit atómico 2
  │     └── test(MCP-XX): unit tests
  │           │
  │           └── merge --no-ff → develop
  │
  ├── fix/MCP-<ticket>-<slug>
  │     └── fix(MCP-XX): corrección
  │           │
  │           └── merge --no-ff → develop
  │
  └── bugfix/MCP-<ticket>-<slug>
        └── fix(MCP-XX): bugfix
              │
              └── merge --no-ff → develop
```

## Ciclo completo

```
git checkout develop
git pull origin develop
git checkout -b feature/MCP-42-slug
  │
  ├── [implementar]
  ├── [clean-code-guardian]
  ├── [unit tests]
  ├── [code review]
  ├── git add <ficheros>
  └── git commit -m "feat(MCP-42): ..."
        │
        git checkout develop
        git merge --no-ff feature/MCP-42-slug -m "merge(MCP-42): ..."
        git push origin develop
        git branch -d feature/MCP-42-slug
```
