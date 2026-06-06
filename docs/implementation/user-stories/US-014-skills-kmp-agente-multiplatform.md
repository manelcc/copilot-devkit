# US-014 — Compartir lógica de negocio multiplataforma con KMP

**Como** desarrollador trabajando con Kotlin Multiplatform,  
**quiero** skills que me guíen en la estructura del módulo compartido KMP y un agente experto,  
**para** implementar lógica multiplataforma (Android + iOS) con patrones correctos.

---

## Criterios de Aceptación

1. La skill `skills/multiplatform/kmp/kmp-shared-module-patterns/` cubre: estructura `commonMain`/`androidMain`/`iosMain`, `expect`/`actual`, Ktor Client, SQLDelight, `kotlinx.coroutines`, shared ViewModels, interop iOS (`@ObjCName`, `@Throws`).
2. El agente `agents/multiplatform/kmp/kmp-expert.agent.md` detecta si la tarea es en módulo shared, Android o iOS y delega correctamente.
3. Los handoffs del agente referencian: `android-compose-expert`, `ios-swiftui-expert` (para tareas de UI específicas).
4. El archivo `instructions/kmp.instructions.md` existe con `applyTo: "**/*.kt"` (scoped a módulos multiplatform).
5. Las instrucciones incluyen reglas de: (1) `expect`/`actual` patterns, (2) convenciones de naming para APIs públicas multiplataforma, (3) restricciones de dependencies en `commonMain`.
6. La skill pasa validación: `./scripts/validate-skill.sh skills/multiplatform/kmp/kmp-shared-module-patterns/` devuelve exit code 0.
7. La skill tiene `references/overview.md` con diagrama Mermaid del módulo KMP típico.
8. Ejecutar `devtools scaffold skill kmp-shared-module-patterns multiplatform/kmp` crea la estructura correcta.

---

## Notas Técnicas

**Skill creada desde cero** (no migración)

**Fuente de patrones**: Proyectos KMP reales, documentación oficial de Kotlin Multiplatform.

**Decisiones abiertas**: ¿`kmp.instructions.md` aplica solo a `shared/` o a todo el proyecto?

**Supuestos**: Kotlin Multiplatform 1.9+ con nuevo memory model estable.

---

## Validación INVEST

| Criterio | ✅ / ⚠️ | Observación |
|---|---|---|
| **Independiente** | ✅ | Depende de US-001, US-003, no bloquea otras US |
| **Negociable** | ✅ | Contenido de skill ajustable |
| **Valiosa** | ✅ | KMP es stack creciente; skill permite implementar lógica compartida Android+iOS |
| **Estimable** | ✅ | Creación de skill + agente + instrucciones: 8-12 horas |
| **Small** | ✅ | 8 CA, cubre skill + agente + instrucciones |
| **Testeable** | ✅ | Todos los CA verificables con validador |

---

## Épica Relacionada

EP-6 — Multiplatform KMP/CMP

---

## Prioridad

**P1** (Alta) — Habilita stack KMP en el repositorio.

## 3. Dependencias y restricciones
- **Dependencias funcionales/técnicas**: US-001 (namespace `multiplatform/kmp/` existe), US-003 (templates)
- **Riesgos aplicables**: KMP evoluciona rápido; las skills pueden quedar desactualizadas
- **Pendientes de validación**: ¿`kmp.instructions.md` aplica solo a `shared/` o a todo el proyecto?
- **Bloqueantes**: Ninguno (skills creadas desde cero)

## 4. Solución funcional
- Crear skills desde template: `devtools scaffold skill kmp-shared-module-patterns multiplatform/kmp`
- Poblar con patrones reales de proyectos KMP actuales
- Agente creado desde template con handoffs a Android e iOS experts

## 5. Checklist de calidad
- **CRITICAL**
  - [ ] `skills/multiplatform/kmp/kmp-shared-module-patterns/` existe y pasa validate-skill.sh
  - [ ] `agents/multiplatform/kmp/kmp-expert.agent.md` existe
  - [ ] `instructions/kmp.instructions.md` existe
- **HIGH**
  - [ ] Skill cubre expect/actual, Ktor Client, SQLDelight y shared ViewModels
  - [ ] Agente tiene handoffs a android-compose-expert e ios-swiftui-expert
- **MEDIUM**
  - [ ] Instrucciones tienen `applyTo` scoped a módulos KMP
- **LOW**
  - [ ] Skill tiene diagrama Mermaid de arquitectura KMP en overview.md

## 6. Casos de prueba
- **Funcionales**:
  - `validate-skill.sh skills/multiplatform/kmp/kmp-shared-module-patterns/` → exit 0
  - `agents/multiplatform/kmp/kmp-expert.agent.md` tiene frontmatter válido con handoffs
  - `instructions/kmp.instructions.md` tiene `applyTo` en frontmatter
- **Reglas de negocio**: Skill debe cubrir KMP con Kotlin 2.0+ (no 1.x)

## 8. Notas y Definition of Ready
- **Decisiones abiertas**: ¿`kmp.instructions.md` aplica a todo el proyecto o solo al módulo `shared/`?
- **Supuestos**: KMP 2.0 es el baseline; no se cubre KMM (deprecated naming)
- **Dependencias previas**: US-001, US-003 completadas
- **Definition of Ready**:
  - [ ] US-003 completada (templates disponibles)
  - [ ] Decisión sobre scope de `kmp.instructions.md` tomada
