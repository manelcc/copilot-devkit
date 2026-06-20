# US-013-PLUS — Importar patrones y quality skills Android, iOS (enrich) y Python

**Como** desarrollador mobile/backend usando este devkit,  
**quiero** tener disponibles las skills de patrones de diseño, quality skills, agentes expertos y prompts para Android, iOS (enriquecido) y Python,  
**para** planificar e implementar con diagnóstico de patrón, detección de antipatrones y auditoría de calidad en los tres stacks sin salir del repo.

---

## Fuente de conocimiento

Proyecto origen:
`/Users/manelcc/Library/CloudStorage/OneDrive-SopraSteria/mac/KMP_APPS/PRUEBA-TECNICA/ANDROID`

---

## Inventario completo de assets a importar

### Android (nuevo en este repo)
| Asset | Origen | Destino en este repo |
|---|---|---|
| `android-patterns/SKILL.md` | `.github/skills/android-patterns/SKILL.md` | `skills/android/compose/android-patterns/SKILL.md` |
| `BEHAVIORAL-PATTERNS.md` | `.github/skills/android-patterns/` | `skills/android/compose/android-patterns/references/` |
| `CREATIONAL-PATTERNS.md` | `.github/skills/android-patterns/` | `skills/android/compose/android-patterns/references/` |
| `STRUCTURAL-PATTERNS.md` | `.github/skills/android-patterns/` | `skills/android/compose/android-patterns/references/` |
| `CONCURRENCY-PATTERNS.md` | `.github/skills/android-patterns/` | `skills/android/compose/android-patterns/references/` |
| `KOTLIN-ANDROID-PATTERNS.md` | `.github/skills/android-patterns/` | `skills/android/compose/android-patterns/references/` |
| `android-quality-skill/SKILL.md` | `.github/skills/android-quality-skill/SKILL.md` | `skills/android/compose/devkit-android-clean-architecture-quality/SKILL.md` |
| quality rules critical/high/medium/low | `.github/android-quality-rules/` | `skills/android/compose/devkit-android-clean-architecture-quality/references/` |
| `android-expert-pattern.agent.md` | `.github/agents/` | `agents/android/compose/android-expert-pattern.agent.md` |
| `android-quality.agent.md` | `.github/agents/` | `agents/android/compose/devkit-android-clean-architecture-quality.agent.md` |
| `android-expert-patterns.prompt.md` | `.github/prompts/` | `prompts/android/compose/android-expert-patterns.prompt.md` |
| `android-quality-analyze.md` | `.github/prompts/` | `prompts/android/compose/devkit-android-clean-architecture-quality-analyze.prompt.md` |

### iOS (enriquecimiento sobre US-013)
| Asset | Origen | Destino en este repo |
|---|---|---|
| `ios-quality-skill/SKILL.md` | `.github/skills/ios-quality-skill/SKILL.md` | `skills/ios/swiftui/devkit-ios-clean-architecture-quality/SKILL.md` |
| quality rules critical/high/medium/low | `.github/ios-quality-rules/` | `skills/ios/swiftui/devkit-ios-clean-architecture-quality/references/` |
| `ios-quality.agent.md` | `.github/agents/` | `agents/ios/swiftui/devkit-ios-clean-architecture-quality.agent.md` |
| `ios-expert-patterns.prompt.md` | `.github/prompts/` | `prompts/ios/swiftui/ios-expert-patterns.prompt.md` |
| `ios-quality-analyze.md` | `.github/prompts/` | `prompts/ios/swiftui/devkit-ios-clean-architecture-quality-analyze.prompt.md` |

> Nota: `ios-patterns` y `ios-swiftui-expert.agent.md` ya están cubiertos por US-013. La ios-quality-skill aporta las reglas de severidad que complementan el diagnóstico de antipatrones ya existente.

### Python (nuevo en este repo)
| Asset | Origen | Destino en este repo |
|---|---|---|
| `python-patterns/SKILL.md` | `.github/skills/python-patterns/SKILL.md` | `skills/backend/python/python-patterns/SKILL.md` |
| `BEHAVIORAL-PATTERNS.md` | `.github/skills/python-patterns/` | `skills/backend/python/python-patterns/references/` |
| `CREATIONAL-PATTERNS.md` | `.github/skills/python-patterns/` | `skills/backend/python/python-patterns/references/` |
| `STRUCTURAL-PATTERNS.md` | `.github/skills/python-patterns/` | `skills/backend/python/python-patterns/references/` |
| `CONCURRENCY-PATTERNS.md` | `.github/skills/python-patterns/` | `skills/backend/python/python-patterns/references/` |
| `PYTHON-PATTERNS.md` | `.github/skills/python-patterns/` | `skills/backend/python/python-patterns/references/` |
| `python-quality-skill/SKILL.md` | `.github/skills/python-quality-skill/SKILL.md` | `skills/backend/python/devkit-python-clean-architecture-quality/SKILL.md` |
| quality rules critical/high/medium/low | `.github/python-quality-rules/` | `skills/backend/python/devkit-python-clean-architecture-quality/references/` |
| `python-expert-pattern.agent.md` | `.github/agents/` | `agents/backend/python/python-expert-pattern.agent.md` |
| `python-quality.agent.md` | `.github/agents/` | `agents/backend/python/devkit-python-clean-architecture-quality.agent.md` |
| `python-expert-patterns.prompt.md` | `.github/prompts/` | `prompts/backend/python/python-expert-patterns.prompt.md` |
| `python-quality-analyze.md` | `.github/prompts/` | `prompts/backend/python/devkit-python-clean-architecture-quality-analyze.prompt.md` |

### Excluidos (específicos del ejercicio técnico)
- `evaluar-ejercicio-repo-mobile/SKILL.md` — contexto exclusivo de hiring
- `generar-ejercicio-repo-mobile/SKILL.md` — contexto exclusivo de hiring
- `mobile-exercise-designer/evaluator.agent.md` — contexto exclusivo de hiring
- `create-android-*/prepare-android-*` prompts — ejercicios técnicos de evaluación

---

## Criterios de Aceptación

1. `skills/android/compose/android-patterns/` existe con SKILL.md + 5 referencias por categoría + overview.md con Mermaid.
2. `skills/android/compose/devkit-android-clean-architecture-quality/` existe con SKILL.md + quality rules (critical/high/medium/low) como referencias.
3. `agents/android/compose/android-expert-pattern.agent.md` existe con handoff a `android-patterns`.
4. `agents/android/compose/devkit-android-clean-architecture-quality.agent.md` existe con handoff a `devkit-android-clean-architecture-quality`.
5. `agents/android/compose/android-compose-expert.agent.md` (existente US-012) actualizado para delegar también en `android-patterns` y `devkit-android-clean-architecture-quality`.
6. `skills/ios/swiftui/devkit-ios-clean-architecture-quality/` existe con SKILL.md + quality rules iOS como referencias.
7. `agents/ios/swiftui/devkit-ios-clean-architecture-quality.agent.md` existe.
8. `agents/ios/swiftui/ios-swiftui-expert.agent.md` (existente US-013) actualizado para delegar también en `devkit-ios-clean-architecture-quality`.
9. `skills/backend/python/python-patterns/` existe con SKILL.md + 5 referencias por categoría + overview.md con Mermaid.
10. `skills/backend/python/devkit-python-clean-architecture-quality/` existe con SKILL.md + quality rules Python como referencias.
11. `agents/backend/python/python-expert-pattern.agent.md` y `python-quality.agent.md` existen.
12. Prompts importados en `prompts/android/compose/`, `prompts/ios/swiftui/` y `prompts/backend/python/`.
13. Todas las skills nuevas pasan `./scripts/devkit-validate-skill.sh`.
14. Ningún asset importado contiene referencias al ejercicio técnico (hiring context).

---

## Checklist de calidad
- **CRITICAL**
  - [ ] android-patterns skill creada y validada
  - [ ] python-patterns skill creada y validada
  - [ ] android-quality y python-quality skills con reglas por severidad
  - [ ] ios-quality skill con reglas por severidad
- **HIGH**
  - [ ] Agentes expertos de patrón (android, python) con handoffs correctos
  - [ ] Agentes de quality (android, ios, python) con handoffs correctos
  - [ ] android-compose-expert.agent.md e ios-swiftui-expert.agent.md actualizados
- **MEDIUM**
  - [ ] Prompts importados y adaptados a la estructura del repo
  - [ ] Referencias por archivo presentes en cada skill de patrones

---

## Dependencias
- US-013 completada (merge en develop) — ✅ DONE
- Acceso confirmado al path fuente: `/Users/manelcc/Library/CloudStorage/OneDrive-SopraSteria/mac/KMP_APPS/PRUEBA-TECNICA/ANDROID`

---

## Épica relacionada
EP-5 (iOS) + EP-3 (Android) + EP-4 (Python/Backend)

## Prioridad
**P0** — Completa el catálogo de patrones y quality para los tres stacks principales.
