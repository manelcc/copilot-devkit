# US-009 — Migrar skills globales (clean-code, git, MR)

## Contexto de la necesidad
Las skills de quality, git y MR de mycardiochef son útiles en cualquier stack (Android, iOS, Backend). Migrarlas al namespace `skills/global/` las hace disponibles cross-stack sin duplicación y sin dependencia del proyecto de origen.

## 1. Encabezado y trazabilidad
- **ID US**: US-009
- **Título usuario**: Migrar skills globales de calidad, git y MR description
- **Descripción usuario**: Como desarrollador en cualquier stack, quiero las skills de clean-code-guardian, git-workflow y mr-description-generator disponibles en `skills/global/`, para seguir convenciones de calidad y git en todos los proyectos.
- **Épica relacionada**: EP-8 — Global Cross-Stack
- **Prioridad sugerida**: Alta (P0)
- **Criterios funcionales trazados**:
  - 3 skills migradas a `skills/global/` con catálogos multi-lenguaje
  - clean-code-guardian incluye catálogos para Kotlin, Java, Swift, Python
  - git-workflow y mr-description-generator con templates genéricos (sin referencias a mycardiochef)
  - Fuente: `mycardiochef/.github/skills/clean-code-guardian/`, `git-workflow/`, `mr-description-generator/`

## Requerimientos de inicio

| ID | Requerimiento | Estado | Tipo | Evidencia/Nota |
|---|---|---|---|---|
| RQ-001 | Acceso a `mycardiochef/.github/skills/` | Necesario | Funcional | Path absoluto en constitution.md |
| RQ-002 | feature-lifecycle skill se actualiza (no deprecated) | Necesario | Funcional | La versión deprecated en mycardiochef se reemplaza aquí |

## 2. Cobertura funcional
- **Skills a migrar** (fuente → destino):
  1. `MC:skills/clean-code-guardian/` → `skills/global/clean-code-guardian/`
     - Incluye: SKILL.md, references/, scripts/check-clean-code.sh, catálogos Kotlin/Java/Swift/Python
  2. `MC:skills/git-workflow/` → `skills/global/git-workflow/`
     - Eliminar referencias a ramas específicas de mycardiochef (feature/migración/*)
     - Generalizar para cualquier proyecto
  3. `MC:skills/mr-description-generator/` → `skills/global/mr-description-generator/`
     - Template MR genérico (sin campos específicos de mycardiochef)
  4. `MC:skills/feature-lifecycle/` → `skills/global/feature-lifecycle/`
     - Reemplaza la versión deprecated; usa git-workflow como base
     - Eliminar estados DEPRECATED del frontmatter

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
