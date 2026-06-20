# Anti-patterns Checklist (Python)

## CRITICAL
- Secretos hardcodeados en código fuente.
- SQL injection por concatenación de strings.
- Importaciones circulares entre capas.
- Lógica de dominio mezclada con infraestructura.

## HIGH
- God object con responsabilidades mezcladas.
- Catch-all `except Exception` que oculta fallos.
- Estado global mutable sin scope.
- Ausencia de typing en interfaces públicas.
- `time.sleep` en código async.

## MEDIUM
- Funciones >50 líneas sin justificación.
- Módulos sin tests unitarios.
- `Any` en interfaces cuando Protocol bastaría.
- Singleton manual en lugar de DI.

## LOW
- Magic numbers sin constantes.
- Imports no usados.
- Docstrings incompletos en módulos críticos.

## Quick scoring
- 0-1 CRITICAL: riesgo controlado.
- 2+ CRITICAL: refactor prioritario antes de release.
- 3+ HIGH: plan de remediación en 30 días.
