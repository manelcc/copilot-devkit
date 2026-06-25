---
name: "devkit-development-lifecycle"
description: >
  Executes the complete guided development lifecycle for a User Story: planning with expert consultation,
  implementation, quality gates with correction loop, interactive user decisions, and MR/PR preparation.
triggers:
  - "ejecuta el ciclo completo"
  - "implementa la US con ciclo guiado"
  - "run full development lifecycle"
  - "orquesta el desarrollo de la US"
non_triggers:
  - "solo genera el plan"
  - "solo ejecuta quality gates"
  - "review architecture only"
---

# Development Lifecycle

## Purpose
Execute the complete development lifecycle for a User Story with planning, expert consultation, quality gates, and interactive decisions to ensure quality, traceability, and adaptation to existing code.

## When to use
- User requests complete implementation of a User Story from scratch to merge-ready
- Team wants guided development with mandatory quality gates
- Need planning with expert consultation before implementation
- Implementation must adapt to existing architecture and patterns

## When NOT to use
- Only need planning without implementation
- Only need quality analysis without implementation
- Single file edits or hotfixes
- Release management tasks

## Inputs
- **User Story identifier**: US-XXX
- **Acceptance criteria**: Clear scope and expected behavior
- **Project context**: Current working directory, stack detection
- **Expert agents available**: Architecture, patterns, code quality agents for the detected stack

## Steps

---

### Phase 0: Load Project Config

> **This phase runs before everything else.** It reads `.github/devkit-project.config.md` and configures which phases are active and with which settings.

#### 0.1 Detect config file

Check if `.github/devkit-project.config.md` exists in the project root.

**If the file EXISTS** → read it and extract:
- `Stack(s)` → set `ACTIVE_STACKS`
- `Rama base` → set `BASE_BRANCH`
- `Unit tests` row → set `UNIT_TESTS_ENABLED` (sí/no) and `UNIT_TEST_FRAMEWORK`
- `Cobertura mínima` → set `COVERAGE_THRESHOLD` (e.g. 40%)
- `E2E tests` row → set `E2E_ENABLED` (sí/no) and `E2E_METHOD`
- `Smoke tests` row → set `SMOKE_ENABLED` (sí/no)
- `Clean code` → set `GATE_CLEAN_CODE` (sí/no)
- `Clean architecture` → set `GATE_CLEAN_ARCH` (sí/no)
- `Cobertura` gate row → set `GATE_COVERAGE` (sí/no)
- `Iteraciones máx.` → set `MAX_ITERATIONS`
- `Estilo de commits` → set `COMMIT_STYLE`
- `Formato título MR/PR` → set `MR_TITLE_FORMAT`
- `Revisores requeridos` → set `REQUIRED_REVIEWERS`

**If the file DOES NOT EXIST** → use conservative defaults:
```
UNIT_TESTS_ENABLED=sí
UNIT_TEST_FRAMEWORK=autodetect
COVERAGE_THRESHOLD=40%
E2E_ENABLED=no
SMOKE_ENABLED=no
GATE_CLEAN_CODE=sí
GATE_CLEAN_ARCH=sí
GATE_COVERAGE=sí
MAX_ITERATIONS=3
COMMIT_STYLE=conventional-commits
MR_TITLE_FORMAT=[US-XXX] descripción
REQUIRED_REVIEWERS=2
```

#### 0.2 Show active config summary

Before starting Phase A, show the user a brief config summary:

```
📋 Configuración del ciclo para {{project_name}} (US-{{id}}):
  Stack: {{ACTIVE_STACKS}}
  Tests: Unit={{UNIT_TESTS_ENABLED}} ({{UNIT_TEST_FRAMEWORK}}, ≥{{COVERAGE_THRESHOLD}}) · E2E={{E2E_ENABLED}} · Smoke={{SMOKE_ENABLED}}
  Gates: Clean-code={{GATE_CLEAN_CODE}} · Arquitectura={{GATE_CLEAN_ARCH}} · Cobertura={{GATE_COVERAGE}}
  Iteraciones máx: {{MAX_ITERATIONS}}
  [Sin config — defaults conservadores]   ← solo si no existe el fichero
```

#### 0.3 Phase activation rules

Apply immediately and throughout the rest of the lifecycle:

| Config value | Effect |
|---|---|
| `UNIT_TESTS_ENABLED=no` | Skip Phase C entirely |
| `E2E_ENABLED=no` | Skip Phase F entirely (no pregunta al usuario) |
| `SMOKE_ENABLED=no` | Skip Phase G entirely (no pregunta al usuario) |
| `GATE_CLEAN_CODE=no` | Skip Phase D.1 |
| `GATE_CLEAN_ARCH=no` | Skip Phase D.2 |
| `GATE_COVERAGE=no` | Skip Phase D.3 |
| `MAX_ITERATIONS=N` | Apply as loop limit in Phase E |
| `COVERAGE_THRESHOLD=X%` | Use X in Phase D.3 check |
| `api_docs != no` | Activar Phase I.0 (API docs generation) |
| `api_docs_format` contiene `swagger` | Generar/actualizar OpenAPI spec en Phase I.0 |
| `api_docs_format` contiene `postman` | Exportar coleción Postman en Phase I.0 |

---

### Phase A: Planning and Pre-Analysis

#### A.1 Receive and Confirm User Story Scope
1. Read User Story from `docs/implementation/user-stories/US-XXX-*.md`
2. Extract acceptance criteria
3. If scope is unclear, handoff to `Scrum Master` for clarification

#### A.1.1 Consult Expert Agents
Execute in parallel:
1. **Architecture Expert** (handoff to stack-specific architecture agent):
   - Analyze existing project structure
   - Identify current architectural patterns
   - Detect architectural constraints
   - Recommend approach for the US

2. **Patterns Expert** (handoff to stack-specific patterns agent):
   - Recommend 2-3 design pattern candidates
   - Provide trade-offs for each pattern
   - Suggest best pattern for this US

3. **Code Quality Expert** (handoff to `devkit-clean-code-guardian`):
   - Analyze code in affected area
   - Identify relevant technical debt
   - Flag quality issues to avoid in new code

#### A.1.2 Generate Implementation Plan
1. Synthesize expert recommendations into coherent plan
2. Create detailed, manually executable implementation steps
3. Adapt to existing code and architecture
4. Include test strategy (unit tests, target coverage ≥40%)
5. **Persist**: `docs/plan-implementation/US-XXX-implementation-plan.md` (use template from DevTools-AI)

#### A.1.3 Generate Test Cases and Smoke Tests
1. Define test cases covering all acceptance criteria
2. Include functional tests, edge cases, error scenarios
3. Select 1-2 critical path test cases as **smoke tests**
4. **Persist**:
   - `docs/test-cases/US-XXX-test-cases.md`
   - `docs/smoke-test/US-XXX-smoke-suite.md`

---

### Phase B: Implementation

#### B.0 Ask User: Implementation Mode
Before any code is written, ask the user how they want the implementation handled:

```
Plan de implementación listo.
¿Cómo quieres gestionar la implementación?

[A] Automático   — El agente implementa todo según el plan
[B] Manual       — Tú implementas, el agente supervisa y valida
[C] Híbrido      — Elige qué partes implementa el agente y cuáles tú
```

#### B.1 If Automatic
1. Implement all steps from plan A.1.2 sequentially
2. Follow expert recommendations:
   - Use selected design pattern
   - Respect architectural constraints
   - Apply code quality guidelines
3. Adapt to existing code conventions
4. Keep changes scoped to US requirements only
5. Inform user when each step completes

#### B.2 If Manual
1. Show the implementation plan steps as a checklist
2. Wait for user to confirm when implementation is done:
   ```
   Cuando hayas terminado la implementación, dime "listo" para
   continuar con la generación de tests y quality gates.
   ```
3. On user confirmation, proceed to Phase C

#### B.3 If Hybrid
1. Show the implementation steps from plan A.1.2
2. For each step, ask who implements it:
   ```
   Paso 1: [descripción del paso]
   ¿Quién implementa este paso?
   [Yo (agente)] [Tú (manual)] [Saltar]
   ```
3. Execute agent-assigned steps; wait for user confirmation on manual steps
4. After all steps resolved, proceed to Phase C

---

### Phase C: Test Generation
> Skip this phase entirely if `UNIT_TESTS_ENABLED=no`.

1. Generate unit tests for all implemented code
2. Follow test cases from Phase A.1.3
3. Target code coverage ≥`{{COVERAGE_THRESHOLD}}` (from project config)
4. Use `{{UNIT_TEST_FRAMEWORK}}` framework and project conventions

---

### Phase D: Quality Gates (Mandatory)

> Gates can be individually disabled via project config. See Phase 0 activation rules.

#### D.1 Execute Clean Code Analysis
> Skip if `GATE_CLEAN_CODE=no`.

1. Handoff to `devkit-clean-code-guardian` with scope: changed files only
2. Wait for analysis report
3. **Persist**: `docs/quality/US-XXX-clean-code-report.md`
4. Check threshold: critical issues = 0, score ≥7.0

#### D.2 Execute Clean Architecture Analysis
> Skip if `GATE_CLEAN_ARCH=no`.

1. Handoff to `devkit-clean-architecture-quality` with scope: affected layers
2. Wait for analysis report
3. **Persist**: `docs/quality/US-XXX-architecture-report.md`
4. Check threshold: critical violations = 0

#### D.3 Validate Test Coverage
> Skip if `GATE_COVERAGE=no` or `UNIT_TESTS_ENABLED=no`.

1. Run test suite with coverage tool (project-specific: JaCoCo, pytest-cov, etc.)
2. Extract coverage percentage
3. **Persist**: coverage report in `docs/quality/US-XXX-clean-code-report.md` (append section)
4. Check threshold: coverage ≥`{{COVERAGE_THRESHOLD}}`

#### D.4 Quality Gate Decision
- **If D.1 OR D.2 OR D.3 fails**: proceed to Phase E (Correction Loop)
- **If all pass**: proceed to Phase F (E2E Tests)

---

### Phase E: Correction Loop
1. Collect all quality gate failure reports
2. **Return to Phase A.1.1** with context:
   - Original US scope
   - Implementation attempt and failures
   - Quality reports (clean-code, architecture, coverage)
3. Consult expert agents again with failure context
4. Regenerate implementation plan with corrections
5. **Limit**: Maximum `{{MAX_ITERATIONS}}` iterations (from project config, default 3). After limit, escalate to user with:
   - Summary of attempts
   - Persistent issues
   - Recommendation: manual intervention or scope reduction

---

### Phase F: E2E Tests

> Skip this phase entirely if `E2E_ENABLED=no` (from project config). If `E2E_ENABLED=sí`, execute without asking the user — it is mandatory.
> If config is missing or `E2E_ENABLED` is not set, ask the user (legacy behavior below).

#### F.1 Generate Quality Summary
Create summary with:
- Clean-code score
- Architecture compliance status
- Test coverage percentage
- Overall quality grade

#### F.2 Conditional: Ask User Only If No Config
If project config does NOT disable E2E:
```
Quality gates passed:
✓ Clean-code: 8.5/10
✓ Architecture: Compliant
✓ Coverage: 52%

¿Deseas ejecutar pruebas E2E?
[Sí] [No]
```

#### F.3 If Active: Provide E2E Instructions
Use `E2E_METHOD` from config to generate targeted instructions:
- **docker-compose**: `docker compose up --build`, test endpoints, health checks
- **manual-device**: Deploy to device/emulator, manual test checklist
- **espresso**: Run Espresso test suite with `./gradlew connectedAndroidTest`
- **xcuitest**: Run XCUITest suite from Xcode or `xcodebuild test`
- **playwright**: `npx playwright test`, capture screenshots on failure
- **otro**: Show generic instructions and ask user to describe method

**Persist**: Instructions in `docs/quality/US-XXX-e2e-instructions.md`

#### F.4 Wait for User Confirmation
Ask user to confirm E2E tests passed before continuing

---

### Phase G: Smoke Tests

> Skip this phase entirely if `SMOKE_ENABLED=no` (from project config). If `SMOKE_ENABLED=sí`, execute without asking the user — it is mandatory.
> If config is missing, ask the user (legacy behavior below).

#### G.1 Conditional: Ask User Only If No Config
If project config does NOT disable smoke tests:
```
¿Deseas ejecutar los smoke tests definidos para esta US?
Smoke tests: TC-001, TC-005 (ver docs/smoke-test/US-XXX-smoke-suite.md)
[Sí] [No]
```

#### G.2 If Active: Execute or Provide Instructions
- **Automated smoke tests available**: Run them and report results
- **Manual smoke tests**: Show checklist from `docs/smoke-test/US-XXX-smoke-suite.md`

#### G.3 Wait for User Confirmation
Ask user to confirm smoke tests passed before continuing

---

### Phase H: Atomic Commits (User Decision)

#### H.1 Prepare Atomic Commits
1. Analyze changed files
2. Group by responsibility:
   - Domain models / entities
   - Use cases / business logic
   - Infrastructure / adapters
   - Tests
   - Documentation
3. Generate semantic commit messages following project conventions

Example grouping:
```
Commit 1: feat(domain): add User entity with validation
Commit 2: feat(application): implement CreateUser use case
Commit 3: feat(infrastructure): add UserRepository implementation
Commit 4: test: add unit tests for CreateUser use case
Commit 5: docs: update API documentation
```

#### H.2 Show Proposed Commits to User
Display:
- Commit count
- Each commit message
- Files affected per commit
- Total lines added/deleted

```
Se proponen 5 commits atómicos:

1. feat(domain): add User entity with validation
   Files: User.kt, UserValidator.kt
   +85 lines

2. feat(application): implement CreateUser use case
   Files: CreateUserUseCase.kt
   +42 lines

...

¿Ejecutar estos commits?
[Sí] [No] [Editar mensajes]
```

#### H.3 User Decision
- **If Sí**: Execute commits using `devkit-git-workflow`
- **If No**: Allow manual commit management, inform user to commit manually
- **If Editar mensajes**: Allow user to modify commit messages, then ask again

---

### Phase I: MR/PR Description Generation

#### I.0 API Documentation (Backend stacks only)
> Skip if `api_docs=no` or stack is not backend (backend-kotlin, backend-python, backend-spring).

Generate API documentation artifacts based on `api_docs_format` from project config:

**If format includes `swagger` or `openapi-file-only`:**
- Generate/update `docs/api/openapi.yaml` with all endpoints affected by the US
- For Ktor: use `ktor-openapi-generator` annotations or manual spec update
- For Spring: leverage `springdoc-openapi` and expose `/v3/api-docs`
- For Python/FastAPI: auto-generated from route definitions
- Verify the spec validates correctly (no broken refs, required fields present)

**If format includes `postman`:**
- Generate `docs/api/US-XXX-postman-collection.json` from the OpenAPI spec
- Include: request examples, environment variables (`{{base_url}}`, `{{token}}`), happy-path and error scenarios
- Tool hint: `openapi-to-postman` CLI or manual collection authoring
- **Persist**: `docs/api/US-XXX-postman-collection.json`

**Inform the user:**
```
📄 API Docs generados:
  [· docs/api/openapi.yaml actualizado]
  [· docs/api/US-XXX-postman-collection.json]
```

#### I.1 Generate MR/PR Description
Handoff to `devkit-mr-description-generator` with context:
- User Story identifier and scope
- Implementation summary (from plan)
- Test cases covered
- Quality metrics achieved
- Smoke tests status
- Commits executed

#### I.2 Enhance with Traceability
Add to generated description:
- Links to planning artifacts: `docs/plan-implementation/US-XXX-*`
- Links to test documentation: `docs/test-cases/US-XXX-*`
- Links to quality reports: `docs/quality/US-XXX-*`
- Checklist for reviewer:
  - [ ] Code follows architectural patterns
  - [ ] Unit tests pass and coverage ≥40%
  - [ ] Clean-code score ≥7.0
  - [ ] No critical architecture violations
  - [ ] E2E tests passed (if applicable)
  - [ ] Smoke tests passed (if applicable)

#### I.3 Persist MR/PR Description
- **Persist**: `docs/mr/US-XXX-description.md`

---

### Phase J: Knowledge Capture (Optional, User Decision)

#### J.1 Ask User: Capture as reusable skill?
```
¿Quieres capturar el conocimiento de esta feature como skill reutilizable?
[Sí] [No]
```
If No → skip to J.4.

#### J.2 Ask User: Skill scope

```
¿Qué alcance tiene esta skill?

[A] Proyecto local    — específica de este proyecto, no se sincroniza
[B] Tecnología        — reutilizable en proyectos del mismo stack (se centraliza en el devkit)
[C] Global            — agnóstica de tecnología (se centraliza como skill global en el devkit)
```

#### J.3 Generate skill by scope

---

**Scope A — Proyecto local**

```
¿Qué prefijo quieres usar para la skill? (ej: "banca", "myapp", "payments")
Nombre final de la skill: <prefijo>-<feature-slug>
```

Actions:
1. Generate skill at `.github/skills/<prefijo>-<feature-slug>/SKILL.md` within the consumer project
2. Do NOT create any symlink to the devkit repo — this skill is project-private
3. Update the consumer project's orchestrator or instructions to reference it:
   - If a `<stack>-project-orchestrator.agent.md` exists in `.github/agents/` → add skill to its `skills:` frontmatter list
   - Alternatively, add an entry to `.github/copilot-instructions.md` pointing to the new skill

```
✅ Skill local generada:
   .github/skills/<prefijo>-<feature-slug>/SKILL.md
   Referenciada en: .github/agents/<orchestrator>.agent.md
```

---

**Scope B — Tecnología (stack-specific)**

Stack detected from project config or auto-detect. Map to devkit path:

| Stack | Devkit path |
|---|---|
| backend-kotlin | `skills/backend/kotlin-ktor/` |
| backend-python | `skills/backend/python/` |
| backend-spring | `skills/backend/spring-java/` |
| android-compose | `skills/android/compose/` |
| android-legacy | `skills/android/legacy/` |
| ios-swiftui | `skills/ios/swiftui/` |
| ios-uikit | `skills/ios/uikit/` |
| kmp | `skills/multiplatform/kmp/` |
| cmp | `skills/multiplatform/cmp/` |

Actions:
1. Generate skill at `.github/skills/devkit-<feature-slug>/` inside the consumer project (temporary location)
2. Run `devtools promote` to move it to the devkit and create the symlink automatically:

```bash
devtools promote devkit-<feature-slug> --tech <stack>
# ej: devtools promote devkit-auth-retry --tech python
```

What `devtools promote` does:
- Moves the skill folder to `<DEVKIT_REPO>/skills/<tech-path>/devkit-<feature-slug>/`
- Replaces the local folder with a symlink → devkit
- Creates `~/.copilot/skills/devkit-<feature-slug>/` symlink for VS Code Copilot

```
✅ Skill de tecnología centralizada:
   Devkit: skills/<tech-path>/devkit-<feature-slug>/SKILL.md
   Symlink proyecto: .github/skills/devkit-<feature-slug>/ → devkit
   Symlink global: ~/.copilot/skills/devkit-<feature-slug>/ → devkit
   Disponible para otros proyectos: devtools sync
```

---

**Scope C — Global (stack-agnostic)**

Actions:
1. Generate skill at `.github/skills/devkit-<feature-slug>/` inside the consumer project (temporary location)
2. Run `devtools promote` with `--tech global`:

```bash
devtools promote devkit-<feature-slug> --tech global
```

```
✅ Skill global centralizada:
   Devkit: skills/global/devkit-<feature-slug>/SKILL.md
   Symlink proyecto: .github/skills/devkit-<feature-slug>/ → devkit
   Symlink global: ~/.copilot/skills/devkit-<feature-slug>/ → devkit
   Disponible para todos los proyectos: devtools sync
```

---

All scopes: handoff to `skill-generator` with context:
- User Story identifier and title
- Detected scope and target path
- Stack(s) and design pattern(s) applied
- Key implementation decisions and trade-offs
- Relevant code files changed
- Test strategy used
- Prefix (scope A) or `devkit-` prefix (scopes B and C)

#### J.4 Finalize
Show the final summary:

```
✅ Ciclo completo para US-XXX

  Artefactos generados:
  · docs/plan-implementation/US-XXX-implementation-plan.md
  · docs/test-cases/US-XXX-test-cases.md
  · docs/quality/US-XXX-*.md
  [· docs/api/openapi.yaml + US-XXX-postman-collection.json]
  · docs/mr/US-XXX-description.md
  [· <ruta-skill> (scope: <A|B|C>)]

  Branch lista. Próximo paso:
  git push origin <branch> && abrir MR/PR
```

---

## Expected outputs
- **Planning artifacts**:
  - `docs/plan-implementation/US-XXX-implementation-plan.md`
  - `docs/test-cases/US-XXX-test-cases.md`
  - `docs/smoke-test/US-XXX-smoke-suite.md`
- **Quality artifacts**:
  - `docs/quality/US-XXX-clean-code-report.md`
  - `docs/quality/US-XXX-architecture-report.md`
  - Optional: `docs/quality/US-XXX-e2e-instructions.md`
- **MR/PR artifacts**:
  - `docs/mr/US-XXX-description.md`
- **API documentation** (backend stacks, when `api_docs != no`):
  - `docs/api/openapi.yaml` (swagger/openapi-file-only)
  - `docs/api/US-XXX-postman-collection.json` (postman)
- **Knowledge artifacts** (optional):
  - `skills/<stack>/devkit-<feature-slug>/SKILL.md`
- **Code changes**: Implemented and committed atomically
- **Branch state**: Ready for push and MR/PR creation

## Validation
- All quality gates passed (clean-code, architecture, coverage)
- All acceptance criteria covered by test cases
- User confirmed E2E and smoke tests (or explicitly skipped)
- Atomic commits executed and branch ready for review
- MR/PR description generated with complete traceability

## Examples

### Example 1: Full lifecycle execution
```
User: "Ejecuta el ciclo completo para US-042"
Agent: [Phase A] Leyendo US-042: "Add user authentication"
Agent: [Phase A.1.1] Consultando expertos...
Agent: → Arquitectura: Recomienda Clean Architecture con JWT en capa de infraestructura
Agent: → Patrones: Recomienda Strategy para múltiples métodos de auth
Agent: → Calidad: Detecta deuda técnica en AuthController existente
Agent: [Phase A.1.2] Plan de implementación generado: docs/plan-implementation/US-042-implementation-plan.md
Agent: [Phase A.1.3] Test cases y smoke tests generados
Agent: ¿Procedo con la implementación según el plan?
User: "Sí"
Agent: [Phase B] Implementando...
Agent: [Phase C] Generando tests unitarios...
Agent: [Phase D.1] Análisis clean-code: ✓ Score 8.5, 0 critical issues
Agent: [Phase D.2] Análisis arquitectura: ✓ Compliant, 0 violations
Agent: [Phase D.3] Cobertura de tests: ✓ 52%
Agent: Quality gates pasados. ¿Deseas ejecutar pruebas E2E?
User: "Sí"
Agent: [Phase F] Instrucciones E2E: docker compose up --build && curl http://localhost:8080/auth/login
Agent: Confirma que las pruebas E2E pasaron
User: "Confirmado"
Agent: ¿Deseas ejecutar smoke tests?
User: "No"
Agent: [Phase H] Commits propuestos:
  1. feat(domain): add User and AuthToken entities
  2. feat(application): implement LoginUser use case with JWT
  3. feat(infrastructure): add JWTAuthService implementation
  4. test: add unit tests for LoginUser
Agent: ¿Ejecutar estos commits?
User: "Sí"
Agent: [Phase H] Commits ejecutados
Agent: [Phase I] MR description generada: docs/mr/US-042-description.md
Agent: [Phase J] ¿Quieres capturar el conocimiento de esta feature como skill?
User: "Sí"
Agent: [Phase J] Skill generada: skills/backend-kotlin/devkit-jwt-authentication/SKILL.md
Agent: Ciclo completo. Branch lista para push. ¿Proceder con push y creación de MR?
```

### Example 2: Quality gate failure with correction loop
```
User: "Implementa US-085 con ciclo guiado"
Agent: [Phase A-C] ... implementación completada
Agent: [Phase D.1] Análisis clean-code: ✗ 3 critical issues detected
Agent: [Phase D] Quality gate FAILED. Entrando en bucle de corrección...
Agent: [Phase E] Consultando expertos con reporte de fallos...
Agent: [Phase A.1.2] Plan ajustado con correcciones: docs/plan-implementation/US-085-implementation-plan.md (v2)
Agent: [Phase B-C] Re-implementando con correcciones...
Agent: [Phase D.1] Análisis clean-code: ✓ Score 8.0, 0 critical issues
Agent: [Phase D.2-D.3] ✓ Arquitectura compliant, ✓ Coverage 45%
Agent: Quality gates pasados (intento 2/3). Continuando...
```

## Notes
- The skill coordinates multiple handoffs to expert agents
- User decisions are mandatory at Phases F, G, H
- Quality gates are non-negotiable (Phase D)
- Maximum 3 correction loop iterations before escalation
- All artifacts are persisted in `docs/` for traceability and audit
- Phase J knowledge capture is always optional — never forced
