# US-014 — Crear skills KMP y agente multiplatform

## Contexto de la necesidad
Kotlin Multiplatform es uno de los stacks de mayor crecimiento para compartir lógica de negocio entre Android e iOS. Esta US crea las skills y el agente que cubren el módulo compartido KMP, habilitando a los equipos a implementar y mantener código KMP con guía de calidad.

## 1. Encabezado y trazabilidad
- **ID US**: US-014
- **Título usuario**: Skills KMP shared module y agente multiplatform
- **Descripción usuario**: Como desarrollador trabajando con Kotlin Multiplatform, quiero skills que me guíen en la estructura del módulo compartido y un agente KMP, para implementar lógica multiplataforma con patrones correctos.
- **Épica relacionada**: EP-6 — Multiplatform KMP/CMP
- **Prioridad sugerida**: Alta (P1)
- **Criterios funcionales trazados**:
  - `skills/multiplatform/kmp/kmp-shared-module-patterns/`
  - `agents/multiplatform/kmp/kmp-expert.agent.md`
  - `instructions/kmp.instructions.md`

## 2. Cobertura funcional
- **`kmp-shared-module-patterns/`** — cubre:
  - Estructura de módulo KMP: `commonMain`, `androidMain`, `iosMain`
  - `expect`/`actual` declarations
  - Ktor Client multiplataforma (HTTP)
  - SQLDelight (base de datos compartida)
  - `kotlinx.coroutines` en contexto KMP
  - Shared ViewModels: patrón para exponerlos a iOS (StateFlow → Swift)
  - Interop iOS: `@ObjCName`, `@Throws`, KMP-NativeCoroutines

- **`kmp-expert.agent.md`** — comportamiento:
  - Detecta si la tarea es en módulo shared, Android o iOS
  - Invoca patrones KMP según el contexto
  - Handoffs a android-compose-expert o ios-swiftui-expert si la tarea es de UI

- **`instructions/kmp.instructions.md`**:
  - `applyTo: "**/*.kt"` (módulos multiplatform)
  - Reglas de expect/actual
  - Convenciones de naming para APIs públicas multiplataforma
  - Restricciones de dependencies en commonMain

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
