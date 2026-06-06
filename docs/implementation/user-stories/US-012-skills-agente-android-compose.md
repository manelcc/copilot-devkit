# US-012 — Implementar features Android Compose con patrones modernos

**Como** desarrollador Android con Jetpack Compose,  
**quiero** skills que me guíen en patrones de Compose, Navigation 3 y un agente experto que las orqueste,  
**para** implementar features de calidad sin buscar referencias externas cada vez.

---

## Criterios de Aceptación

1. La skill `skills/android/compose/jetpack-compose-patterns/` existe con secciones: state hoisting, `remember`/`rememberSaveable`, `LazyColumn`, side effects (`LaunchedEffect`, `DisposableEffect`), custom Layout, performance (`derivedStateOf`, `Stable`, `Immutable`).
2. La skill `skills/android/compose/android-navigation-compose/` cubre Navigation 3: `NavController`, `NavHost`, `composable {}`, passing arguments, deep links, multiple backstacks.
3. El agente `agents/android/compose/android-compose-expert.agent.md` detecta tipo de tarea (nueva feature, migración, refactor, review, testing) e invoca skills relevantes.
4. Los handoffs del agente referencian: `migrate-xml-to-compose`, `jetpack-compose-patterns`, `android-navigation-compose`.
5. Cada skill pasa validación: `./scripts/validate-skill.sh skills/android/compose/<skill-name>/` devuelve exit code 0.
6. Cada skill tiene `references/overview.md` con diagrama Mermaid del workflow.
7. Las skills incluyen al menos un ejemplo realista de código (no solo placeholders).
8. Ejecutar `devtools scaffold skill jetpack-compose-patterns android/compose` crea la estructura correcta desde template.

---

## Notas Técnicas

**Skills a crear desde cero** (no migración):
- `jetpack-compose-patterns`
- `android-navigation-compose`

**Agente creado desde template**: `agents/_TEMPLATE.agent.md`

**Fuente de patrones**: Proyectos Android modernos, documentación oficial de Jetpack Compose.

**Decisiones abiertas**: ¿Incluir skill de Hilt en esta US o en US futura?

**Supuestos**: Navigation 3 es suficientemente estable para skill producción.

---

## Validación INVEST

| Criterio | ✅ / ⚠️ | Observación |
|---|---|---|
| **Independiente** | ✅ | Depende de US-001, US-003, US-011 (migrate ya existe) |
| **Negociable** | ✅ | Contenido de skills ajustable |
| **Valiosa** | ✅ | Skills core para cualquier proyecto Android Compose greenfield |
| **Estimable** | ✅ | Creación de 2 skills + 1 agente: 8-12 horas |
| **Small** | ✅ | 8 CA, cubre 2 skills + agente orquestador |
| **Testeable** | ✅ | Todos los CA verificables con validador |

---

## Épica Relacionada

EP-3 — Stack Android Compose

---

## Prioridad

**P1** (Alta) — Completa el namespace Android Compose con skills core.

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
