# US-011 — Migrar skill migrate-xml-to-compose e instrucciones Android Compose

## Contexto de la necesidad
La migración de XML Views a Jetpack Compose es una de las tareas más frecuentes en proyectos Android legacy. La skill de awesome-copilot para este caso ya existe y está probada. Migrarla al namespace `skills/android/compose/` junto con las instrucciones específicas de Compose cierra el stack Android moderno con cobertura básica.

## 1. Encabezado y trazabilidad
- **ID US**: US-011
- **Título usuario**: Skill migración XML-to-Compose e instrucciones Android Compose
- **Descripción usuario**: Como desarrollador Android migrando de XML a Jetpack Compose, quiero la skill de migración disponible en `skills/android/compose/` y las instrucciones de Compose configuradas, para obtener guía y código de calidad sin buscar en repos externos.
- **Épica relacionada**: EP-3 — Stack Android Compose
- **Prioridad sugerida**: Alta (P0)
- **Criterios funcionales trazados**:
  - `skills/android/compose/migrate-xml-to-compose/` migrada y adaptada
  - `instructions/android-compose.instructions.md` con reglas Kotlin + Compose
  - Referencia: skill `migrate-xml-views-to-jetpack-compose` de awesome-copilot (`~/.claude/skills/`)

## Requerimientos de inicio

| ID | Requerimiento | Estado | Tipo | Evidencia/Nota |
|---|---|---|---|---|
| RQ-001 | Acceso a `~/.claude/skills/migrate-xml-views-to-jetpack-compose/` | Necesario | Funcional | Disponible en entorno local |
| RQ-002 | Conocimiento de stacks Android Compose actuales (Navigation 3, Hilt, Material3) | Necesario | Funcional | Para instrucciones.md |

## 2. Cobertura funcional
- **Skill a migrar**:
  - Fuente: `~/.claude/skills/migrate-xml-views-to-jetpack-compose/`
  - Destino: `skills/android/compose/migrate-xml-to-compose/`
  - Adaptaciones: frontmatter actualizado, paths relativos válidos, referencias a awesome-copilot documentadas en references/

- **`instructions/android-compose.instructions.md`** — reglas:
  - `applyTo: "**/*.kt"` (scoped a proyectos Compose)
  - Composables: funciones sin estado, state hoisting, preview
  - Navigation: Navigation 3 (`NavController`, `NavHost`, `composable {}`)
  - DI: Hilt con `@HiltViewModel`, `hiltViewModel()`
  - Async: Coroutines + Flow con `collectAsStateWithLifecycle()`
  - Theming: Material3, `MaterialTheme`, dark mode
  - Testing: `composeTestRule`, `onNodeWithText`, `performClick`
  - Referencia a `skills/android/compose/` para tareas específicas

## 3. Dependencias y restricciones
- **Dependencias funcionales/técnicas**: US-001 (namespace `android/compose/` existe), US-004 (validador)
- **Riesgos aplicables**: La skill de awesome-copilot puede estar desactualizada respecto a las últimas versiones de Compose; revisar antes de migrar
- **Pendientes de validación**: ¿Navigation 3 o Navigation 2 como estándar en las instrucciones?
- **Bloqueantes**: Acceso a `~/.claude/skills/`

## 4. Solución funcional
- **Proceso de migración**:
  1. Copiar `~/.claude/skills/migrate-xml-views-to-jetpack-compose/` a destino
  2. Actualizar frontmatter `name` a `migrate-xml-to-compose`
  3. Añadir sección en `references/` con link al origen de awesome-copilot
  4. Ejecutar `validate-skill.sh`

- **Instrucciones Android Compose** — estructura del fichero:
  ```
  ---
  applyTo: "**/*.kt"
  ---
  # Android Compose Instructions
  ## Composables
  ## State management
  ## Navigation (Navigation 3)
  ## Dependency Injection (Hilt)
  ## Coroutines + Flow
  ## Theming (Material3)
  ## Testing
  ## Skills de referencia
  ```

## 5. Checklist de calidad
- **CRITICAL**
  - [ ] `skills/android/compose/migrate-xml-to-compose/` existe y pasa validate-skill.sh
  - [ ] `instructions/android-compose.instructions.md` existe con frontmatter `applyTo`
- **HIGH**
  - [ ] Instrucciones cubren: Composables, Navigation 3, Hilt, Flow, Material3
  - [ ] Skill adaptada sin referencias a rutas de ~/.claude/
- **MEDIUM**
  - [ ] Nota de origen de la skill en references/
- **LOW**
  - [ ] Instrucciones tienen menos de 150 líneas

## 6. Casos de prueba
- **Funcionales**:
  - `validate-skill.sh skills/android/compose/migrate-xml-to-compose/` → exit 0
  - `instructions/android-compose.instructions.md` tiene frontmatter YAML con `applyTo`
  - Copilot en proyecto Compose aplica las instrucciones al editar ficheros `.kt`
- **Errores**: Si awesome-copilot skill está desactualizada (Compose < 1.5), actualizar ejemplos

## 8. Notas y Definition of Ready
- **Decisiones abiertas**: ¿Navigation 3 o Navigation 2 como estándar?
- **Supuestos**: Navigation 3 es el estándar para proyectos nuevos; Navigation 2 se documenta en legacy
- **Dependencias previas**: US-001, US-004 completadas
- **Fuentes**:
  - `~/.claude/skills/migrate-xml-views-to-jetpack-compose/`
  - Documentación oficial Jetpack Compose
- **Definition of Ready**:
  - [ ] US-001, US-004 completadas
  - [ ] Acceso a `~/.claude/skills/` confirmado
  - [ ] Decisión Navigation 2 vs 3 tomada
