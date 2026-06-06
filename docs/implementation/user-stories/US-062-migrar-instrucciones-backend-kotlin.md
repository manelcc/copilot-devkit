# US-062 — Migrar instrucciones backend Kotlin

**Como** desarrollador Ktor en cualquier proyecto,
**quiero** que `instructions/backend-kotlin.instructions.md` contenga las reglas de `copilot-instructions.md` de mycardiochef,
**para** que Copilot genere código Ktor de calidad sin configuración adicional.

---

## Requerimientos de inicio

| ID | Requerimiento | Estado | Tipo | Nota |
|---|---|---|---|---|
| RQ-001 | Acceso a `mycardiochef/.github/copilot-instructions.md` | Necesario | Funcional | Fuente de migración |
| RQ-002 | Estructura `instructions/` creada | Necesario | Arquitectura | Parte de US-001 |
| RQ-003 | Se definió el estándar de `applyTo` para Kotlin | Necesario | Calidad | Alineado con DoD |

---

## Criterios de Aceptación

1. El archivo `instructions/backend-kotlin.instructions.md` existe y tiene `applyTo: "**/*.kt"`.
2. Incluye reglas para: estructura Ktor, HMAC auth, Flyway, Coroutines, documentación Kotlin.
3. Referencia las skills de `backend/kotlin-ktor/` para tareas específicas.
4. No contiene referencias a `mycardiochef`, rutas absolutas o campos específicos de proyecto origen.
5. El archivo es válido según el parser de instrucciones del repositorio (YAML/Markdown parseable).

---

## Referencias

- `MC:.github/copilot-instructions.md`
- `MC:.github/copilot-kotlin-server-rules.md`
- `MC:.github/copilot-hmac-auth.md`

---

## Dependencias y restricciones

- Dependencias: US-001, US-005, US-061
- Restricciones: Mantener solo reglas genéricas de backend Kotlin; las políticas específicas de seguridad se documentan como supuestos.

---

## Validación INVEST

| Criterio | ✅ / ⚠️ | Observación |
|---|---|---|
| Independiente | ✅ | Se puede completar sin migrar skills adicionales |
| Negociable | ✅ | Las reglas exactas pueden ajustarse según el estilo del stack |
| Valiosa | ✅ | Asegura generación de código Ktor consistente y de calidad |
| Estimable | ✅ | Alcance acotado a un archivo de instrucciones |
| Small | ✅ | Único artefacto con criterios claros |
| Testeable | ✅ | CA verificables con parseo e inspección de contenido |
