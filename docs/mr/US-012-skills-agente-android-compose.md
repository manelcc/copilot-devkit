# MR/PR Description

## Que hace
- Implementa US-012 con dos skills nuevas para Android Compose:
  - skills/android/compose/jetpack-compose-patterns/
  - skills/android/compose/android-navigation-compose/
- Crea el agente experto de Compose:
  - agents/android/compose/android-compose-expert.agent.md
- Añade handoffs explícitos del agente a las tres skills objetivo de la US:
  - devkit-migrate-xml-to-compose
  - jetpack-compose-patterns
  - android-navigation-compose
- Incluye ejemplos realistas de código Kotlin/Compose en ambas skills.
- Incluye references/overview.md con diagrama Mermaid en ambas skills.
- Alinea el contenido con Android Skills oficiales, especialmente:
  - android/skills navigation/navigation-3
  - android/skills jetpack-compose (adaptive y migration)

## Por que
- Completa el stack base de Android Compose para desarrollo guiado por skills.
- Reduce ambigüedad en decisiones de implementación para features nuevas, refactors y navegación.
- Establece una orquestación explícita para seleccionar la skill adecuada según tipo de tarea.

## Como probar
### Precondiciones
- Rama checkout: feature/US-012-skills-agente-android-compose
- Repo actualizado desde origin/develop

### Pasos
1. Validar skill de patrones Compose:
   ./scripts/devkit-validate-skill.sh skills/android/compose/jetpack-compose-patterns
2. Validar skill de navegación Compose:
   ./scripts/devkit-validate-skill.sh skills/android/compose/android-navigation-compose
3. Verificar agente:
   - existe agents/android/compose/android-compose-expert.agent.md
   - frontmatter YAML válido
   - handoffs a devkit-migrate-xml-to-compose, jetpack-compose-patterns y android-navigation-compose
4. Revisar que ambas skills incluyen:
   - secciones obligatorias del template
   - ejemplos de código realista
   - references/overview.md con Mermaid

### Resultado esperado
- Ambas skills pasan validación con exit code 0.
- El agente Android Compose experto existe y orquesta correctamente por tipo de tarea.
- Los artefactos cubren los criterios funcionales de la US-012 para patterns + Nav3 + handoffs.

## Checklist
- [x] Rama creada desde develop actualizado
- [x] Commit atómico y semántico
- [x] Validación de skills en verde
- [x] Agente con handoffs requeridos
- [x] Referencias oficiales Android incorporadas en el contenido

## Referencias
- Branch: feature/US-012-skills-agente-android-compose
- Base: develop
- Commit:
  - 60ac796
- Commits (rango): origin/develop..feature/US-012-skills-agente-android-compose