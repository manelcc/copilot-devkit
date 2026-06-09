# Plantilla canónica — Descripción de Merge Request

> Este fichero es la plantilla de referencia que usa la skill `mr-description-generator`.
> Los tokens `{{VARIABLE}}` son sustituidos por la skill en tiempo de ejecución.

---

```markdown
## 📋 US {{US_ID}} — {{US_TITLE}}

**Rama:** `{{BRANCH}}` → `develop`
**Fecha:** {{DATE}}
**Doc de implementación:** `doc/implementation/{{US_DOC_FILENAME}}`

---

## 🎯 Objetivo

{{US_OBJECTIVE}}

---

## 📦 Cambios incluidos

{{#if COMMITS_FEAT}}
### ✨ Nuevas funcionalidades
{{COMMITS_FEAT}}
{{/if}}

{{#if COMMITS_FIX}}
### 🐛 Correcciones
{{COMMITS_FIX}}
{{/if}}

{{#if COMMITS_TEST}}
### 🧪 Tests
{{COMMITS_TEST}}
{{/if}}

{{#if COMMITS_REFACTOR}}
### ♻️ Refactors
{{COMMITS_REFACTOR}}
{{/if}}

{{#if COMMITS_OTHER}}
### 🔧 Otros (docs / ci / chore)
{{COMMITS_OTHER}}
{{/if}}

---

## ✅ Criterios de aceptación

{{ACCEPTANCE_CRITERIA}}

---

## 🧪 Cómo probar en local

### Precondiciones
{{HOW_TO_TEST_PRECONDITIONS}}

### Pasos
{{HOW_TO_TEST_STEPS}}

### Resultado esperado
{{HOW_TO_TEST_EXPECTED}}

---

## 🏗️ Impacto técnico

| Área | Descripción |
|---|---|
| Capas modificadas | {{LAYERS_MODIFIED}} |
| Tests añadidos | {{TESTS_ADDED}} |
| Migraciones DB | {{DB_MIGRATIONS}} |
| Variables de entorno nuevas | {{NEW_ENV_VARS}} |

---

## 📎 Notas para el revisor

{{REVIEWER_NOTES}}

---

## 🔗 Referencias

- Doc de la US: `doc/implementation/{{US_DOC_FILENAME}}`
- MR doc local: `doc/mr/{{BRANCH_SLUG}}-mr.md`
```

---

## Notas de uso de la plantilla

### Tokens obligatorios

| Token | Descripción |
|---|---|
| `{{US_ID}}` | Número de US, ej. `1.1` |
| `{{US_TITLE}}` | Título extraído del `# ` del doc de la US |
| `{{BRANCH}}` | Nombre completo de la rama |
| `{{BRANCH_SLUG}}` | Solo el slug sin prefijo, ej. `MCP-1.1-health-check` |
| `{{DATE}}` | Fecha ISO-8601, ej. `2026-06-03` |
| `{{US_DOC_FILENAME}}` | Nombre del fichero MD de la US |
| `{{US_OBJECTIVE}}` | Párrafo de `## Objetivo funcional` del doc de la US |
| `{{ACCEPTANCE_CRITERIA}}` | Tabla de `## Criterios de aceptación` del doc de la US |

### Tokens de commits (al menos uno debe estar presente)

| Token | Commits de tipo |
|---|---|
| `{{COMMITS_FEAT}}` | `feat:` |
| `{{COMMITS_FIX}}` | `fix:` |
| `{{COMMITS_TEST}}` | `test:` |
| `{{COMMITS_REFACTOR}}` | `refactor:` |
| `{{COMMITS_OTHER}}` | `docs:`, `ci:`, `chore:` |

Formato de cada línea de commit:
```
- `<hash-corto>` <mensaje completo del commit>
```

### Tokens del bloque "Cómo probar en local" (OBLIGATORIOS — guardrail del orquestador)

| Token | Descripción |
|---|---|
| `{{HOW_TO_TEST_PRECONDITIONS}}` | Lista de requisitos previos (software, puertos, datos) |
| `{{HOW_TO_TEST_STEPS}}` | Pasos numerados para ejecutar en local |
| `{{HOW_TO_TEST_EXPECTED}}` | Resultado esperado observable (HTTP status, output, etc.) |

### Tokens de impacto técnico

| Token | Valor si no aplica |
|---|---|
| `{{LAYERS_MODIFIED}}` | `domain`, `application`, `infrastructure`, `entrypoint` |
| `{{TESTS_ADDED}}` | Número y nombres de clases de test |
| `{{DB_MIGRATIONS}}` | `ninguna` si no hay migraciones Flyway |
| `{{NEW_ENV_VARS}}` | `ninguna` si no hay variables nuevas |

### `{{REVIEWER_NOTES}}`

Incluir siempre al menos uno de:
- Decisiones de diseño no evidentes
- Trade-offs asumidos
- Deuda técnica conocida
- `Sin notas adicionales.` si no hay nada relevante
