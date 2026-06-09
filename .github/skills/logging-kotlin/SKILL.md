---
name: logging-kotlin
description: "Convencion de logging Kotlin/Ktor del middleware. Usar cuando: anadir logs a una clase nueva, depurar con trazabilidad X-Request-ID/X-Correlation-ID, activar trazas HTTP en debug/stage, cambiar implementacion de logging, revisar buenas practicas de niveles, privacidad o lazy evaluation."
---

# Skill: Logging Kotlin — Middleware MyCardioChef

## Fuentes de verdad obligatorias

- `src/main/kotlin/es/mycardiochef/middleware/core/logging/Logging.kt`
- `src/main/resources/logback.xml`
- `docs/guides/LOGGING.md`
- `docs/guides/LOGGING_PRACTICO_X_REQUEST_Y_CORRELATION.md`
- `docs/guides/LOGGING_MIGRATION_EXAMPLE.md`

## Arquitectura del sistema de logging

Capas (de mayor a menor abstraccion):

```
Application Code
    └── Logger interface  (abstraccion — nunca romper)
        └── LoggerFactory.create(name)
            └── KotlinLoggingAdapter
                └── kotlin-logging (SLF4J wrapper)
                    └── Logback (implementacion final)
```

Ficheros clave:
- `Logging.kt` — unico fichero a modificar para cambiar libreria.
- `logback.xml` — niveles y patrones por paquete.

## Como usar logging en el codigo

### En cualquier clase (extension property — forma preferida)

```kotlin
class MyService {
    fun process() {
        logger.info { "procesando" }
        logger.debug { "detalle: $value" }
        logger.error(e) { "fallo al procesar: ${e.message}" }
    }
}
```

### En funciones top-level o use cases sin clase (loggerFor)

```kotlin
private val log = loggerFor("NombreComponente")

fun myFunction() {
    log.info { "ejecutando" }
}
```

### En extension functions de Application

```kotlin
fun Application.configurePlugin() {
    logger.info { "Plugin configurado" }
}
```

## Niveles — regla operativa

| Nivel   | Cuando usarlo |
|---------|---------------|
| `trace` | Detalle extremo; solo en desarrollo local |
| `debug` | Informacion util para depuracion |
| `info`  | Eventos de negocio relevantes (arranque, fin de operacion, estado) |
| `warn`  | Situacion anomala pero recuperable (fallback activado, ratio bajo, timeout parcial) |
| `error` | Error que requiere atencion; siempre pasar la excepcion como primer argumento |

Regla de excepcion obligatoria:

```kotlin
// Correcto
logger.error(e) { "fallo en enriquecimiento ingrediente='$name'" }

// Incorrecto — se pierde el stack trace
logger.error { "fallo: ${e.message}" }
```

## Lazy evaluation — regla obligatoria

Usar siempre lambdas `{ }`, nunca interpolacion directa como argumento:

```kotlin
// Correcto — solo evalua si INFO esta habilitado
logger.info { "ratio=${"%.2f".format(ratio)} total=$total" }

// Incorrecto — evalua siempre aunque el nivel este desactivado
logger.info("ratio=${ratio} total=${total}")
```

## Trazabilidad: X-Request-ID y X-Correlation-ID

### Comportamiento del middleware

- Lee `X-Request-ID` de la cabecera de entrada; si no existe, genera un UUID.
- Lee `X-Correlation-ID`; si no existe, usa el `X-Request-ID` como fallback.
- Devuelve ambos en cabeceras de respuesta.
- Los propaga a servicios internos (ej. `web-scraping`) via headers `X-Request-ID` / `X-Correlation-ID`.

### Regla de uso en Postman / pruebas

- Una unica peticion: envia `X-Request-ID` fijo para poder filtrar logs.
- Un flujo completo (login + profile + recetas): envia mismo `X-Correlation-ID` en todas las peticiones.

### Comandos de investigacion rapida

```bash
# Filtrar por request ID concreto
docker compose --env-file .env.local logs --since=30m middleware | grep -F 'mi-request-id-001'

# Filtrar todo un flujo
docker compose --env-file .env.local logs --since=30m middleware | grep -F 'mi-correlation-id'

# Ver llamadas salientes HTTP (ej. a web-scraping)
docker compose --env-file .env.local logs --since=30m middleware | grep -Ei 'MCP-HTTP-Client|web-scraping'
```

## Trazas HTTP (request/response body)

### Cuándo se activan

| Entorno | Activo por defecto | Override |
|---------|--------------------|----------|
| `KTOR_DEVELOPMENT=true` | Si | `HTTP_TRACE_ENABLED=false` para desactivar |
| `APP_ENV=stage\|staging` | Si | `HTTP_TRACE_ENABLED=false` para desactivar |
| produccion | No | `HTTP_TRACE_ENABLED=true` (no recomendado) |

Variable de activacion explicita:

```env
HTTP_TRACE_ENABLED=true
```

### Que incluye la traza

- Linea de acceso: metodo, path, status, `requestId`.
- Body JSON de request y response (sanitizado).
- Payload de llamadas salientes del cliente HTTP interno.

### Campos sensibles enmascarados automaticamente

`password`, `accessToken`, `refreshToken`, `token`, `secret`, `signature`, `authorization`

Headers del cliente HTTP sanitizados:
`Authorization`, `Cookie`, `*token*`, `*secret*`, `*signature*`, `*key*`

**Regla**: no anadir datos sensibles a payloads de prueba aunque el sistema los enmascare.

## Configuracion en logback.xml

Ubicacion: `src/main/resources/logback.xml`

Patron actual:

```xml
<pattern>%d{YYYY-MM-dd HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n</pattern>
```

Loggers por paquete definidos:

```xml
<logger name="com.mycardiochef" level="DEBUG"/>
<logger name="io.ktor"          level="INFO"/>
<logger name="io.modelcontextprotocol" level="DEBUG"/>
```

Para anadir un nuevo paquete con nivel especifico:

```xml
<logger name="es.mycardiochef.middleware.infrastructure.client" level="DEBUG"/>
```

## Cambio de libreria de logging

Solo hay que modificar `Logging.kt` — ningun otro fichero cambia.

Pasos:
1. Crear nuevo adapter que implemente `Logger` interface.
2. Actualizar `LoggerFactory.create(name)` para instanciar el nuevo adapter.
3. Actualizar dependencias en `build.gradle.kts`.
4. Crear/actualizar fichero de configuracion de la nueva libreria.

El codigo de aplicacion (clases, use cases, plugins) no requiere ningun cambio.

Ver ejemplo completo: `docs/guides/LOGGING_MIGRATION_EXAMPLE.md`.

## Checklist al anadir logging a codigo nuevo

- [ ] Usar `logger` (extension property) en clases, `loggerFor("Nombre")` en top-level.
- [ ] Usar siempre lambdas `{ }` para lazy evaluation.
- [ ] Nivel `error` incluye la excepcion como primer parametro.
- [ ] Mensajes de `info`/`warn` incluyen contexto identificable (`requestId`, nombre ingrediente, etc.).
- [ ] No se loguean tokens, passwords ni secretos en claro.
- [ ] Si el componente es invocado desde un use case que tiene `requestId`, incluirlo en los mensajes relevantes.

## Antipatrones a evitar

```kotlin
// MAL — interpolacion directa fuera de lambda
logger.info("procesando $id con $data")

// MAL — excepcion no incluida en error
logger.error { "fallo: ${e.message}" }

// MAL — nivel incorrecto para evento de negocio normal
logger.debug { "usuario autenticado exitosamente" }  // deberia ser info

// MAL — log de secreto aunque sea parcial
logger.info { "token=${token.take(10)}..." }
```
