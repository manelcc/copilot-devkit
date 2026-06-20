# US-011 — Migrar de XML a Jetpack Compose con guía automatizada

**Como** desarrollador Android migrando de XML Views a Jetpack Compose,  
**quiero** la skill de migración disponible en `skills/android/compose/` y las instrucciones Compose configuradas,  
**para** obtener guía estructurada y código de calidad sin buscar en repositorios externos.

---

## Requerimientos de inicio

| ID | Requerimiento | Estado | Tipo | Evidencia/Nota |
|---|---|---|---|---|
| RQ-001 | Acceso a `~/.claude/skills/migrate-xml-views-to-jetpack-compose/` | Necesario | Funcional | Disponible en entorno local |
| RQ-002 | Conocimiento de stacks Android Compose actuales (Navigation 3, Hilt, Material3) | Necesario | Funcional | Para instrucciones.md |
| RQ-003 | Acceso opcional a `https://github.com/android/skills` para ampliar cobertura | Necesario | Integración | Fuente externa para casos no cubiertos por skill local |

## Criterios de Aceptación

1. La skill existe en `skills/android/compose/migrate-xml-to-compose/` con estructura válida (SKILL.md + references/overview.md).
2. El frontmatter `name` de la skill es `migrate-xml-to-compose` y el campo `description` menciona "XML Views", "Jetpack Compose", "migration".
3. El archivo `references/overview.md` incluye nota de origen: "Migrada desde awesome-copilot: [link]".
4. La skill pasa validación: `./scripts/validate-skill.sh skills/android/compose/migrate-xml-to-compose/` devuelve exit code 0.
5. El archivo `instructions/android-compose.instructions.md` existe con `applyTo: "**/*.kt"`.
6. Las instrucciones incluyen reglas de: (1) Composables sin estado, (2) Navigation 3, (3) Hilt DI, (4) Coroutines + Flow, (5) Material3, (6) Testing con `composeTestRule`.
7. Las instrucciones referencian `skills/android/compose/` para tareas específicas.
8. Las instrucciones tienen menos de 250 líneas (reglas core, no exhaustivas).
9. Las instrucciones documentan cuándo usar `https://github.com/android/skills` como fuente de apoyo para casos avanzados o gaps de la skill local.

---

## Notas Técnicas

**Path fuente**: `~/.claude/skills/migrate-xml-views-to-jetpack-compose/`

**Fuente externa complementaria**: `https://github.com/android/skills`

**Adaptaciones necesarias**:
- Actualizar frontmatter `name` a `migrate-xml-to-compose`
- Añadir sección en `references/` con link al origen
- Verificar paths relativos

**Decisiones abiertas**: ¿Navigation 3 o Navigation 2 como estándar en instrucciones?

**Supuestos**: La skill de awesome-copilot está actualizada con las últimas versiones de Compose.

---

## Validación INVEST

| Criterio | ✅ / ⚠️ | Observación |
|---|---|---|
| **Independiente** | ✅ | Depende de US-001 y US-004, no bloquea otras migraciones |
| **Negociable** | ✅ | Contenido de instrucciones ajustable |
| **Valiosa** | ✅ | Skill de migración es una de las más demandadas en Android |
| **Estimable** | ✅ | Migración + creación de instrucciones: 4-6 horas |
| **Small** | ✅ | 8 CA, cubre migración + instrucciones |
| **Testeable** | ✅ | Todos los CA verificables con validador |

---

## Épica Relacionada

EP-3 — Stack Android Compose

---

## Prioridad

**P0** (Bloqueante) — Primera skill del namespace Android Compose.

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
    - `https://github.com/android/skills`
  - Documentación oficial Jetpack Compose
- **Definition of Ready**:
  - [ ] US-001, US-004 completadas
  - [ ] Acceso a `~/.claude/skills/` confirmado
  - [ ] Decisión Navigation 2 vs 3 tomada
