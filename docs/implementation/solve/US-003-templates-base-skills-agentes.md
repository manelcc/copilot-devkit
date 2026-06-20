# US-003 — Crear artefactos consistentes sin partir de cero

**Como** contributor creando una nueva skill o agente,  
**quiero** un template completo como punto de partida,  
**para** generar artefactos con estructura consistente sin necesitar estudiar ejemplos existentes o documentación.

---

## Requerimientos de inicio

| ID | Requerimiento | Estado | Tipo | Evidencia/Nota |
|---|---|---|---|---|
| RQ-001 | SKILL.md debe tener frontmatter YAML con `name` y `description` | Necesario | Funcional | Requerido por validate-skill.sh (US-004) |
| RQ-002 | Secciones obligatorias: When to use, When NOT to use, Inputs, Steps, Outputs, Validation, Examples | Necesario | Funcional | Basado en skill-generator global (~/.copilot/skills/skill-generator/) |
| RQ-003 | overview.md debe contener bloque Mermaid | Necesario | Funcional | Requerido por validate-skill.sh |
| RQ-004 | _TEMPLATE.agent.md debe tener `description` y `handoffs` en frontmatter | Necesario | Funcional | Patrón mycardiochef/.github/agents/_TEMPLATE.agent.md |

## 2. Cobertura funcional
- **Flujo principal**:
  1. Contributor ejecuta `devtools scaffold skill my-skill android/compose`
  2. CLI copia `skills/_TEMPLATE/` a `skills/android/compose/my-skill/`
  3. Reemplaza placeholders `[Name]`, `[namespace]`
  4. Contributor edita SKILL.md con contenido real
  5. Pre-commit valida antes del commit
- **Entradas**: Nombre de skill y namespace destino
- **Validaciones**: El template en sí no debe fallar `validate-skill.sh`
- **Salidas**: Directorio `skills/<namespace>/<name>/` con SKILL.md + references/overview.md
- **Casos límite**: Si el nombre ya existe en el namespace, advertir sin sobreescribir

## 3. Dependencias y restricciones
- **Dependencias funcionales/técnicas**: US-001 (directorios existen); US-004 usa estos templates como referencia de validación
- **Riesgos aplicables**: Si el template cambia, las skills existentes deben revisarse
- **Pendientes de validación**: ¿Se necesita template separado para skills con `scripts/`?
- **Bloqueantes**: Ninguno

## 4. Solución funcional

**Secciones obligatorias de `skills/_TEMPLATE/SKILL.md`**:
- frontmatter YAML (name, description)
- `## When to use` — triggers
- `## When NOT to use` — non-triggers
- `## Inputs`
- `## Steps`
- `## Expected outputs`
- `## Validation` — checklist
- `## Examples` — ejemplo realista con prompt y acción

**Secciones de `agents/_TEMPLATE.agent.md`**:
- frontmatter: description, handoffs (array con label, agent, prompt)
- `## Pre-Execution Checks`
- `## Outline` (pasos numerados)
- `## Expected output`

**Fuentes de referencia**:
- `mycardiochef/.github/skills/clean-code-guardian/SKILL.md` — ejemplo skill compleja
- `mycardiochef/.github/agents/_TEMPLATE.agent.md` — template agente existente

## 5. Checklist de calidad
- **CRITICAL**
  - [ ] `skills/_TEMPLATE/SKILL.md` pasa `validate-skill.sh` sin errores
  - [ ] `skills/_TEMPLATE/references/overview.md` contiene bloque mermaid
  - [ ] `agents/_TEMPLATE.agent.md` tiene frontmatter con description y handoffs
- **HIGH**
  - [ ] Todos los placeholders marcados con `[UpperCase]` fáciles de localizar
  - [ ] Template de SKILL.md incluye ejemplo realista (no solo "example placeholder")
- **MEDIUM**
  - [ ] Template de agente incluye al menos un handoff de ejemplo
- **LOW**
  - [ ] Comentarios en templates explican cada sección

## Criterios de Aceptación

1. El archivo `skills/_TEMPLATE/SKILL.md` existe y contiene frontmatter YAML con campos `name` y `description`.
2. El template de skill incluye secciones obligatorias: "When to use", "When NOT to use", "Inputs", "Steps", "Expected outputs", "Validation", "Examples".
3. El archivo `skills/_TEMPLATE/references/overview.md` contiene un bloque Mermaid placeholder de tipo `flowchart TD`.
4. El archivo `agents/_TEMPLATE.agent.md` existe y contiene frontmatter con campos `description`, `tools` y `model`.
5. Ejecutar `./scripts/validate-skill.sh skills/_TEMPLATE/` devuelve exit code 0 (sin errores).
6. Todos los placeholders en templates están marcados con `[UpperCase]` para fácil localización (ejemplo: `[Name]`, `[Namespace]`).
7. El template de skill incluye al menos un ejemplo realista con prompt de usuario y acción esperada (no solo "example placeholder").
8. Ejecutar `devtools scaffold skill test-skill global` usando estos templates genera un directorio `skills/global/test-skill/` con archivos válidos.

---

## Notas Técnicas

**Fuentes de referencia**:
- `~/.copilot/skills/skill-generator/` — estructura de referencia
- `.github/skills/prd-to-epics-mapper/` — ejemplo skill compleja existente

**Decisiones abiertas**: ¿Se necesita template separado para skills con `scripts/`?

**Supuestos**: El validador de US-004 acepta estos templates sin modificaciones.

---

## Validación INVEST

| Criterio | ✅ / ⚠️ | Observación |
|---|---|---|
| **Independiente** | ✅ | Depende de US-001 (directorios existen), pero no de US-004 |
| **Negociable** | ✅ | Número de secciones del template ajustable |
| **Valiosa** | ✅ | Reduce tiempo de creación de artefacto de 2h a 30 min |
| **Estimable** | ✅ | Redacción de 2 templates: 4-6 horas |
| **Small** | ✅ | 8 CA, cubre un flujo (scaffold → validación) |
| **Testeable** | ✅ | Todos los CA verificables con comandos de validación |

---

## Épica Relacionada

EP-1 — Habilitar contribución colaborativa en el repositorio DevTools-AI

---

## Prioridad

**P0** (Bloqueante) — Sin templates, cada contributor inventa su propia estructura.

---

## 6. Casos de prueba
- **Funcionales**:
  - Copiar `skills/_TEMPLATE/` a `skills/global/test-skill/` → `validate-skill.sh` → exit 0
  - `agents/_TEMPLATE.agent.md` tiene YAML frontmatter válido (parseable)
- **Reglas de negocio**:
  - Un template sin "When NOT to use" debe fallar el validador
- **Errores**: Si overview.md no tiene mermaid, validador indica exactamente qué falta

## 7. Diagrama de flujo
```mermaid
flowchart TD
    A[devtools scaffold skill name namespace] --> B[Copiar _TEMPLATE/ a destino]
    B --> C[Reemplazar placeholders]
    C --> D[Abrir SKILL.md en editor]
    D --> E[Contributor edita contenido]
    E --> F[git commit]
    F --> G{pre-commit validate-skill.sh}
    G -->|válida| H[Commit aceptado]
    G -->|inválida| I[Error con sección faltante]
    I --> E
```

## 8. Notas y Definition of Ready
- **Decisiones abiertas**: ¿El template de agente necesita sección "When NOT to use"?
- **Supuestos**: Los templates son estáticos, no generados dinámicamente
- **Dependencias previas**: US-001 completada
- **Definition of Ready**:
  - [ ] US-001 completada
  - [ ] Secciones obligatorias de SKILL.md acordadas con el equipo
  - [ ] Criterios del validador (US-004) definidos aunque no implementado
