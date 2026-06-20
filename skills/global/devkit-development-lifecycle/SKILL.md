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
1. Implement according to plan from Phase A.1.2
2. Follow expert recommendations:
   - Use selected design pattern
   - Respect architectural constraints
   - Apply code quality guidelines
3. Adapt to existing code conventions
4. Keep changes scoped to US requirements only

---

### Phase C: Test Generation
1. Generate unit tests for all implemented code
2. Follow test cases from Phase A.1.3
3. Target code coverage ≥40%
4. Use project's testing framework and conventions

---

### Phase D: Quality Gates (Mandatory)

#### D.1 Execute Clean Code Analysis
1. Handoff to `devkit-clean-code-guardian` with scope: changed files only
2. Wait for analysis report
3. **Persist**: `docs/quality/US-XXX-clean-code-report.md`
4. Check threshold: critical issues = 0, score ≥7.0

#### D.2 Execute Clean Architecture Analysis
1. Handoff to `devkit-clean-architecture-quality` with scope: affected layers
2. Wait for analysis report
3. **Persist**: `docs/quality/US-XXX-architecture-report.md`
4. Check threshold: critical violations = 0

#### D.3 Validate Test Coverage
1. Run test suite with coverage tool (project-specific: JaCoCo, pytest-cov, etc.)
2. Extract coverage percentage
3. **Persist**: coverage report in `docs/quality/US-XXX-clean-code-report.md` (append section)
4. Check threshold: coverage ≥40%

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
5. **Limit**: Maximum 3 iterations. After 3 failures, escalate to user with:
   - Summary of attempts
   - Persistent issues
   - Recommendation: manual intervention or scope reduction

---

### Phase F: E2E Tests (Optional, User Decision)

#### F.1 Generate Quality Summary
Create summary with:
- Clean-code score
- Architecture compliance status
- Test coverage percentage
- Overall quality grade

#### F.2 Ask User: Execute E2E Tests?
```
Quality gates passed:
✓ Clean-code: 8.5/10
✓ Architecture: Compliant
✓ Coverage: 52%

¿Deseas ejecutar pruebas E2E?
[Sí] [No]
```

#### F.3 If Yes: Provide E2E Instructions
Detect project type and generate instructions:
- **Docker projects**: `docker compose up --build`, test endpoints, health checks
- **Mobile projects**: Deploy to device/emulator, manual test checklist
- **Web projects**: Start dev server, browser test scenarios

**Persist**: Instructions in `docs/quality/US-XXX-e2e-instructions.md`

#### F.4 Wait for User Confirmation
Ask user to confirm E2E tests passed before continuing

---

### Phase G: Smoke Tests (Optional, User Decision)

#### G.1 Ask User: Execute Smoke Tests?
```
¿Deseas ejecutar los smoke tests definidos para esta US?
Smoke tests: TC-001, TC-005 (ver docs/smoke-test/US-XXX-smoke-suite.md)
[Sí] [No]
```

#### G.2 If Yes: Execute or Provide Instructions
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
