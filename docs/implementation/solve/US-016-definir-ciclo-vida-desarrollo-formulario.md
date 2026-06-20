# Solve — US-016 Agente orquestador del ciclo de desarrollo guiado con quality gates

**Estado**: ✅ Completado  
**Fecha de cierre**: 2025-01-24

## Resumen
Se implementa el **agente orquestador completo del ciclo de desarrollo** que gestiona las 9 fases desde planificación hasta MR/PR, con consulta a agentes expertos, quality gates obligatorios, decisiones interactivas del usuario y persistencia de artefactos.

## Cambios implementados

### 1. Agente orquestador
- **Ubicación**: `agents/global/devkit-development-lifecycle-orchestrator.agent.md`
- **Responsabilidad**: Pre-checks y delegación a la skill ejecutable
- **Handoffs**: `devkit-clean-architecture-quality`, `devkit-clean-code-guardian`, `Scrum Master`
- **Skills**: `devkit-development-lifecycle`, `devkit-git-workflow`, `devkit-mr-description-generator`

### 2. Skill ejecutable
- **Ubicación**: `skills/global/devkit-development-lifecycle/SKILL.md`
- **Triggers**: "ejecuta el ciclo completo", "implementa la US con ciclo guiado"
- **Fases implementadas**:
  - **A**: Planificación y análisis previo (consulta expertos, genera plan + test cases)
  - **B**: Implementación según plan
  - **C**: Generación de tests unitarios (cobertura ≥40%)
  - **D**: Quality gates obligatorios (clean-code, architecture, coverage)
  - **E**: Bucle de corrección si quality gates fallan (máx 3 iteraciones)
  - **F**: Pruebas E2E opcionales (decisión usuario)
  - **G**: Smoke tests opcionales (decisión usuario)
  - **H**: Commits atómicos (decisión usuario)
  - **I**: Descripción MR/PR con trazabilidad

### 3. Documentación técnica
- **Ubicación**: `skills/global/devkit-development-lifecycle/references/overview.md`
- **Contenido**: Diagramas Mermaid del flujo completo, tablas de decisión, artifacts

### 4. Estructura de documentos (templates de referencia en DevTools-AI)
Los templates se usan como referencia; los documentos reales se generan en **proyecto consumidor**:
- `docs/_TEMPLATE-implementation-plan.md`
- `docs/_TEMPLATE-test-cases.md`
- `docs/_TEMPLATE-smoke-suite.md`
- `docs/_TEMPLATE-clean-code-report.md`
- `docs/_TEMPLATE-architecture-report.md`

### 5. Artefactos generados en proyecto consumidor
```
proyecto-consumidor/
  docs/
    plan-implementation/US-XXX-implementation-plan.md
    test-cases/US-XXX-test-cases.md
    smoke-test/US-XXX-smoke-suite.md
    quality/US-XXX-clean-code-report.md
    quality/US-XXX-architecture-report.md
    mr/US-XXX-description.md
```

## Cobertura de criterios de aceptación

| # | Criterio | Estado |
|---|----------|--------|
| CA1 | Consulta 3 expertos (arquitectura, patrones, calidad) | ✅ Fase A.1.1 |
| CA2 | Genera plan de implementación detallado | ✅ Fase A.1.2 |
| CA3 | Genera test cases y smoke tests | ✅ Fase A.1.3 |
| CA4 | Ejecuta implementación y genera tests unitarios ≥40% | ✅ Fases B y C |
| CA5 | Ejecuta quality gates obligatorios y persiste reportes | ✅ Fase D |
| CA6 | Bucle de corrección si quality gates fallan (máx 3 iter.) | ✅ Fase E |
| CA7 | Pregunta por E2E y smoke tests, genera instrucciones | ✅ Fases F y G |
| CA8 | Prepara commits atómicos y pregunta si ejecutar | ✅ Fase H |
| CA9 | Genera descripción MR/PR con trazabilidad | ✅ Fase I |
| CA10 | Artefactos se generan en proyecto consumidor | ✅ Templates en DevTools-AI, docs en consumidor |

## Flujo de invocación

### Desde orquestadores de stack
Los orquestadores por tecnología (Android, iOS, Backend) delegan al agente de ciclo de desarrollo:

```
Usuario: "Implementa US-042"
↓
Orquestador de Stack (ej. devkit-backend-kotlin-project-orchestrator)
↓ (detecta que es implementación completa de US)
↓ handoff a devkit-development-lifecycle-orchestrator
↓ pre-checks (US existe, stack detectado, expertos disponibles)
↓ invoca skill devkit-development-lifecycle
↓
Ciclo completo de 9 fases ejecutado
```

### Ejemplo de ejecución completa
```
User: "Ejecuta el ciclo completo para US-042"

Agent (orchestrator): [Pre-checks: US-042 existe, stack: Backend Kotlin]
Agent: Invocando skill devkit-development-lifecycle...

Agent (skill): [Fase A] Leyendo US-042: "Add user authentication"
Agent: [A.1.1] Consultando expertos...
  → Arquitectura: Recomienda Clean Architecture con JWT en infra
  → Patrones: Recomienda Strategy para múltiples métodos auth
  → Calidad: Detecta deuda técnica en AuthController existente
Agent: [A.1.2] Plan generado: docs/plan-implementation/US-042-implementation-plan.md
Agent: [A.1.3] Test cases y smoke tests generados
Agent: ¿Procedo con la implementación?

User: "Sí"

Agent: [Fase B] Implementando según plan...
Agent: [Fase C] Generando tests unitarios...
Agent: [Fase D.1] Clean-code: ✓ Score 8.5, 0 critical issues
Agent: [Fase D.2] Architecture: ✓ Compliant, 0 violations
Agent: [Fase D.3] Coverage: ✓ 52%
Agent: Quality gates pasados. ¿Deseas ejecutar pruebas E2E?

User: "Sí"

Agent: [Fase F] Instrucciones E2E:
  docker compose up --build
  curl http://localhost:8080/auth/login
Agent: Confirma que las pruebas E2E pasaron

User: "Confirmado"

Agent: ¿Deseas ejecutar smoke tests?

User: "No"

Agent: [Fase H] Commits propuestos:
  1. feat(domain): add User and AuthToken entities
  2. feat(application): implement LoginUser use case with JWT
  3. feat(infrastructure): add JWTAuthService implementation
  4. test: add unit tests for LoginUser
Agent: ¿Ejecutar estos commits?

User: "Sí"

Agent: [Fase H] 4 commits ejecutados
Agent: [Fase I] MR description generada: docs/mr/US-042-description.md

Agent (orchestrator): Ciclo completo. Branch lista para push.
Agent: ¿Proceder con push y creación de MR?

User: "Sí"

Agent: [Ejecuta git push...]
Agent: Abre GitLab/GitHub para crear MR con descripción
```

### Ejemplo con bucle de corrección
```
User: "Implementa US-085"

Agent: [Fase A-C] ... implementación completada
Agent: [Fase D.1] Clean-code: ✗ 3 critical issues detected
  - Función login() tiene 45 líneas (máx: 30)
  - Clase AuthService tiene 8 responsabilidades (SRP violation)
  - Magic number 3600 en JWT expiration
Agent: [Fase D] Quality gate FAILED. Entrando en bucle de corrección...

Agent: [Fase E] Consultando expertos con reporte de fallos...
  → Arquitectura: Separar AuthService en AuthValidator + TokenGenerator
  → Patrones: Extraer método validate() de login()
  → Calidad: Usar constante JWT_EXPIRATION_SECONDS
Agent: [A.1.2] Plan ajustado (v2) generado

Agent: [Fase B-C] Re-implementando con correcciones...
Agent: [Fase D.1] Clean-code: ✓ Score 8.0, 0 critical issues
Agent: [Fase D.2-D.3] ✓ Architecture compliant, ✓ Coverage 45%
Agent: Quality gates pasados (intento 2/3). Continuando...
```

## Validación
- ✅ Skill ejecutable implementada con 9 fases completas
- ✅ Agente orquestador conectado con handoffs y pre-checks
- ✅ Templates de artefactos creados como referencia
- ✅ Documentación técnica con diagramas Mermaid
- ✅ Ejemplos de invocación con bucle de corrección
- ✅ Artefactos se generan en proyecto consumidor

## Próximos pasos
1. **Integrar handoff desde stack orchestrators**:
   - `devkit-backend-kotlin-project-orchestrator`
   - `devkit-android-project-orchestrator`
   - `devkit-ios-project-orchestrator`
2. **Testing end-to-end** con US real en proyecto consumidor
3. **Ajustar templates** según feedback de uso real
4. **Documentar en README** de DevTools-AI cómo invocar el ciclo

