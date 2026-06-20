# Solve — US-016 Agente orquestador del ciclo de desarrollo guiado con quality gates

## Resumen
Se implementa el **agente orquestador completo del ciclo de desarrollo** que gestiona las 9 fases desde planificación hasta MR/PR, con consulta a agentes expertos, quality gates obligatorios, decisiones interactivas del usuario y persistencia de artefactos.

## Cambios implementados

### 1. Agente orquestador
- **Ubicación**: `agents/global/devkit-development-lifecycle-orchestrator.agent.md`
- **Fases implementadas**:
  - **A**: Planificación y análisis previo (consulta expertos, genera plan + test cases)
  - **B**: Implementación según plan
  - **C**: Generación de tests unitarios
  - **D**: Quality gates obligatorios (clean-code, architecture, coverage ≥40%)
  - **E**: Bucle de corrección si quality gates fallan
  - **F**: Pruebas E2E opcionales (decisión usuario)
  - **G**: Smoke tests opcionales (decisión usuario)
  - **H**: Commits atómicos (decisión usuario)
  - **I**: Descripción MR/PR con trazabilidad

### 2. Estructura de documentos
- `docs/plan-implementation/`: Planes de implementación detallados
- `docs/test-cases/`: Test cases con priorización de smoke tests
- `docs/smoke-test/`: Suites de smoke test ejecutables
- `docs/quality/`: Informes de clean-code y clean-architecture

### 3. Templates de artefactos
- `docs/plan-implementation/_TEMPLATE-implementation-plan.md`
- `docs/test-cases/_TEMPLATE-test-cases.md`
- `docs/smoke-test/_TEMPLATE-smoke-suite.md`
- `docs/quality/_TEMPLATE-clean-code-report.md`
- `docs/quality/_TEMPLATE-architecture-report.md`

### 4. Handoffs del agente
- **A `devkit-clean-architecture-quality`**: Para análisis de arquitectura (Fase D.2)
- **A `devkit-clean-code-guardian`**: Para análisis clean-code (Fase D.1)
- **A `Scrum Master`**: Si scope de US no está claro

### 5. Skills utilizadas
- `devkit-git-workflow`: Para commits atómicos (Fase H)
- `devkit-mr-description-generator`: Para descripción MR/PR (Fase I)

## Cobertura de criterios de aceptación
1. Plan de implementación consultando expertos: ✅ Fase A.1.1 y A.1.2
2. Test cases y smoke tests propuestos: ✅ Fase A.1.3
3. Implementación según plan: ✅ Fase B
4. Quality gates obligatorios: ✅ Fase D (clean-code, architecture, coverage)
5. Bucle de corrección si falla: ✅ Fase E vuelve a Fase A.1.1
6. Pregunta por E2E con instrucciones adaptadas: ✅ Fase F
7. Pregunta por smoke tests: ✅ Fase G
8. Commits atómicos con confirmación: ✅ Fase H
9. Descripción MR/PR con trazabilidad: ✅ Fase I
10. Artefactos en estructura persistente: ✅ Todos en `docs/`

## Flujo de invocación

### Desde orquestadores de stack
Los orquestadores por tecnología (Android, iOS, Backend) delegan al agente de ciclo de desarrollo:

```
Usuario: "Implementa US-042"
↓
Orquestador de Stack (ej. devkit-backend-kotlin-project-orchestrator)
↓ (detecta que es implementación completa de US)
↓ handoff a devkit-development-lifecycle-orchestrator
↓
Ciclo completo de 9 fases ejecutado
```

### Ejemplo de ejecución
```
User: "Ejecuta el ciclo completo para US-042"
Agent: [Lee US-042]
Agent: [Consulta arquitectura, patrones, calidad]
Agent: "Plan de implementación generado en docs/plan-implementation/US-042-implementation-plan.md"
Agent: "Test cases generados en docs/test-cases/US-042-test-cases.md"
Agent: "Smoke tests propuestos: TC-001, TC-005"
Agent: "¿Procedo con la implementación?"
User: "Sí"
Agent: [Implementa según plan]
Agent: [Genera tests unitarios]
Agent: [Ejecuta quality gates]
Agent: "✓ Clean-code: 8.5/10"
Agent: "✓ Architecture: Compliant"
Agent: "✓ Coverage: 52%"
Agent: "Quality gates pasados. ¿Deseas ejecutar pruebas E2E?"
User: "Sí"
Agent: [Genera instrucciones E2E para Docker]
Agent: "Instrucciones: docker compose up --build && curl http://localhost:8080/health"
Agent: "¿Deseas ejecutar smoke tests?"
User: "No"
Agent: [Prepara commits atómicos]
Agent: "Commits propuestos:"
Agent: "1. feat: add User entity"
Agent: "2. feat: implement CreateUser use case"
Agent: "3. test: add unit tests for CreateUser"
Agent: "¿Ejecutar estos commits?"
User: "Sí"
Agent: [Ejecuta commits]
Agent: [Genera descripción MR]
Agent: "MR generada en docs/mr/US-042-description.md"
Agent: "Ciclo completo. ¿Proceder con push y creación de MR?"
```

## Validación
- Diagrama de flujo completo en US-016 con 9 fases y decisiones del usuario
- Templates de artefactos disponibles en `docs/`
- Handoffs a agentes expertos definidos
- Skills de git y MR integradas

## Próximos pasos
1. Integrar el handoff desde orquestadores de stack existentes:
   - `devkit-backend-kotlin-project-orchestrator`
   - `devkit-android-project-orchestrator`
   - `devkit-ios-project-orchestrator`
2. Validar con una US real end-to-end
3. Ajustar templates de artefactos según feedback
