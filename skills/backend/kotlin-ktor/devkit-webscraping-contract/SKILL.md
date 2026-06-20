---
name: devkit-webscraping-contract
description: "Contrato operativo entre middleware y web-scraping, incluyendo seguridad HMAC v1 y checklist de validacion end-to-end."
applyTo:
  - "src/**/*.kt"
  - "docs/**/*.md"
triggers:
  - "hmac auth between services"
  - "webscraping contract"
  - "service to service signing"
  - "x-signature"
  - "internal auth"
non_triggers:
  - "auth de usuarios finales"
  - "ui frontend"
  - "configuración de pipelines"
---

# Skill: Middleware <-> Web-Scraping Contract

## Goal
Definir y aplicar el contrato tecnico entre `middleware` (sender) y `web-scraping` (receiver), con protocolo de seguridad interna HMAC-SHA256 `v1` obligatorio.

## Mandatory source of truth
Usar siempre estas referencias como contrato fuente:
- `.github/copilot-hmac-auth.md`
- `docs/guides/SERVICE_TO_SERVICE_SIGNING.md`
- `src/main/kotlin/<org>/<project>/infrastructure/client/ScrapingServiceClient.kt`
- `src/main/kotlin/<org>/<project>/core/di/KoinModules.kt`

Si hay conflicto entre implementacion local y protocolo `v1`, priorizar `v1` y explicar riesgo de compatibilidad.

## Service roles
- `middleware`: sender (firma requests salientes).
- `web-scraping`: receiver (valida firma entrante).

## Runtime endpoint contract
- Endpoint interno por defecto: `http://web-scraping:5004/api/v1/scrape`
- Metodo: `POST`
- Request body JSON:

```json
{
  "url": "https://example.com/recipe"
}
```

## Transport and tracing headers
Headers funcionales del flujo:
- `X-Request-ID` (trazabilidad)
- `X-Correlation-ID` (trazabilidad cross-service)

Headers de autenticacion obligatorios (`v1`):
- `X-Service-Id`
- `X-Timestamp`
- `X-Signature`
- `X-Signature-Version: v1`
- `X-Key-Id`

## Security contract (HMAC v1)
Decisiones fijas:
- Algorithm: `HmacSHA256`
- Signature encoding: `Base64`
- Timestamp: epoch seconds UTC
- Recommended skew: `+/- 300s`
- Signature version: `v1`

Canonical string (`v1`):

```text
METHOD\n
PATH_AND_QUERY\n
BODY_SHA256\n
TIMESTAMP\n
SERVICE_ID
```

Reglas:
- `METHOD` en uppercase.
- Query params ordenados por key y luego value.
- `BODY_SHA256` sobre bytes exactos del body.
- Empty body hash:
  `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`

## Middleware implementation contract
Configuracion sender requerida:
- `INTERNAL_AUTH_SERVICE_ID`
- `INTERNAL_AUTH_KEY_ID`
- `INTERNAL_AUTH_SECRET`
- `INTERNAL_AUTH_ALLOWED_SKEW_SECONDS` (recomendado: `300`)

Reglas de implementacion:
- Instalar `InternalAuthClientPlugin` en `HttpClient` compartido (DI), no crear clientes ad-hoc.
- Enviar body como `String` JSON real para que la firma use bytes exactos.
- No setear manualmente headers de auth en interceptors/request builders.
- Sanitizar en logs cualquier header/token/secret/signature/key.

## Functional response contract from web-scraping
Campos esperados de respuesta:
- `url`
- `strategy_used`
- `title`
- `ingredients[]`
- `instructions[]`
- Opcionales: `description`, `servings`, `prepTimeMinutes`, `cookTimeMinutes`, `totalTimeMinutes`, `difficulty`, `cuisineType`, `mealType`, `imageUrl`, `language`, `raw_content`

Mapeo de error relevante:
- HTTP `422` con `error|code = NOT_A_RECIPE` -> mapear a error funcional de dominio.
- HTTP no exitoso distinto de `422` -> error tecnico de integracion.

## Compatibility and migration rules
- Prohibido proponer variantes de headers, canonicalizacion o algoritmo fuera de `v1` sin RFC aprobado.
- Migracion obligatoria: reemplazar firma manual por `InternalAuthClientPlugin`.
- Rotacion de claves:
1. Crear nueva clave y nuevo `keyId`.
2. Distribuir clave a sender/receiver.
3. Cambiar sender al nuevo `keyId`.
4. Mantener overlap de claves en receiver.
5. Retirar clave vieja en fecha de corte.

## QA checklist (minimum)
1. Cada request saliente a `/api/v1/scrape` incluye los 5 headers de auth.
2. `X-Signature-Version` es siempre `v1`.
3. Request con body JSON firma correctamente.
4. Request sin body conserva firma valida (hash de body vacio).
5. Secretos no aparecen en logs.
6. Receiver con secreto incorrecto responde `401`.
7. Con `X-Request-ID` y `X-Correlation-ID` fijos se puede trazar el flujo end-to-end en ambos servicios.

## Troubleshooting quick map
- `MISSING_HEADERS` -> faltan headers de auth requeridos.
- `UNSUPPORTED_SIGNATURE_VERSION` -> version distinta de `v1`.
- `INVALID_TIMESTAMP` -> timestamp invalido/no parseable.
- `TOKEN_EXPIRED` -> reloj desincronizado o skew insuficiente.
- `INVALID_SIGNATURE` -> body firmado distinto del body enviado.
- `UNKNOWN_SERVICE_ID` -> sender no registrado.
- `UNKNOWN_KEY_ID` -> key id no registrado para el sender.

HTTP mapping sugerido:
- `400`: `MISSING_HEADERS`, `UNSUPPORTED_SIGNATURE_VERSION`, `INVALID_TIMESTAMP`
- `401`: `TOKEN_EXPIRED`, `INVALID_SIGNATURE`, `UNKNOWN_SERVICE_ID`, `UNKNOWN_KEY_ID`

## Expected outputs when applying this skill
- Contrato de conexion middleware<->web-scraping documentado en texto y checklist.
- Configuracion de variables de entorno y DI validada.
- Evidencia de trazabilidad y firma `v1` en pruebas/integracion.
## Purpose
Provide reusable guidance for this backend Kotlin/Ktor capability.

## When to use
- Use this skill when the request matches this skill domain.

## When NOT to use
- Do not use this skill for unrelated domains.

## Inputs
- Current repository context
- User requirement and expected outcome

## Steps
1. Identify the scope and impacted files.
2. Apply the recommended implementation pattern.
3. Validate with project checks and conventions.

## Expected outputs
- Updated files aligned with this skill guidelines.

## Validation
- Skill structure and frontmatter are valid.
- Changes are consistent with repository standards.

## Examples
- Example request: "apply this skill workflow to implement the requested change".
