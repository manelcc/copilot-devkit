# Anti-patterns Checklist (Android/Kotlin)

## CRITICAL
- Singleton con estado global mutable.
- GlobalScope / runBlocking en main thread.
- Acceso directo a datos desde UI sin Repository.

## HIGH
- God ViewModel (>300 líneas, responsabilidades mezcladas).
- Side effects en UseCase o Repository.
- Coroutines sin cancelación ni scope controlado.
- Acoplamiento de capas en dirección incorrecta.

## MEDIUM
- LiveData en nuevos proyectos en vez de StateFlow.
- Colecciones mutables cruzando límites de capa.
- Falta de manejo de error explícito en flows.

## LOW
- Magic numbers sin constantes nombradas.
- Tests con dependencias reales de red o BD.

## Quick scoring
- 0-1 CRITICAL: riesgo controlado, plan de remediación en sprint.
- 2+ CRITICAL: refactor prioritario, no avanzar feature.
- 3+ HIGH: deuda técnica acumulada, plan 30 días.
