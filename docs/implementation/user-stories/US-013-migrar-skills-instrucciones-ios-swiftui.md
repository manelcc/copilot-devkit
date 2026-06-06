# US-013 — Migrar skills e instrucciones iOS SwiftUI

## Contexto de la necesidad
El proyecto `bankinter-devtools` contiene skills iOS probadas en proyectos reales. Migrarlas al namespace centralizado `skills/ios/swiftui/` junto con las instrucciones Swift/SwiftUI cubre el stack iOS moderno para cualquier equipo que use este repo central.

## 1. Encabezado y trazabilidad
- **ID US**: US-013
- **Título usuario**: Migrar skills iOS SwiftUI y crear instrucciones Swift/SwiftUI
- **Descripción usuario**: Como desarrollador iOS con SwiftUI, quiero las skills de bankinter-devtools disponibles en `skills/ios/swiftui/` y las instrucciones Swift/SwiftUI configuradas, para implementar features iOS de calidad sin buscar en repos externos.
- **Épica relacionada**: EP-5 — Stack iOS
- **Prioridad sugerida**: Alta (P0)
- **Criterios funcionales trazados**:
  - Skills iOS de `bankinter-devtools/skills/ios/` migradas a `skills/ios/swiftui/`
  - Skill `swiftui-patterns` creada
  - Agente `ios-swiftui-expert.agent.md` creado
  - `instructions/ios-swiftui.instructions.md` con reglas Swift + SwiftUI
  - Fuente: `bankinter-devtools/skills/ios/` y `bankinter-devtools/agents/ios/`

## Requerimientos de inicio

| ID | Requerimiento | Estado | Tipo | Evidencia/Nota |
|---|---|---|---|---|
| RQ-001 | Acceso a `bankinter-devtools/skills/ios/` | Necesario | Funcional | Path: `/Users/manelcc/Documents/BANKINTER/bankinter-devtools/skills/ios/` |
| RQ-002 | Acceso a `bankinter-devtools/agents/ios/` | Necesario | Funcional | Agentes iOS por proyecto (bro/inx/nbo) |

## 2. Cobertura funcional
- **Skills a migrar** desde `BK:skills/ios/` → `skills/ios/swiftui/`:
  - Todas las skills de los subdirectorios `bro/`, `inx/`, `nbo/` que sean genéricas (no específicas de proyecto)
  - Prefijo del proyecto en el nombre se elimina para generalizar

- **Skill nueva a crear**: `skills/ios/swiftui/swiftui-patterns/`
  - SwiftUI View lifecycle
  - `@State`, `@Binding`, `@ObservableObject`, `@Environment`
  - NavigationStack, Sheet, fullScreenCover
  - Async/await con `task {}` modifier
  - `List`, `LazyVStack`, `LazyHStack`

- **Agente**: `agents/ios/swiftui/ios-swiftui-expert.agent.md`
  - Detecta tipo de tarea iOS SwiftUI
  - Handoffs a skills SwiftUI

- **`instructions/ios-swiftui.instructions.md`**:
  - `applyTo: "**/*.swift"`
  - MVVM con `@Observable` (Swift 5.9+) o `ObservableObject`
  - Async/await, Combine donde aplica
  - NavigationStack (no NavigationView)
  - Testing: XCTest, ViewInspector

## 3. Dependencias y restricciones
- **Dependencias funcionales/técnicas**: US-001 (namespace `ios/swiftui/` existe), US-004 (validador)
- **Riesgos aplicables**: Las skills de bankinter pueden ser project-specific (bro/inx/nbo); necesitan revisión para generalizar
- **Pendientes de validación**: ¿Cuántas skills de bankinter son realmente genéricas? ¿Cuáles son solo para proyectos específicos?
- **Bloqueantes**: Acceso a bankinter-devtools

## 4. Solución funcional
- **Proceso**:
  1. `ls bankinter-devtools/skills/ios/` → listar skills disponibles
  2. Clasificar: genéricas (migrar) vs project-specific (descartar o crear variante genérica)
  3. Migrar genéricas a `skills/ios/swiftui/`
  4. Crear `swiftui-patterns` desde template
  5. Crear agente desde template con handoffs
  6. Crear `instructions/ios-swiftui.instructions.md`

## 5. Checklist de calidad
- **CRITICAL**
  - [ ] Skills genéricas de iOS migradas a `skills/ios/swiftui/`
  - [ ] `swiftui-patterns` skill creada y pasa validate-skill.sh
  - [ ] `agents/ios/swiftui/ios-swiftui-expert.agent.md` existe
  - [ ] `instructions/ios-swiftui.instructions.md` existe con `applyTo: "**/*.swift"`
- **HIGH**
  - [ ] Ninguna skill migrada tiene referencias a proyectos específicos de bankinter (bro/inx/nbo)
  - [ ] Instrucciones cubren: MVVM, async/await, NavigationStack, testing
- **MEDIUM**
  - [ ] Agente tiene handoffs a skills SwiftUI disponibles
- **LOW**
  - [ ] Nota de migración indica origen bankinter-devtools

## 6. Casos de prueba
- **Funcionales**:
  - `ls skills/ios/swiftui/` → al menos 2 directorios (skills migradas + swiftui-patterns)
  - `validate-skill.sh skills/ios/swiftui/swiftui-patterns/` → exit 0
  - `grep -ri "bankinter\|bro\|inx\|nbo" skills/ios/swiftui/` → sin resultados en contenido funcional
  - `instructions/ios-swiftui.instructions.md` tiene `applyTo: "**/*.swift"`
- **Errores**: Skill específica de proyecto bankinter encontrada → se mueve a `skills/ios/swiftui/legacy/` con nota

## 8. Notas y Definition of Ready
- **Decisiones abiertas**: ¿Skills específicas de proyectos bankinter (bro/inx/nbo) se incluyen con namespace de proyecto o se descartan?
- **Supuestos**: Las skills genéricas superan en número a las project-specific
- **Dependencias previas**: US-001, US-004 completadas
- **Fuentes**:
  - `bankinter-devtools/skills/ios/bro/`, `bk/inx/`, `bk/nbo/`
  - `bankinter-devtools/agents/ios/`
- **Definition of Ready**:
  - [ ] US-001, US-004 completadas
  - [ ] Acceso a bankinter-devtools confirmado
  - [ ] Decisión sobre skills project-specific tomada
