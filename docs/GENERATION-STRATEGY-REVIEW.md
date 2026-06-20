# Generation Strategy Review — Project Generators

**Fecha de completación**: 2026-06-20  
**Estado**: ✓ COMPLETADO (Fase 1: CLI expandida)

---

## Generadores Identificados

### 1. **CLI: `devtools scaffold skill`** ✓ INTEGRADO
- **Propósito**: Genera skills dentro del DevKit (`skills/<namespace>/<skill-name>/`)
- **Estado**: Implementado en `cli-tools/devtools/commands/scaffold.py`
- **Integración**: 
  - ✓ Usado por `devkit-development-lifecycle-orchestrator` (post-US)
  - ✓ Disponible vía CLI: `devtools scaffold skill <name> <namespace>`
- **Ubicación**: Solo en el proyecto DevKit (artefactos internos)

### 2. **Skill: `devkit-kotlin-mcp-server-generator`** ✓ INDEPENDIENTE
- **Propósito**: Genera proyectos MCP **completos** (externos al DevKit)
- **Salida**: Proyecto nuevo con Gradle, Kotlin, tests, README
- **Alcance**: Fuera del DevKit (es un consumidor del DevKit)
- **Trigger**: "genera el proyecto mcp", "bootstrap del mcp server"
- **Integración**: Delegado por `devkit-kotlin-mcp-expert` agent
- **Justificación**: Diferente scope (proyectos externos ≠ skills internas)

### 3. **Agent: `devkit-devops`** ⚠ DOCUMENTAR INTEGRACIÓN
- **Propósito**: Genera pipelines CI/CD (YAML: GitLab CI, GitHub Actions, Azure DevOps)
- **Salida**: Archivos en raíz del proyecto consumidor (`.github/workflows/`, `.gitlab-ci.yml`, etc)
- **Ubicación**: Fuera del DevKit (artefacto del proyecto consumidor)
- **Trigger**: "crea la pipeline", "configura CI/CD", etc
- **Status**: ⚠ No documentado si requiere `devtools` CLI o integración especial

### 4. **Skills de Guidance** ✓ NO GENERAN ARCHIVOS
- `devkit-postgresql-crud` → Patrones de BD
- `devkit-ktor-auth-flow` → Patrones de autenticación
- `devkit-clean-code-guardian` → Revisor de calidad
- `devkit-mr-description-generator` → Genera descripción MR
- `devkit-development-lifecycle` → Orquesta 9 fases

---

## Matrix de Generación

| Generator | Genera | Ubicación | CLI/Skill | Integrado | Notas |
|-----------|--------|-----------|-----------|-----------|-------|
| `scaffold skill` | Skills | DevKit/skills/ | ✓ CLI | ✓ Sí | En lifecycle orchestrator |
| `kotlin-mcp-generator` | Proyectos MCP | Externo | Skill | ✓ Sí | Via devkit-kotlin-mcp-expert |
| `devops` | Pipelines CI/CD | Externo | Agent | ⚠ Parcial | Revisar delegación |

---

## Conclusiones

### ✓ Bien Integrado
1. **Skills + devtools scaffold** funcionan juntos correctamente
2. **devkit-development-lifecycle-orchestrator** ahora ofrece generar skill post-US
3. **MCP generator** está clara su responsabilidad (proyectos nuevos)

### ⚠ Hallazgos de Revisión

**Orchestrators de otros stacks:**
- ✓ `devkit-android-project-orchestrator` → Solo routing (no genera)
- ✓ `devkit-ios-project-orchestrator` → Solo routing (no genera)
- ✓ `devkit-kmp-project-orchestrator` → Solo routing (no genera)
- **Conclusión**: Correcto; no necesitan project generators propios

### ➡ Próximas Acciones (Priorizadas)

**🔴 ALTA PRIORIDAD**
1. Expandir `devtools scaffold` CLI (baja complejidad, alto impacto):
   - `devtools scaffold instruction <name> <namespace>`
   - `devtools scaffold prompt <name> <namespace>`
   - Completar simetría 1:1

**🟡 MEDIA PRIORIDAD**
2. Documentar `devkit-devops` CI/CD generation:
   - Revisar cómo se invoca y qué genera
   - Considerar integración con CLI

**🟢 BAJA PRIORIDAD**
3. Testing end-to-end: US → implementation → scaffold skill → merge

---

## Comando CLI Disponible

```bash
# Crear skill dentro del DevKit
devtools scaffold skill <name> <namespace>

# Ejemplos:
devtools scaffold skill user-auth backend/kotlin-ktor
devtools scaffold skill navigation android/compose
devtools scaffold skill state-management multiplatform/kmp
```

## Referencias
- [US-081 — Comando devtools scaffold](docs/implementation/user-stories/US-081-comando-devtools-scaffold.md)
- [SCAFFOLD-QUICK-REFERENCE](docs/SCAFFOLD-QUICK-REFERENCE.md)
- [Development Lifecycle Orchestrator](agents/global/devkit-development-lifecycle-orchestrator.agent.md)

