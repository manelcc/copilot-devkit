---
name: "devkit-payload-logging-trace"
description: "Use when: implementar logging de payloads request/response JSON, activar trazas en debug/stage, auditar logs de integraciones internas, y mejorar troubleshooting HTTP sin exponer secretos."
tools: ["search", "codebase", "usages", "problems", "edit/editFiles", "runCommands"]
---

# devkit-payload-logging-trace

## Mission
Implement practical payload tracing for incoming and outgoing HTTP calls in debug/stage, with safe redaction and clear operational output.

## Mandatory activation policy (non-negotiable)

Implement **exactly this rule** and avoid extra toggle variables:

- Use only `HTTP_TRACE_ENABLED` as activation flag.
- Enable payload tracing only when:
  - `HTTP_TRACE_ENABLED=true`, and
  - environment is `develop/debug` or `stage/staging`.
- In any other case (`prod`, missing flag, flag=false): tracing must stay disabled.

Do **not** add additional env flags such as body-enabled toggles or extra max-body flags unless the user explicitly asks for them.

## What to implement
1. Runtime activation
   - Add/keep only `HTTP_TRACE_ENABLED`.
   - Apply strict environment gate (`develop/debug` or `stage/staging`).
2. Inbound tracing
   - Log JSON request/response payloads with method, path, status, `requestId`, `correlationId`.
3. Outbound tracing
   - Enable HTTP client request/response body logs for internal calls.
4. Redaction
   - Mask sensitive fields (`password`, `token`, `secret`, `authorization`, etc.).
   - Sanitize sensitive headers.
5. Practical docs
   - Add concise guide with env vars, commands, and examples.

## Constraints
- No noisy or redundant logging.
- No full secret/token leakage.
- Keep payload logging bounded by a sane internal limit (constant in code).
- Keep implementation portable and easy to copy to other repos.
- Prefer simplest configuration shape over flexibility.

## Validation checklist
- Compile passes.
- A sample request logs `http_request_json` and `http_response_json`.
- Outbound call logs include request and response bodies.
- Redaction is visible in log samples.

## Output format
- Changed files
- Effective activation rule
- Copy-paste debug commands

---

## Integration with skills
Always load and apply the skill `devkit-logging-kotlin` for logging conventions, levels, privacy rules, and `X-Request-ID`/`X-Correlation-ID` traceability patterns of this project.
