---
name: "devkit-project-config-wizard"
description: >
  Conducts an interactive interview to configure the development lifecycle for a consumer project.
  Asks about stack, testing strategy (unit/E2E/smoke), quality gates and thresholds, branch strategy,
  and MR/PR rules. Generates `.github/devkit-project.config.md` that the development lifecycle skill
  reads automatically on every cycle.
triggers:
  - "configura el ciclo de desarrollo de este proyecto"
  - "setup lifecycle for this project"
  - "wizard de configuración de proyecto"
  - "create project config"
  - "no tengo .github/devkit-project.config.md"
non_triggers:
  - "ejecuta el ciclo de una US"
  - "implementa la US"
  - "quality gates only"
---

# Project Config Wizard

## Purpose

Generate the file `.github/devkit-project.config.md` through a structured interview. This config file is the single source of truth for how the development lifecycle (phases, quality gates, testing, MR/PR) behaves in this project. Without it, the lifecycle skill falls back to conservative defaults.

---

## When to use

- First time setting up the devkit in a project
- When the orchestrator detects `.github/devkit-project.config.md` is missing
- When the user wants to change the lifecycle config (re-run the wizard)

---

## When NOT to use

- To implement a User Story (use `devkit-development-lifecycle` instead)
- When `.github/devkit-project.config.md` already exists and no changes are needed
- For isolated code reviews, lint fixes, or single-file operations

---

## Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| Project name | Yes | — | Short identifier for the project |
| Stack(s) | Yes | — | One or more: `android-compose`, `android-legacy`, `ios-swiftui`, `ios-uikit`, `backend-kotlin`, `backend-python`, `backend-spring`, `kmp`, `cmp` |
| Base branch | No | `develop` | Branch that features are cut from |
| Branch prefix | No | `feature/` | Prefix used for feature branches |
| Unit test framework | No | JUnit5/MockK (kotlin), pytest (python), XCTest (ios), JUnit5 (spring) | Testing framework |
| Coverage threshold | No | `40` | Minimum line coverage % |

---

## Steps

Conduct the interview in **4 blocks**. Ask all questions in a block together (not one by one) to minimize round-trips. Provide defaults in brackets — if the user says "default" or just presses Enter, use them.

---

### Block 1 — Project Identity

```
Bloque 1 / 4 — Identificación del proyecto

1. ¿Cómo se llama este proyecto?
2. ¿Qué stack(s) usa?
   Opciones: android-compose | android-legacy | ios-swiftui | ios-uikit |
             backend-kotlin | backend-python | backend-spring | kmp | cmp
   (Puedes indicar varios separados por coma)
3. ¿Cuál es la rama base para features? [develop]
4. ¿Qué prefijo de rama usáis? [feature/]
5. ¿El proyecto expone APIs REST que requieren documentación? [no]
   — Si sí: ¿qué formato(s)?
     swagger+postman | swagger-only | postman-only | openapi-file-only
   — Nota: solo aplica a stacks backend (backend-kotlin, backend-python, backend-spring)
```

---

### Block 2 — Testing Strategy

```
Bloque 2 / 4 — Estrategia de testing

5. ¿El proyecto tiene tests unitarios? [sí]
   — Si sí: ¿qué framework?
     Android: JUnit5+MockK | JUnit4+Mockito
     iOS: XCTest
     Backend Kotlin: JUnit5+MockK+Kotest
     Backend Python: pytest
     Backend Spring: JUnit5+Mockito
     [autodetectar según stack]

6. ¿Cuál es el umbral mínimo de cobertura? [40%]

7. ¿El proyecto tiene tests E2E? [no]
   — Si sí: ¿cómo se ejecutan?
     docker-compose | manual-device | espresso | xcuitest | playwright | otro

8. ¿El proyecto tiene smoke tests? [no]
   — Si sí: ¿se ejecutan automáticamente o manualmente? [manual]
```

---

### Block 3 — Quality Gates

```
Bloque 3 / 4 — Quality gates

9.  ¿Ejecutar análisis de clean-code en cada ciclo? [sí]
10. ¿Ejecutar análisis de clean-architecture en cada ciclo? [sí]
11. ¿Aplicar gate de cobertura (fallar si cobertura < umbral)? [sí]
12. ¿Cuántas iteraciones máximas de corrección antes de escalar al usuario? [3]
```

---

### Block 4 — Git & MR/PR

```
Bloque 4 / 4 — Git y MR/PR

13. ¿Estilo de commits? [conventional-commits]
    Opciones: conventional-commits | libre
14. ¿Formato del título de MR/PR? [[US-XXX] descripción]
15. ¿Número de revisores requeridos? [2]
16. ¿Existe template de MR/PR en el repo? [no]
    — Si sí: ¿ruta? [.github/PULL_REQUEST_TEMPLATE.md]
```

---

## Config File Generation

After completing the interview, generate `.github/devkit-project.config.md` with the following structure. Include all values — never leave a field empty; use the default if the user didn't specify.

```markdown
---
generated_by: devkit-project-config-wizard
date: {{TODAY}}
---

# DevKit Project Config

> Generado por el wizard de configuración. Modifica este fichero para ajustar el
> comportamiento del ciclo de desarrollo. Ejecuta de nuevo el wizard con:
> `@devkit-development-lifecycle-orchestrator configura este proyecto`

## Identificación

| Campo | Valor |
|---|---|
| Proyecto | {{project_name}} |
| Stack(s) | {{stacks}} |
| Rama base | {{base_branch}} |
| Prefijo de rama | {{branch_prefix}} |

## Testing

| Fase | Activa | Detalles |
|---|---|---|
| Unit tests | {{unit_tests}} | Framework: {{unit_test_framework}} · Cobertura mínima: {{coverage_threshold}} |
| E2E tests | {{e2e_tests}} | Método: {{e2e_method}} |
| Smoke tests | {{smoke_tests}} | Ejecución: {{smoke_execution}} |

## API Documentation

| Campo | Valor |
|---|---|
| API docs | {{api_docs}} |
| Formato(s) | {{api_docs_format}} |

## Quality Gates

| Gate | Activo | Configuración |
|---|---|---|
| Clean code | {{gate_clean_code}} | — |
| Clean architecture | {{gate_clean_arch}} | — |
| Cobertura | {{gate_coverage}} | Umbral: {{coverage_threshold}} |
| Iteraciones máx. de corrección | — | {{max_iterations}} |

## Git & MR/PR

| Campo | Valor |
|---|---|
| Estilo de commits | {{commit_style}} |
| Formato título MR/PR | {{mr_title_format}} |
| Revisores requeridos | {{required_reviewers}} |
| Template MR/PR | {{mr_template_path}} |
```

---

## Post-generation (Steps — final step)

After creating the file:

1. Confirm to the user:
   ```
   ✅ Configuración guardada en `.github/devkit-project.config.md`

   Resumen del ciclo para {{project_name}}:
   - Stack: {{stacks}}
   - Unit tests: {{unit_tests}} ({{unit_test_framework}}, cobertura ≥{{coverage_threshold}})
   - E2E tests: {{e2e_tests}}
   - Smoke tests: {{smoke_tests}}
   - Quality gates: clean-code={{gate_clean_code}}, clean-arch={{gate_clean_arch}}

   Para empezar un ciclo usa:
   @devkit-development-lifecycle-orchestrator ejecuta el ciclo de la US-XXX
   ```

2. If `.github/` does not exist, create it with `mkdir -p .github`.
3. Do NOT overwrite an existing config without confirmation:
   ```
   Ya existe `.github/devkit-project.config.md`. ¿Sobreescribir? [s/N]
   ```

---

## Expected outputs

- `.github/devkit-project.config.md` — project lifecycle configuration file (YAML frontmatter + Markdown tables)
- Confirmation summary shown to the user with effective settings

---

## Validation

- Config file created/updated at `.github/devkit-project.config.md`
- All required fields present: `project_name`, `stacks`, `base_branch`, `branch_prefix`
- Coverage threshold is a number between 0 and 100
- Stack values are from the allowed list
- If `api_docs != no`, stack must include a backend variant

---

## Examples

**Trigger: first setup**
```
Usuario: configura este proyecto para el ciclo devkit
Agente: [lanza el wizard en 4 bloques, genera .github/devkit-project.config.md]
```

**Trigger: re-run wizard to change config**
```
Usuario: quiero desactivar los E2E tests en este proyecto
Agente: [detecta config existente, confirma sobreescritura, re-lanza wizard con valores actuales como defaults]
```

**Trigger: orchestrator auto-detection**
```
@devkit-development-lifecycle-orchestrator ejecuta el ciclo de la US-042
[Orchestrator: no hay .github/devkit-project.config.md → ofrece wizard antes de continuar]
```
