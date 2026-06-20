# copilot-devkit

Repositorio base para construir y gobernar un devkit de GitHub Copilot con:

- agentes especializados por stack
- skills reutilizables por dominio
- prompts e instrucciones por contexto
- herramientas CLI para scaffold, validacion y sincronizacion

Este repositorio sigue el enfoque de trabajo definido actualmente en el canal:

- https://vscode.dev/github/manelcc/copilot-devkit/blob/develop

## Objetivo actual

En esta fase estamos consolidando la topologia inicial del proyecto para que cualquier contributor pueda:

- ubicar rapidamente artefactos por stack
- mantener simetria entre agents, skills y prompts
- escalar el catalogo sin romper convenciones
- automatizar validaciones y bootstrap local con cli-tools y scripts

## Estructura objetivo (Sprint 0)

```text
.
├── .github/
│   ├── copilot-instructions.md
│   └── agents/
│       ├── project-orchestrator.agent.md
│       └── devkit-feature-lifecycle.agent.md
├── agents/
├── skills/
├── prompts/
├── instructions/
├── cli-tools/
├── docs/
├── scripts/
└── README.md
```

## Convenciones clave

1. Simetria 1:1 entre namespaces de agents, skills y prompts.
2. Jerarquia por stack: global, android, ios, multiplatform, backend.
3. Artefactos por defecto con stubs y .gitkeep para versionar hojas vacias.
4. Evolucion incremental del contenido via user stories en docs/implementation/user-stories.

## Estado

- Estructura base de directorios inicial creada.
- Stubs iniciales de instrucciones por stack creados.
- Orquestadores globales en .github/agents definidos como placeholders.

## Siguientes hitos

- completar contenido funcional de agentes, skills, prompts e instrucciones
- implementar comandos CLI de scaffold, validate, sync
- reforzar validaciones de simetria y calidad en scripts de soporte
