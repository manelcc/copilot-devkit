---
name: "<agent-name>"
description: >
  Una línea: qué hace este agente, cuándo se invoca y qué produce.
  Máximo 2 líneas.
model: Claude Sonnet 4.6 (copilot)
tools:
  - search
  - codebase
  - usages
  - problems
  - edit/editFiles
  - runCommands
---

# <Agent Name>

## Mission

Descripción clara de la misión de este agente en 3-5 frases.
Qué problema resuelve, qué coordina y qué produce.

---

## Trigger conditions

- El usuario pide X.
- El usuario menciona Y.
- El contexto incluye Z.

## Non-trigger conditions

- Tareas que NO debe manejar este agente (y a quién delegar).
- Otro caso excluido.

---

## Skills consumidas

| Skill | Cuándo la usa |
|---|---|
| `skill-name` | Descripción de en qué momento del workflow la usa |
| `skill-name` | Descripción |

## Agentes con los que colabora

| Agente | Relación |
|---|---|
| `agent-name` | Delega X a este agente cuando Y |
| `agent-name` | Recibe resultado de Z |

---

## Workflow

### Paso 1: Nombre

Descripción del paso. Qué hace, qué herramienta usa, qué decide.

```bash
# Comando de ejemplo si aplica
```

### Paso 2: Nombre

Descripción.

> **⚠️ GUARDRAIL:** Descripción de una regla de seguridad o restricción importante.

### Paso N: Nombre

Descripción.

---

## Execution rules

1. Regla de comportamiento 1.
2. Regla de comportamiento 2.
3. Nunca hacer X sin consultar al usuario.
4. Si detecta Y → hacer Z y preguntar antes de continuar.

---

## Output format

- Executive summary
- Lista de hallazgos / acciones tomadas
- Próximos pasos recomendados
- Preguntas pendientes de decisión del usuario

---

## Guardrails

- No editar código sin confirmación del usuario en casos de riesgo.
- No mezclar cambios de features distintas en el mismo commit.
- No hardcodear secretos o tokens en ningún ejemplo de código.
- Si falta contexto para actuar, preguntar antes de asumir.

---

## Stack de referencia

- Kotlin 2.x
- Ktor 3.x
- Exposed 0.5x
- Gradle Kotlin DSL
- JUnit5 + MockK
- PostgreSQL + Flyway
