# US-013 — Implementar features iOS SwiftUI con guía estructurada

**Como** desarrollador iOS con SwiftUI,  
**quiero** las skills de bankinter-devtools disponibles en `skills/ios/swiftui/` y las instrucciones Swift/SwiftUI configuradas,  
**para** implementar features iOS de calidad sin buscar en repositorios externos.

---

## Requerimientos de inicio

| ID | Requerimiento | Estado | Tipo | Evidencia/Nota |
|---|---|---|---|---|
| RQ-001 | Acceso a `bankinter-devtools/skills/ios/` | Necesario | Funcional | Path: `/Users/manelcc/Documents/BANKINTER/bankinter-devtools/skills/ios/` |
| RQ-002 | Acceso a `bankinter-devtools/agents/ios/` | Necesario | Funcional | Agentes iOS por proyecto (bro/inx/nbo) |

## Criterios de Aceptación

1. Las skills genéricas de `bankinter-devtools/skills/ios/{bro,inx,nbo}/` están migradas a `skills/ios/swiftui/` (se eliminan prefijos de proyecto: `bro-`, `inx-`, `nbo-`).
2. La skill `skills/ios/swiftui/swiftui-patterns/` cubre: `@State`, `@Binding`, `@ObservableObject`, NavigationStack, async/await con `task {}`, `List`, `LazyVStack`.
3. El agente `agents/ios/swiftui/ios-swiftui-expert.agent.md` detecta tipo de tarea iOS SwiftUI y delega a skills relevantes.
4. El archivo `instructions/ios-swiftui.instructions.md` existe con `applyTo: "**/*.swift"`.
5. Las instrucciones incluyen reglas de: (1) MVVM con `@Observable` o `ObservableObject`, (2) Async/await, Combine, (3) NavigationStack (no NavigationView), (4) Testing con XCTest.
6. Ninguna skill migrada contiene referencias específicas al proyecto bankinter (verificable con `grep -r "bankinter" skills/ios/swiftui/` sin resultados o solo en comentarios de origen).
7. Cada skill migrada pasa validación: `./scripts/validate-skill.sh skills/ios/swiftui/<skill-name>/` devuelve exit code 0.
8. Ejecutar `ls -1 skills/ios/swiftui/` muestra al menos 3 skills (migradas + swiftui-patterns).

---

## Notas Técnicas

**Path fuente**: `/Users/manelcc/Documents/BANKINTER/bankinter-devtools/skills/ios/`

**Proceso de migración**:
- Identificar skills genéricas (no específicas de bro/inx/nbo)
- Eliminar prefijos de proyecto del nombre
- Actualizar frontmatter y paths relativos

**Decisiones abiertas**: ¿Qué skills de bankinter-devtools son genéricas vs específicas de proyecto?

**Supuestos**: Las skills de bankinter-devtools están actualizadas con SwiftUI moderno.

---

## Validación INVEST

| Criterio | ✅ / ⚠️ | Observación |
|---|---|---|
| **Independiente** | ✅ | Depende de US-001, US-003, US-004 |
| **Negociable** | ✅ | Número de skills migradas ajustable |
| **Valiosa** | ✅ | Skills probadas en producción disponibles para cualquier proyecto iOS |
| **Estimable** | ✅ | Migración + creación de swiftui-patterns + agente: 8-12 horas |
| **Small** | ✅ | 8 CA, cubre migración + skill nueva + agente + instrucciones |
| **Testeable** | ✅ | Todos los CA verificables con validador y grep |

---

## Épica Relacionada

EP-5 — Stack iOS

---

## Prioridad

**P0** (Bloqueante) — Primera población del namespace iOS.

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
