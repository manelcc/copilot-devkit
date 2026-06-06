# US-009 — Aplicar convenciones de calidad cross-stack

**Como** desarrollador en cualquier stack (Android, iOS, Backend),  
**quiero** las skills de clean-code-guardian, git-workflow, mr-description-generator y feature-lifecycle disponibles en `skills/global/`,  
**para** seguir convenciones de calidad, git y MR en todos los proyectos sin duplicar código.

---

## Requerimientos de inicio

| ID | Requerimiento | Estado | Tipo | Evidencia/Nota |
|---|---|---|---|---|
| RQ-001 | Acceso a `mycardiochef/.github/skills/` | Necesario | Funcional | Path absoluto en constitution.md |
| RQ-002 | feature-lifecycle skill se actualiza (no deprecated) | Necesario | Funcional | La versión deprecated en mycardiochef se reemplaza aquí |

## Criterios de Aceptación

1. Las 4 skills existen en `skills/global/`: `clean-code-guardian`, `git-workflow`, `mr-description-generator`, `feature-lifecycle`.
2. La skill `clean-code-guardian` incluye `scripts/check-clean-code.sh` funcional y catálogos JSON para Kotlin, Java, Swift, Python.
3. El script `check-clean-code.sh` ejecuta sin errores en macOS con bash 3.2+.
4. La skill `git-workflow` no contiene referencias a ramas específicas de mycardiochef (verificable con `grep "feature/migración" skills/global/git-workflow/` sin resultados).
5. La skill `mr-description-generator` usa template genérico: secciones "Qué hace", "Por qué", "Cómo probar", "Checklist" sin campos específicos de proyecto.
6. La skill `feature-lifecycle` no tiene `deprecated: true` en frontmatter y referencia a `git-workflow` como base.
7. Ejecutar `./scripts/validate-skill.sh` sobre las 4 skills devuelve exit code 0.
8. Ninguna skill contiene paths absolutos a mycardiochef (verificable con `grep -r "/mycardiochef/" skills/global/` sin resultados).

---

## Notas Técnicas

**Path fuente**: `/Users/manelcc/.../mycardiochef/middleware/.github/skills/`

**Adaptaciones por skill**:
- `clean-code-guardian`: copiar completo incluyendo scripts y catálogos
- `git-workflow`: generalizar convenciones de rama a `feature/<tipo>/<descripción>`
- `mr-description-generator`: eliminar campos custom de mycardiochef
- `feature-lifecycle`: eliminar estado deprecated, reescribir referenciando `git-workflow`

**Decisiones abiertas**: ¿El template MR es suficientemente genérico para GitLab y GitHub?

**Supuestos**: Convenciones de rama son compatibles con múltiples workflows.

---

## Validación INVEST

| Criterio | ✅ / ⚠️ | Observación |
|---|---|---|
| **Independiente** | ✅ | Depende de US-001 y US-004, pero no bloquea otras migraciones |
| **Negociable** | ✅ | Template MR ajustable por proyecto consumidor |
| **Valiosa** | ✅ | Skills cross-stack disponibles para Android, iOS, Backend |
| **Estimable** | ✅ | Migración de 4 skills + generalización: 6-8 horas |
| **Small** | ✅ | 8 CA, cubre migración completa de 4 skills globales |
| **Testeable** | ✅ | Todos los CA verificables con validador y grep |

---

## Épica Relacionada

EP-8 — Global Cross-Stack

---

## Prioridad

**P0** (Bloqueante) — Skills globales son base para todos los stacks.

## 3. Dependencias y restricciones
- **Dependencias funcionales/técnicas**: US-001 (namespace global existe), US-004 (validador)
- **Riesgos aplicables**: git-workflow tiene referencias a ramas de mycardiochef; deben generalizarse sin perder las convenciones
- **Pendientes de validación**: ¿El template MR de mr-description-generator es suficientemente genérico para todos los stacks?
- **Bloqueantes**: Ninguno

## 4. Solución funcional
- **clean-code-guardian**: Copiar completo incluyendo `scripts/check-clean-code.sh` y todos los catálogos JSON. Verificar que el script funciona en macOS (shebang, dependencias bash)
- **git-workflow**: Generalizar convenciones de rama: `feature/<tipo>/<descripción>` en lugar de `feature/migración/F0.x-...`. Mantener reglas de commit y merge
- **mr-description-generator**: Template MR sin campos de mycardiochef. Mantener secciones: Qué hace, Por qué, Cómo probar, Capturas, Checklist
- **feature-lifecycle**: Eliminar `deprecated: true` del frontmatter; reescribir para que sea el ciclo genérico de feature usando la skill `git-workflow`

## 5. Checklist de calidad
- **CRITICAL**
  - [ ] 4 skills existen en `skills/global/`
  - [ ] Ninguna tiene referencias a "mycardiochef", "mycardio" ni ramas específicas del proyecto fuente
  - [ ] Todas pasan `validate-skill.sh` exit 0
- **HIGH**
  - [ ] clean-code-guardian tiene catálogos para Kotlin, Java, Swift y Python
  - [ ] `scripts/check-clean-code.sh` ejecuta sin errores en macOS
  - [ ] feature-lifecycle no tiene `deprecated: true` en frontmatter
- **MEDIUM**
  - [ ] Template MR es genérico y aplicable a cualquier proyecto
- **LOW**
  - [ ] Nota de migración en frontmatter indica origen

## 6. Casos de prueba
- **Funcionales**:
  - `ls skills/global/` → 4 directorios (clean-code-guardian, git-workflow, mr-description-generator, feature-lifecycle)
  - `validate-skill.sh skills/global/clean-code-guardian/` → exit 0
  - `grep -ri "mycardiochef" skills/global/` → sin resultados
  - `bash skills/global/clean-code-guardian/scripts/check-clean-code.sh --help` → exit 0
- **Errores**: Si check-clean-code.sh usa bashisms no disponibles en macOS → convertir a bash POSIX

## 8. Notas y Definition of Ready
- **Decisiones abiertas**: ¿Template MR necesita variantes por stack (Android/iOS/Backend)?
- **Supuestos**: Las convenciones de git son suficientemente genéricas con `feature/<tipo>/<descripción>`
- **Dependencias previas**: US-001, US-004 completadas
- **Fuentes**:
  - `mycardiochef/.github/skills/clean-code-guardian/`
  - `mycardiochef/.github/skills/git-workflow/`
  - `mycardiochef/.github/skills/mr-description-generator/`
  - `mycardiochef/.github/skills/feature-lifecycle/` (deprecated, a reactivar)
- **Definition of Ready**:
  - [ ] US-001, US-004 completadas
  - [ ] Acceso a mycardiochef confirmado
  - [ ] Decisión sobre variantes de template MR tomada
