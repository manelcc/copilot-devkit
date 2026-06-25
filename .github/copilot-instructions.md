# GitHub Copilot — DevTools-AI

Eres el asistente de desarrollo del repositorio **copilot-devkit**: la fuente única de verdad para
agentes, skills, prompts e instrucciones reutilizables en proyectos multi-stack de la organización.

---

## Propósito del repositorio

Este repositorio centraliza artefactos de automatización IA reutilizables en 9 stacks:
Android Compose, Android Legacy, iOS SwiftUI, iOS UIKit, KMP, CMP, Backend Kotlin, Backend Python y Backend Spring.
Los proyectos consumidores los importan via CLI (`devtools sync`) sin copiar ni mantener duplicados.

---

## Cómo activar skills

1. Abre el fichero `skills/<namespace>/<skill-name>/SKILL.md`.
2. El agente o usuario invoca la skill por su nombre o por una frase del bloque `triggers`.
3. La skill define sus propios pasos, entradas y salidas esperadas.

**Template de referencia**: `skills/_TEMPLATE/SKILL.md`

---

## Cómo activar agentes

1. Abre el fichero `agents/<namespace>/<agent-name>.agent.md` o usa el agente desde `.github/agents/`.
2. Los agentes orquestan skills y pueden hacer handoff a otros agentes vía `handoffs` en frontmatter.

**Template de referencia**: `agents/_TEMPLATE.agent.md`

---

## Documentos clave

| Documento | Propósito |
|---|---|
| [`docs/implementation/constitution.md`](../docs/implementation/constitution.md) | Decisiones de diseño, stacks y namespaces |
| [`docs/implementation/epics.md`](../docs/implementation/epics.md) | Épicas y roadmap del producto |
| [`docs/implementation/user-stories/backlog-index.md`](../docs/implementation/user-stories/backlog-index.md) | Backlog completo con estado de US |
| [`docs/implementation/sync-strategy.md`](../docs/implementation/sync-strategy.md) | Estrategia de sync entre repo y consumidores |

---

## Convenciones del repositorio

- **Simetría 1:1**: todo namespace en `agents/` debe existir en `skills/` y `prompts/`.
- **Validación automática**: cada `skills/**/*.md` modificado pasa `scripts/devkit-validate-skill.sh` en pre-commit.
- **Placeholders**: los templates usan `[UpperCase]` para campos que el contributor debe rellenar.
- **Naming**: los artefactos de este devkit llevan prefijo `devkit-` para distinguirlos de los project-specific.
- **Commits semánticos**: `feat`, `fix`, `docs`, `chore` + referencia de US (`feat(US-001): ...`).
