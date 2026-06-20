# MR/PR Description

## Que hace
- Implementa US-010 con orquestación especializada por stack y convención de naming `devkit-` en artefactos clave.
- Añade 7 agentes orquestadores por tecnología:
  - `devkit-android-project-orchestrator`
  - `devkit-ios-project-orchestrator`
  - `devkit-backend-kotlin-project-orchestrator`
  - `devkit-backend-python-project-orchestrator`
  - `devkit-backend-java-project-orchestrator`
  - `devkit-kmp-project-orchestrator`
  - `devkit-cmp-project-orchestrator`
- Crea instrucciones globales cross-stack en `instructions/devkit-global.instructions.md` con `applyTo: "**"`.
- Migra naming en agentes, instrucciones, skills y scripts a prefijo `devkit-`.
- Actualiza hook de pre-commit para validar con `scripts/devkit-validate-skill.sh` y corrige resolución de rutas de skills anidadas.

## Por que
- Evita ambigüedad al enrutar tareas entre stacks distintos (Android, iOS, backend Kotlin/Python/Java, KMP, CMP).
- Estandariza naming del repositorio para distinguir claramente este kit (`devkit-`) y facilitar mantenimiento.
- Centraliza reglas globales mínimas para commits, PR/MR y delegación por stack.

## Como probar
### Precondiciones
- Rama checkout: `feature/US-010-devkit-project-orchestrators`
- Repo actualizado desde `origin/develop`

### Pasos
1. Verificar existencia de los 7 orquestadores especializados bajo `agents/`.
2. Verificar `instructions/devkit-global.instructions.md` con frontmatter `applyTo: "**"`.
3. Ejecutar commit de prueba que toque un `SKILL.md` y validar que el hook llama a `scripts/devkit-validate-skill.sh`.
4. Revisar que los artefactos migrados usen prefijo `devkit-` en `agents/`, `instructions/`, `skills/` y `scripts/`.

### Resultado esperado
- Delegación por stack disponible con naming consistente `devkit-`.
- Hook pre-commit funcional tras renaming de script.
- US-010 reflejada en documentación y cambios versionados.

## Checklist
- [x] Rama creada desde `develop` actualizado
- [x] Commits atomicos y semanticos
- [ ] Build/Test en verde
- [x] Riesgos y limitaciones documentados
- [x] Documentacion actualizada si aplica

## Referencias
- Branch: `feature/US-010-devkit-project-orchestrators`
- Base: `develop`
- Commit: `11a6c78`
- Commits (rango): `origin/develop..feature/US-010-devkit-project-orchestrators`
- PR URL sugerida por remoto:
  - `https://github.com/manelcc/copilot-devkit/pull/new/feature/US-010-devkit-project-orchestrators`
