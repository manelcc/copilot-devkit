# DevTools Scaffold — Quick Reference

## Comandos Disponibles

Genera la estructura base de artefactos automáticamente desde templates.

### `devtools scaffold skill`

Genera una skill dentro del DevKit (`skills/<namespace>/<skill-name>/`)

```bash
devtools scaffold skill <skill-name> <namespace>
```

**Ejemplos:**
```bash
devtools scaffold skill jwt-authentication backend/kotlin-ktor
devtools scaffold skill edge-to-edge-ui android/compose
devtools scaffold skill shared-module-patterns multiplatform/kmp
```

### `devtools scaffold instruction`

Genera una instruction a nivel raíz (`instructions/<instruction-name>.instructions.md`)

```bash
devtools scaffold instruction <instruction-name>
```

**Ejemplos:**
```bash
devtools scaffold instruction devkit-backend-java
devtools scaffold instruction devkit-cmp-advanced
```

### `devtools scaffold prompt`

Genera un prompt dentro del DevKit (`prompts/<namespace>/<prompt-name>.prompt.md`)

```bash
devtools scaffold prompt <prompt-name> <namespace>
```

**Ejemplos:**
```bash
devtools scaffold prompt design-patterns-finder backend/kotlin-ktor
devtools scaffold prompt quality-analyzer android/compose
```

---

## Tabla de Referencia

| Comando | Ubicación | Con namespace | Archivo |
|---------|-----------|---------------|---------|
| `skill` | `skills/` | ✓ Sí | `SKILL.md` (carpeta) |
| `instruction` | `instructions/` | ✗ No | `*.instructions.md` (flat) |
| `prompt` | `prompts/` | ✓ Sí | `*.prompt.md` |

---

## Validaciones Automáticas

✓ Verifica que el namespace exista  
✓ Previene nombres con `/`  
✓ Evita sobrescribir artefactos existentes  
✓ Reemplaza placeholders automáticamente en templates  

---

## Salida esperada

```
✓ Skill creado en /Users/manelcc/.../skills/backend/kotlin-ktor/jwt-authentication/SKILL.md
✓ Instruction creada en /Users/manelcc/.../instructions/devkit-backend-java.instructions.md
✓ Prompt creado en /Users/manelcc/.../prompts/backend/kotlin-ktor/design-patterns-finder.prompt.md
```

---

## Workflow Post-US

El agente **Development Lifecycle Orchestrator** ofrece generar artefactos automáticamente:

```
Agent: ¿Deseas generar una skill reutilizable para esta funcionalidad?
User: "Sí"

Agent: Nombre de la skill: jwt-authentication
Agent: Namespace: backend/kotlin-ktor

Agent: [Ejecuta] devtools scaffold skill jwt-authentication backend/kotlin-ktor
Agent: ✓ Skill creada en skills/backend/kotlin-ktor/jwt-authentication/SKILL.md
Agent: → Completa manualmente: descripción, parámetros, ejemplos, referencias
```

---

## Próximos Pasos

Después de scaffoldear, edita el archivo generado:

### Skills
1. Completa la descripción en el frontmatter
2. Define triggers y non_triggers
3. Añade secciones: Purpose, When to use, When NOT to use, Inputs, Steps, Outputs
4. Crea `references/overview.md` con documentación adicional

### Instructions
1. Completa el contexto y principios generales
2. Define key patterns con ejemplos
3. Lista anti-patterns a evitar
4. Proporciona quality checklist

### Prompts
1. Actualiza `title` y `description`
2. Enlaza el `agent` correcto
3. Define el proceso/pasos
4. Añade escenarios comunes y referencia rápida

Ver:
- [Skill Template](skills/_TEMPLATE/SKILL.md)
- [Instruction Template](instructions/_TEMPLATE/TEMPLATE.instructions.md)
- [Prompt Template](prompts/_TEMPLATE/TEMPLATE.prompt.md)

