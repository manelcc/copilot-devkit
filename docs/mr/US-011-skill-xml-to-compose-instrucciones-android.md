# MR/PR Description

## Que hace
- Implementa US-011 para Android Compose con una skill operativa de migración XML -> Compose en `skills/android/compose/devkit-migrate-xml-to-compose/`.
- Completa `instructions/devkit-android-compose.instructions.md` con reglas de Compose, Navigation 3, Hilt, Coroutines + Flow, Material3 y testing con `composeTestRule`.
- Refuerza política de integración con skills oficiales Android:
  - uso obligatorio condicional de `https://github.com/android/skills` cuando la cobertura local no sea suficiente.
- Define y aplica la regla de oro Android CLI First:
  - priorizar flujos ejecutables por CLI para build, test, lint y validaciones de migración.
- Alinea el orquestador Android con estas políticas en `agents/android/devkit-android-project-orchestrator.agent.md`.

## Por que
- Asegura cobertura real de casos Android avanzados sin depender solo de la skill local.
- Estandariza una política técnica clara para agentes: primero CLI, luego alternativas manuales solo si no existe vía automatizable.
- Reduce ambigüedad operativa al documentar cuándo escalar a Android Skills oficiales.

## Como probar
### Precondiciones
- Rama checkout: `feature/US-011-skill-xml-to-compose-instrucciones-android`
- Repo actualizado desde `origin/develop`

### Pasos
1. Validar skill: `./scripts/devkit-validate-skill.sh skills/android/compose/devkit-migrate-xml-to-compose`
2. Revisar instrucciones Android Compose:
   - existe `applyTo: "**/*.kt"`
   - incluye secciones de Compose, Navigation 3, Hilt, Flow, Material3 y testing.
3. Verificar política Android Skills oficiales en instrucciones y US:
   - obligatoriedad condicional cuando exista gap funcional.
4. Verificar regla de oro Android CLI en:
   - `instructions/devkit-android-compose.instructions.md`
   - `agents/android/devkit-android-project-orchestrator.agent.md`

### Resultado esperado
- Skill de migración válida y usable.
- Instrucciones Android Compose completas.
- Política de uso de Android Skills oficiales aplicada.
- Regla CLI-first formalizada en documentación y orquestación.

## Checklist
- [x] Rama creada desde `develop` actualizado
- [x] Commits atomicos y semanticos
- [x] Validación de skill en verde
- [x] Riesgos y limitaciones documentados
- [x] Documentación actualizada si aplica

## Referencias
- Branch: `feature/US-011-skill-xml-to-compose-instrucciones-android`
- Base: `develop`
- Commits:
  - `ddcb784`
  - `f4cfbc1`
  - `23749a3`
- Commits (rango): `origin/develop..feature/US-011-skill-xml-to-compose-instrucciones-android`
