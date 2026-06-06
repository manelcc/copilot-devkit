# US-012 — Crear skills y agente Android Compose (patterns, Nav3, Hilt)

## Contexto de la necesidad
Más allá de la migración, los proyectos Android Compose necesitan skills que guíen la implementación de patrones modernos: state management, Navigation 3, Hilt DI y un agente que orqueste todas estas capacidades. Esta US crea el núcleo de skills Android Compose para proyectos greenfield y maduros.

## 1. Encabezado y trazabilidad
- **ID US**: US-012
- **Título usuario**: Skills de patrones Android Compose y agente experto
- **Descripción usuario**: Como desarrollador Android con Jetpack Compose, quiero skills que me guíen en patrones de Compose, Navigation 3 y un agente experto que las orqueste, para implementar features de calidad sin buscar referencias externas.
- **Épica relacionada**: EP-3 — Stack Android Compose
- **Prioridad sugerida**: Alta (P1)
- **Criterios funcionales trazados**:
  - `skills/android/compose/jetpack-compose-patterns/`
  - `skills/android/compose/android-navigation-compose/` (Navigation 3)
  - `agents/android/compose/android-compose-expert.agent.md`
  - Referencia a `mycardiochef/.github/skills/` para patrones Android

## 2. Cobertura funcional
- **`jetpack-compose-patterns/`** — cubre:
  - Composable stateless vs stateful
  - State hoisting y `remember`/`rememberSaveable`
  - `LazyColumn`, `LazyRow`, grids
  - Side effects: `LaunchedEffect`, `SideEffect`, `DisposableEffect`
  - Custom Layout y Modifier chains
  - Performance: `derivedStateOf`, `key()`, `Stable`/`Immutable`

- **`android-navigation-compose/`** — cubre:
  - Navigation 3: `NavController`, `NavHost`, `composable {}`
  - Passing arguments (safe args pattern en Compose)
  - Deep links
  - Multiple backstacks
  - Bottom navigation + NavHost

- **`android-compose-expert.agent.md`** — comportamiento:
  - Detecta tipo de tarea: nueva feature, migración, refactor, review, testing
  - Invoca skills relevantes según la tarea
  - Handoffs a: `migrate-xml-to-compose`, `jetpack-compose-patterns`, `android-navigation-compose`

## 3. Dependencias y restricciones
- **Dependencias funcionales/técnicas**: US-001, US-003 (templates), US-011 (skill migrate ya existe)
- **Riesgos aplicables**: Navigation 3 es relativamente nueva; documentación puede estar incompleta
- **Pendientes de validación**: ¿Incluir skill de Hilt en esta US o en una futura US-016?
- **Bloqueantes**: Ninguno

## 4. Solución funcional
- Crear skills desde el template `skills/_TEMPLATE/` (US-003)
- Usar `devtools scaffold skill jetpack-compose-patterns android/compose`
- Poblar con patrones reales extraídos de proyectos Android actuales
- El agente usa el template `agents/_TEMPLATE.agent.md` (US-003)

## 5. Checklist de calidad
- **CRITICAL**
  - [ ] 2 skills existen y pasan `validate-skill.sh`
  - [ ] Agente `android-compose-expert.agent.md` existe con handoffs
- **HIGH**
  - [ ] `jetpack-compose-patterns` cubre al menos 6 patrones con ejemplos de código
  - [ ] `android-navigation-compose` cubre Navigation 3 (no Navigation 2)
- **MEDIUM**
  - [ ] Agente tiene lógica de detección de tipo de tarea
- **LOW**
  - [ ] Cada skill tiene diagrama Mermaid en overview.md

## 6. Casos de prueba
- **Funcionales**:
  - `validate-skill.sh skills/android/compose/jetpack-compose-patterns/` → exit 0
  - `validate-skill.sh skills/android/compose/android-navigation-compose/` → exit 0
  - `agents/android/compose/android-compose-expert.agent.md` tiene frontmatter válido
- **Reglas de negocio**: Patrones deben ser para Compose 1.6+ y Navigation 3

## 8. Notas y Definition of Ready
- **Decisiones abiertas**: ¿Skill de Hilt en esta US o en US-016?
- **Supuestos**: Navigation 3 es el estándar; Navigation 2 no se documenta aquí
- **Dependencias previas**: US-001, US-003, US-011 completadas
- **Definition of Ready**:
  - [ ] US-003 completada (templates disponibles)
  - [ ] US-011 completada (skill migrate existe como referencia)
  - [ ] Decisión Hilt en esta US o en US-016 tomada
