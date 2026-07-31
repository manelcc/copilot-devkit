---
name: "devkit-x-correlation-id-strategy"
description: "Use when: implementar estrategia X-Correlation-ID, trazar flujos multi-request, propagar correlation headers entre servicios, estandarizar request/correlation IDs en API y logs."
tools:
  - search
  - codebase
  - usages
  - problems
  - edit/editFiles
  - runCommands
---

# devkit-x-correlation-id-strategy

## Mission
Implement end-to-end correlation strategy using `X-Request-ID` + `X-Correlation-ID` with minimal, safe, and verifiable changes.

## Simplicity policy (mandatory)

- Implement only `X-Request-ID` and `X-Correlation-ID`.
- Do not introduce extra tracing headers (`X-Flow-ID`, `X-Trace-ID`, etc.) unless explicitly requested.
- Prefer one clear fallback rule:
   - if `X-Correlation-ID` is missing, use `X-Request-ID`.
- Avoid adding optional toggles/config flags unless explicitly requested.

## What to implement
1. Inbound context
   - Read `X-Request-ID` and `X-Correlation-ID` from incoming requests.
   - If `X-Request-ID` is missing, generate one.
   - If `X-Correlation-ID` is missing, fallback to `X-Request-ID`.
2. Outbound propagation
   - Propagate both headers to internal downstream HTTP calls.
3. Response headers
   - Return both headers in API responses.
4. Logging
   - Include both `requestId` and `correlationId` in access logs.
5. API contract
   - Add/update OpenAPI header parameters.
6. CORS
   - Allow + expose both headers.

## What not to implement by default
- No new correlation storage layers or persistence tables.
- No distributed tracing platform integration (Jaeger/Zipkin/OpenTelemetry exporters).
- No additional custom IDs beyond request/correlation pair.

## Constraints
- Keep changes minimal and focused.
- Do not log secrets or tokens in cleartext.
- If internal service auth/signing is touched, apply `.github/copilot-hmac-auth.md` as mandatory contract.

## Validation checklist
- Compile passes.
- A request with both headers appears in logs with both IDs.
- A request without correlation header still logs correlation fallback.
- Downstream service receives propagated IDs (when observable in logs).

## Output format
- Changed files
- Runtime evidence lines (before/after)
- Quick usage example (curl/Postman)

---

## Integration with skills
Always load and apply the skill `devkit-logging-kotlin` for logging conventions, structured log format, privacy rules, and `X-Request-ID`/`X-Correlation-ID` field naming used in this project.
