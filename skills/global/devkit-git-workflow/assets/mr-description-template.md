# Merge Request — Plantilla de Descripción

> Instrucciones para Copilot: rellena cada sección con la información extraída de los commits y los cambios del diff. Elimina las líneas de guía (entre `>`) antes de presentar al usuario.

---

## ¿Qué hace este MR?

> Resumen ejecutivo en 2-4 frases. Qué funcionalidad se añade, qué bug se corrige o qué mejora se introduce. Escrito para alguien que no conoce el detalle técnico.

_Ejemplo: Añade el cliente HTTP `JsoupRecipeClient` que permite obtener y parsear recetas desde URLs externas. Incluye manejo de timeout configurable y reintentos antes de delegar al cliente mock de fallback._

---

## Motivación / Problema resuelto

> Por qué era necesario este cambio. Referencia a issue, bug report, requerimiento de producto o deuda técnica.

- Resuelve: <!-- #issue o descripción del problema -->
- Contexto: <!-- Por qué ahora, por qué así -->

---

## Cambios técnicos

> Descripción del enfoque técnico. Qué se creó, qué se modificó, qué se eliminó. Listar los archivos clave o decisiones de diseño relevantes.

### Archivos principales
| Archivo | Tipo de cambio | Descripción |
|---------|---------------|-------------|
| `src/...` | Nuevo / Modificado / Eliminado | Qué hace este archivo en el contexto del MR |

### Decisiones de diseño
- <!-- Decisión 1: por qué se eligió este enfoque vs alternativa -->
- <!-- Decisión 2: trade-offs considerados -->

---

## Testing

> Qué se probó, cómo y con qué resultado.

- **Tests unitarios**: <!-- qué casos cubre, clase de test -->
- **Tests de integración**: <!-- qué escenarios, fixtures usados -->
- **Cobertura**: <!-- impacto en cobertura, si bajó explicar por qué es aceptable -->
- **Prueba manual** (si aplica): <!-- pasos seguidos, resultado esperado -->

---

## Checklist de validación pre-merge

- [ ] `./gradlew build` — sin errores
  - [ ] Warnings evaluados y documentados (si los hay)
- [ ] `./gradlew test` — todos los tests en verde
- [ ] `./scripts/code_review_local.sh` — sin errores críticos
  - [ ] Warnings de review resueltos o justificados
- [ ] Variables de entorno nuevas subidas a GitLab CI/CD (si aplica)
- [ ] Documentación actualizada (si aplica)
- [ ] No contiene cambios no relacionados con el objetivo del MR

---

## Breaking changes

> Indicar si hay cambios incompatibles con versiones anteriores. Si no hay, dejarlo vacío o escribir "Ninguno".

<!-- Ninguno | Descripción del breaking change y cómo migrar -->

---

## Notas para el revisor

> Información adicional que facilite la revisión: áreas de riesgo, alternativas descartadas, contexto de decisiones no obvias.

<!-- Opcional: qué mirar con más cuidado, contexto de decisiones difíciles -->
