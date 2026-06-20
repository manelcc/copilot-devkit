# US-014 — Compartir lógica de negocio multiplataforma con KMP

**Merge Request:** `feature/US-014-skills-kmp-agente-multiplatform` → `develop`

**Status:** 🚧 IN PROGRESS (Commit 1/2)

**Autor:** Copilot Dev Agent  
**Fecha:** 2026-06-20

---

## Resumen Ejecutivo

Se han creado **skill, agente e instructions** para guiar el desarrollo de módulos Kotlin Multiplatform (KMP) compartidos. El repositorio ahora tiene capacidad de orientar a desarrolladores en:

- Estructura y patrones de módulos `commonMain`, `androidMain`, `iosMain`
- Aplicación correcta de `expect/actual` declarations
- Reglas de Clean Architecture aplicadas a multiplatform
- Interoperabilidad iOS (@ObjCName, @Throws)
- Testing standards (JUnit5 + MockK en commonTest)

---

## Criterios de Aceptación (CA) — Estado

| CA | Descripción | Estado |
|----|----|--------|
| 1 | Skill `skills/multiplatform/kmp/kmp-shared-module-patterns/` cubre: estructura, expect/actual, Ktor Client, SQLDelight, shared ViewModel, iOS interop | ✅ DONE |
| 2 | Agente `agents/multiplatform/kmp/devkit-kmp-expert.agent.md` detecta scope y delega a android-compose-expert, ios-swiftui-expert | ✅ DONE |
| 3 | Handoffs del agente referencian expertos de Android e iOS | ✅ DONE |
| 4 | Archivo `instructions/kmp.instructions.md` existe con `applyTo: "multiplatform/**/*.kt"` | ✅ DONE |
| 5 | Instructions incluyen reglas de expect/actual, naming, restricciones de deps | ✅ DONE |
| 6 | Skill pasa `./scripts/devkit-validate-skill.sh` con exit code 0 | ✅ DONE |
| 7 | Skill tiene `references/overview.md` con diagrama Mermaid de módulo KMP | ✅ DONE |
| 8 | `devtools scaffold skill kmp-shared-module-patterns multiplatform/kmp` crea estructura (future: CLI enhancement) | ⏳ PENDING (out of scope) |

---

## Entregables — Commit 1

### 1. Skill: `kmp-shared-module-patterns`

**Ubicación:** `skills/multiplatform/kmp/kmp-shared-module-patterns/SKILL.md`

**Contenido:**
- 📋 **Purpose**: Guía de patrones para módulos compartidos KMP
- 🎯 **Triggers**: 7 frases de trigger (expect/actual, Ktor, ViewModel, SQLDelight, iOS interop, deps, platform logic)
- 🚫 **Non-triggers**: 4 escenarios excluidos (debugging, migración, UI Compose, decisiones CMP)
- 📥 **Inputs**: Topology, targets, data persistence strategy
- 📊 **Steps**: 7 pasos detallados desde validación de scope hasta roadmap de implementación
- 📤 **Expected outputs**: Guidance + ejemplos código + checklist arquitectónico
- 💡 **Examples**: 3 ejemplos (HTTP client, ViewModel, iOS interop)
- ✅ **Validation**: 4 checks de calidad

**Patterns cubiertos:**
```
✅ Domain tier:          Entities, use cases (sin deps)
✅ Application tier:     SharedViewModel, expect/actual para coroutines
✅ Infrastructure tier:  SQLDelight, Ktor Client, database factories
✅ iOS interop:          @ObjCName, @Throws, nullability conventions
✅ Guardrails:           Circular deps prevention, platform leaks detection
```

**Diagrama de arquitectura en `references/overview.md`:**
- Topología típica: Domain ← App ← Infrastructure ← Platform (5 diagramas Mermaid)
- Guía de placement expect/actual (6 casos de uso)
- Reglas de visibilidad de source sets
- Pattern template expect/actual
- Testing structure (commonTest + platform tests)

### 2. Agent: `devkit-kmp-expert`

**Ubicación:** `agents/multiplatform/kmp/devkit-kmp-expert.agent.md`

**Misión:**
> Proporciona orientación autorizada para desarrollo KMP a nivel de módulo shared, detecta riesgos de arquitectura, aplica patrones expect/actual correctamente y delega a expertos de plataforma.

**Trigger conditions:** 10 preguntas de trigger (expect/actual, CircularDeps, SQLDelight, ViewModel, API exposure, límites arquitectónicos, errores mismatch, serialización, @ObjCName, excepciones)

**Delegaciones (Handoffs):**
| Target | Trigger | Contexto |
|--------|---------|----------|
| `devkit-android-compose-expert` | UI Android o Compose platform-specific | Arquitectura shared + constraints Android |
| `devkit-ios-swiftui-expert` | UI iOS o interop @ObjCName/@Throws | APIs shared + requirements iOS |
| `devkit-kotlin-server-quality` | Code quality audit de shared module | Ruta shared/ + scope (commonMain/androidMain/iosMain) |
| `devkit-clean-architecture-quality` | Architectural review cross-platform | Full project topology (shared/androidApp/iosApp) |

**Execution flow:**
1. Detectar topología de módulos (grep build.gradle.kts)
2. Clasificar request tipo: expect/actual, serialización, DB, ViewModel, iOS interop, arquitectura, circular deps
3. Aplicar patrón desde skill → código + guardrails
4. Validar expect/actual balance, Clean Arch, iOS interop
5. Delegar o cerrar

**Quality gate checklist:** 10 items (arquitectura, deps, iOS interop, testing, estilo)

### 3. Instructions: `kmp.instructions.md`

**Ubicación:** `instructions/kmp.instructions.md`

**Scope:** `applyTo: "multiplatform/**/*.kt"` (solo rutas bajo multiplatform/)

**10 Secciones de reglas:**

1. **Source Set Boundaries** (Rule 1.1-1.2)
   - ❌ No Android/Foundation imports en commonMain
   - ✅ Matriz de visibilidad: qué source set importa qué

2. **expect/actual Pattern Discipline** (Rule 2.1-2.3)
   - Balanced declarations (1 expect = 1 actual per platform)
   - Signature matching
   - Placement rules

3. **Architecture Layer Enforcement** (Rule 3.1-3.2)
   - Domain ← App ← Infrastructure ← Platform
   - No circular dependencies

4. **iOS Interop Patterns** (Rule 4.1-4.3)
   - @ObjCName para APIs públicas
   - @Throws para exception mapping
   - Nullability conventions

5. **expect/actual for Platform Concerns** (Rule 5.1-5.4)
   - HTTP Client single instance
   - Database Factory pattern
   - Main thread Dispatcher
   - Logging (opcional)

6. **Testing Standards** (Rule 6.1-6.2)
   - JUnit5 + MockK en commonTest
   - ≥40% coverage (JaCoCo)
   - Platform-specific tests en androidTest/iosTest

7. **Naming Conventions** (Rule 7.1-7.2)
   - camelCase funcs, PascalCase types
   - Context clarity en expect/actual

8. **Documentation Requirements** (Rule 8.1-8.2)
   - KDoc para APIs públicas
   - Architecture diagram para módulos complejos

9. **Anti-Patterns to Avoid** (9 patrones ❌ → soluciones ✅)

10. **Quality Gate Checklist** (10 items pre-merge)

---

## Validación Pre-Merge

### Quality Gates Completados ✅

- ✅ `./scripts/devkit-validate-skill.sh skills/multiplatform/kmp/kmp-shared-module-patterns/`
  ```
  [OK] SKILL.md exists
  [OK] YAML frontmatter found
  [OK] Found sections: Purpose, When to use, Inputs, Steps, Expected outputs, Validation, Examples
  [OK] references/overview.md exists
  [OK] Mermaid diagrams found
  RESULT: All skills passed validation
  ```

### Architectural Review (Self-Check)

- ✅ No circular dependencies dentro de skill/agent/instructions
- ✅ Handoffs bien definidos (Sin ambigüedad sobre cuándo delegar)
- ✅ Scope de instructions claro: `multiplatform/**/*.kt` (no afecta Android ni iOS targets específicos)
- ✅ Patrones consistent con repo global (Clean Architecture, testing, naming)
- ✅ Referencias a skills relacionadas existentes (`devkit-clean-architecture-quality`, `devkit-clean-code-guardian`)

### Coverage

- ✅ expect/actual: 5+ examples
- ✅ iOS interop: @ObjCName, @Throws, nullability covered
- ✅ Database patterns: SQLDelight + Exposed mentioned
- ✅ HTTP: Ktor Client patterns
- ✅ ViewModel: Shared state management
- ✅ Testing: commonTest + platform tests
- ✅ Guardrails: Circular deps, platform leaks, naming

---

## Notas Técnicas

### Decisiones de Diseño

1. **Scope de instructions:** Se definió como `multiplatform/**/*.kt` para NOT interferir con Android e iOS targets específicos. Cada plataforma tiene sus propias instructions.

2. **Agente vs. Skill:** 
   - Skill = Patrones detallados + guardrails + ejemplos código
   - Agent = Orquestación, detección de topology, delegaciones

3. **Handoffs:** Agent delega a:
   - `android-compose-expert` → UI Android
   - `ios-swiftui-expert` → UI iOS
   - `kotlin-server-quality` → Code quality audit
   - `clean-architecture-quality` → Full architecture audit

### Supuestos

- Kotlin Multiplatform 1.9+ con memory model estable
- KMP es para Android + iOS (aunque patrón es genérico)
- Desarrolladores ya conocen basics de Kotlin

### Limitaciones

- ❌ No incluye patrones para CMP (UI Compose Multiplatform); es tarea de US-015
- ❌ CLI enhancement (`devtools scaffold`) no implementado (requiere cambio en CLI)
- ❌ No cubre interop con C/C++ (fuera de scope KMP typical)

---

## Próximos Pasos (Out of Scope — US-015+)

1. **Skill: cmp-ui-patterns** (Compose Multiplatform UI)
   - State management (MVI/MVVM)
   - Type-safe navigation
   - Theming multiplatform

2. **Instructions: cmp.instructions.md**
   - Rules específicas para CMP targets

3. **CLI Enhancement**
   - `devtools scaffold skill kmp-shared-module-patterns multiplatform/kmp`

4. **Integration Tests**
   - KMP project template con pre-configured skill + agent

---

## Commits Atómicos

### Commit 1 ✅ (Actual)
```
feat(kmp): create skill, agent, and instructions for KMP shared module patterns

- Create skill 'kmp-shared-module-patterns' with expect/actual patterns, architecture guidance, and iOS interop
- Create agent 'devkit-kmp-expert' with topology detection and delegations to platform experts
- Create instructions 'kmp.instructions.md' with rules for source set boundaries, Clean Architecture, testing
- Include Mermaid diagrams for KMP architecture, dependency flow, and source set visibility
- Add references/overview.md with complete patterns for HTTP client, database, and ViewModel

Files:
+ agents/multiplatform/kmp/devkit-kmp-expert.agent.md
+ instructions/kmp.instructions.md
+ skills/multiplatform/kmp/kmp-shared-module-patterns/SKILL.md
+ skills/multiplatform/kmp/kmp-shared-module-patterns/references/overview.md
```

### Commit 2 (Pending)
- Update US-014 in docs/implementation/user-stories/ with DoD checklist + completion
- Close US-014 in backlog

---

## Métricas de Calidad

| Métrica | Target | Actual |
|---------|--------|--------|
| Skill sections | 8 (Purpose, Triggers, Inputs, Steps, Outputs, Validation, Examples, + ref overview) | ✅ 8 |
| Agent handoffs | ≥3 | ✅ 4 (Android, iOS, Quality, ArchAudit) |
| Mermaid diagrams | ≥3 | ✅ 8 (Architecture, Deps, Source sets, expect/actual guide, Testing, Ktor, SQLDelight, Guardrails) |
| Code examples | ≥5 | ✅ 15+ (Domain, App, Infra, iOS interop tiers) |
| Guardrails | ≥5 | ✅ 7 (no platform imports, balanced expect/actual, arch violations, iOS interop, circular deps, naming, testing) |
| Instructions rules | ≥10 | ✅ 10 (boundaries, expect/actual, Clean Arch, iOS interop, platform concerns, testing, naming, docs, anti-patterns, quality gate) |

---

## Reviewers Checklist

- [ ] Skill contiene patrones viables y actualizado para Kotlin 2.0+
- [ ] Agente no tiene ambigüedades en handoffs
- [ ] Instructions scope es claro (`multiplatform/**/*.kt`)
- [ ] Mermaid diagrams renderean correctamente
- [ ] No hay referencias rotas a skills/agents
- [ ] Ejemplos código compilan mentalmente
- [ ] Quality gate checklist es verificable en CI/CD
- [ ] Naming consistent con repo (devkit- prefix, .agent.md, .instructions.md)

---

## Definition of Done (para US-014 completa)

**Commit 1 (Actual):**
- ✅ Skill + Agent + Instructions creados
- ✅ Validación pre-commit pasada
- ✅ MR description completa

**Commit 2 (Pending):**
- ⏳ US-014 marked as COMPLETED en docs/implementation/user-stories/
- ⏳ DoD checklist verificado (todos CA = ✅)
- ⏳ MR mergeada a develop

---

## Referencias

- Skill file: [kmp-shared-module-patterns/SKILL.md](../../skills/multiplatform/kmp/kmp-shared-module-patterns/SKILL.md)
- Agent file: [devkit-kmp-expert.agent.md](../../agents/multiplatform/kmp/devkit-kmp-expert.agent.md)
- Instructions: [kmp.instructions.md](../../instructions/kmp.instructions.md)
- Mermaid docs: [overview.md](../../skills/multiplatform/kmp/kmp-shared-module-patterns/references/overview.md)
- US story: [US-014](../user-stories/US-014-skills-kmp-agente-multiplatform.md)

---

**MR Status:** Ready for Review ✅  
**Branch:** `feature/US-014-skills-kmp-agente-multiplatform`  
**Target:** `develop`  
**Last Updated:** 2026-06-20
