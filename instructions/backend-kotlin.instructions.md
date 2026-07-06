---
applyTo: "**/*.kt"
---

# Backend Kotlin/Ktor Instructions

Estas instrucciones aplican a proyectos backend Kotlin/Ktor y priorizan reglas reutilizables, agnosticas al producto.

## 1. Estructura Ktor (Application y routing)

- La funcion `Application.module()` debe orquestar y delegar en funciones de configuracion:
  - `configureSerialization()`
  - `configureSecurity()`
  - `configureMonitoring()`
  - `configureRouting()`
- Evita configurar plugins y rutas complejas inline dentro de `module()`.
- Las rutas no contienen logica de negocio ni acceso directo a repositorios/DB.
- Cada endpoint delega en use cases o servicios de aplicacion y responde DTOs.
- El manejo de errores se centraliza con `StatusPages`.

## 2. HMAC auth interna (protocolo v1)

- Para comunicacion interna firmada, mantener protocolo HMAC-SHA256 version `v1`.
- No proponer variaciones de algoritmo, headers o canonicalizacion sin RFC.
- Cliente (sender): firma requests salientes en un plugin/interceptor dedicado.
- Servidor (receiver): valida firma y skew temporal en middleware/plugin dedicado.
- Variables esperadas por entorno:
  - `INTERNAL_AUTH_SERVICE_ID`
  - `INTERNAL_AUTH_KEY_ID`
  - `INTERNAL_AUTH_SECRET`
  - `INTERNAL_AUTH_ALLOWED_SKEW_SECONDS`
- Nunca hardcodear secretos; usar variables de entorno o secret manager.

## 3. Flyway migrations

- Todas las mutaciones de esquema deben ir en migraciones versionadas (`Vxxx__*.sql`).
- No proponer crear tablas manualmente si existe migracion Flyway para ese cambio.
- Startup:
  - En entornos no productivos puede permitirse desactivar migraciones automaticas.
  - En CI/CD y entornos persistentes, las migraciones deben ejecutarse de forma controlada.
- Antes de desplegar cambios con DB:
  - validar orden de versionado,
  - validar idempotencia,
  - verificar `flyway_schema_history`.

## 4. Coroutines en servidor

- Toda operacion IO bloqueante (DB, HTTP, filesystem) se ejecuta en `Dispatchers.IO`.
- No atrapar `CancellationException` como error generico; si se captura, relanzarla.
- Aplicar `withTimeout` o `withTimeoutOrNull` en llamadas externas susceptibles de colgarse.
- Evitar `GlobalScope`; usar structured concurrency con scopes acotados al ciclo de vida.
- Mantener limites claros entre capa web, aplicacion y acceso a datos para mejorar testabilidad.

## 5. Documentacion Kotlin

- Todo elemento publico relevante debe incluir KDoc.
- Estructura minima recomendada:
  - descripcion corta,
  - contexto funcional,
  - `@param` para entradas,
  - `@return` cuando aplique,
  - ejemplo breve en casos no triviales.
- Priorizar documentar contratos y efectos secundarios frente a detalles obvios.

## 6. Skills de referencia (backend/kotlin-ktor)

- `skills/backend/kotlin-ktor/devkit-kotlin-mcp-server-generator/`
- `skills/backend/kotlin-ktor/devkit-logging-kotlin/`
- `skills/backend/kotlin-ktor/devkit-unit-testing-kotlin/`
- `skills/backend/kotlin-ktor/devkit-postgresql-crud/`
- `skills/backend/kotlin-ktor/devkit-ktor-auth-flow/`
- `skills/backend/kotlin-ktor/devkit-webscraping-contract/`

## 7. Checklist rapido antes de commit

- `Application.module()` limpia y delegada.
- Rutas sin logica de negocio.
- Cambios de DB cubiertos por Flyway.
- Coroutines sin bloqueos ni anti-patrones de cancelacion.
- KDoc actualizado en piezas publicas nuevas o modificadas.
- Sin secretos embebidos en codigo ni en ficheros versionados.
