# MR: US-016 — Agente orquestador del ciclo de vida de desarrollo guiado

| Campo | Valor |
|---|---|
| **Rama** | `feature/US-016-definir-ciclo-vida-desarrollo-formulario` |
| **Target** | `develop` |
| **Fecha** | 2026-06-20 |
| **Tipo** | `feat` |

---

## 🎯 Qué se ha implementado

Se implementa el **Development Lifecycle Orchestrator**: agente y skill que orquestan el ciclo completo de desarrollo de una User Story desde la planificación hasta la MR/PR lista para revisión.

El sistema guía al desarrollador a través de 9 fases con quality gates obligatorios, consulta a agentes expertos y puntos de decisión interactivos donde el usuario controla qué hace el agente y qué hace él mismo.

---

## 📦 Commits incluidos

### feat
- `feat(US-016)`: add development lifecycle orchestrator specification
- `feat(US-016)`: implement 9-phase development lifecycle skill
- `feat(US-016)`: add implementation mode choice to Phase B

---

## 📂 Archivos modificados

### Nuevos
| Archivo | Descripción |
|---|---|
| `agents/global/devkit-development-lifecycle-orchestrator.agent.md` | Agente orquestador con pre-checks y delegación a skill |
| `skills/global/devkit-development-lifecycle/SKILL.md` | Skill ejecutable con lógica de las 9 fases |
| `skills/global/devkit-development-lifecycle/references/overview.md` | Diagramas Mermaid y tablas de decisión |
| `docs/_TEMPLATE-implementation-plan.md` | Template de plan de implementación |
| `docs/_TEMPLATE-test-cases.md` | Template de test cases |
| `docs/_TEMPLATE-smoke-suite.md` | Template de smoke test suite |
| `docs/_TEMPLATE-clean-code-report.md` | Template de reporte clean-code |
| `docs/_TEMPLATE-architecture-report.md` | Template de reporte arquitectura |

### Modificados
| Archivo | Descripción |
|---|---|
| `docs/implementation/user-stories/US-016-*.md` | User Story actualizada con 9 fases y 10 ACs |
| `docs/implementation/solve/US-016-*.md` | Documentación de solución completa |

---

## 🔄 Fases del ciclo implementadas

| Fase | Descripción | Modo |
|------|-------------|------|
| **A** | Planificación: consulta expertos, genera plan + test cases + smoke tests | Automático |
| **B** | Implementación | ✋ **Usuario decide**: Automático / Manual / Híbrido |
| **C** | Generación de tests unitarios (cobertura ≥40%) | Automático |
| **D** | Quality gates obligatorios (clean-code, architecture, coverage) | Automático |
| **E** | Bucle de corrección si quality gates fallan (máx 3 iter.) | Automático |
| **F** | Pruebas E2E | ✋ **Usuario decide**: Sí / No |
| **G** | Smoke tests | ✋ **Usuario decide**: Sí / No |
| **H** | Commits atómicos | ✋ **Usuario decide**: Ejecutar / Manual / Editar |
| **I** | Descripción MR/PR con trazabilidad | Automático |

### Modos de implementación (Fase B)

```
¿Cómo quieres gestionar la implementación?
[A] Automático — El agente implementa todo según el plan
[B] Manual      — Tú implementas, el agente supervisa y valida
[C] Híbrido     — Elige qué partes implementa el agente y cuáles tú
```

### Quality gates (Fase D)

| Gate | Umbral |
|------|--------|
| Clean-code score | ≥7.0/10, 0 critical issues |
| Architecture | 0 critical violations |
| Test coverage | ≥40% |

Si algún gate falla → bucle de corrección (Fase E) con reporte a expertos (máx 3 iteraciones).

---

## 🤝 Handoffs del agente

- **`devkit-clean-architecture-quality`** → Fase D.2 (quality gate arquitectura)
- **`devkit-clean-code-guardian`** → Fase D.1 (quality gate clean-code)
- **`devkit-git-workflow`** → Fase H (commits atómicos)
- **`devkit-mr-description-generator`** → Fase I (descripción MR)
- **`Scrum Master`** → Si el scope de la US no está claro

---

## 🧪 Cómo probar en local

### Precondiciones
- Proyecto consumidor con User Story definida en `docs/implementation/user-stories/US-XXX-*.md`
- Agentes expertos disponibles para el stack detectado

### Pasos de validación del agente

1. Abrir Copilot Agent con el agente `devkit-development-lifecycle-orchestrator`
2. Invocar: `"Ejecuta el ciclo completo para US-XXX"`
3. Verificar que el agente:
   - Lee la US y consulta 3 expertos (arquitectura, patrones, calidad)
   - Genera `docs/plan-implementation/US-XXX-implementation-plan.md`
   - Genera `docs/test-cases/US-XXX-test-cases.md`
   - Genera `docs/smoke-test/US-XXX-smoke-suite.md`
   - Pregunta el modo de implementación (Automático / Manual / Híbrido)
   - Ejecuta quality gates y genera reportes en `docs/quality/`
   - Pregunta por E2E y smoke tests
   - Prepara commits atómicos y pregunta confirmación
   - Genera `docs/mr/US-XXX-description.md`

### Resultado esperado
- Todos los artefactos generados en `docs/` del proyecto consumidor
- Quality gates superados o bucle de corrección activado correctamente
- MR description lista con trazabilidad completa

---

## ✅ Criterios de aceptación

| # | Criterio | Estado |
|---|----------|--------|
| CA1 | Consulta 3 expertos (arquitectura, patrones, calidad) en Fase A.1.1 | ✅ |
| CA2 | Genera plan detallado persistido en `docs/plan-implementation/` | ✅ |
| CA3 | Genera test cases y smoke tests en `docs/test-cases/` y `docs/smoke-test/` | ✅ |
| CA4 | Pregunta modo de implementación (Automático / Manual / Híbrido) | ✅ |
| CA5 | Ejecuta quality gates obligatorios y persiste reportes | ✅ |
| CA6 | Bucle de corrección si quality gates fallan (máx 3 iter.) | ✅ |
| CA7 | Pregunta por E2E y smoke tests con instrucciones adaptadas | ✅ |
| CA8 | Prepara commits atómicos y pregunta confirmación | ✅ |
| CA9 | Genera descripción MR/PR con trazabilidad | ✅ |
| CA10 | Artefactos generados en proyecto consumidor, no en DevTools-AI | ✅ |

---

## 📋 Checklist para el reviewer

- [ ] Skill `devkit-development-lifecycle/SKILL.md` tiene las 9 fases completas
- [ ] Fase B incluye modos Automático / Manual / Híbrido
- [ ] Fase D define umbrales de quality gates
- [ ] Fase E tiene límite de 3 iteraciones en bucle de corrección
- [ ] Fases F, G, H tienen puntos de decisión interactivos del usuario
- [ ] Agente orquestador delega correctamente a la skill ejecutable
- [ ] Diagramas Mermaid en `references/overview.md` reflejan el flujo real
- [ ] Pre-commit hook validó la skill: `[OK] VALIDATION PASSED`
- [ ] Templates de artefactos disponibles en `docs/`

---

## 🔗 Referencias

- [User Story](../implementation/user-stories/US-016-definir-ciclo-vida-desarrollo-formulario.md)
- [Solve doc](../implementation/solve/US-016-definir-ciclo-vida-desarrollo-formulario.md)
- [Skill ejecutable](../../skills/global/devkit-development-lifecycle/SKILL.md)
- [Diagrama de flujo](../../skills/global/devkit-development-lifecycle/references/overview.md)
