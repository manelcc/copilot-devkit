# Concurrency Patterns (Reference)

Source lineage:
- /Users/manelcc/Documents/BANKINTER/apps-ios/appmovil-nbo-ios/.github/skills/ios-patterns/CONCURRENCY-PATTERNS.md

## Intent
Asegurar thread-safety y consistencia de estado en ejecucion concurrente.

## Core patterns
- Actor model: aislamiento de estado mutable.
- Barrier: sincronizacion en puntos de coordinacion.
- Read-Write Lock: multiples lecturas y escritura exclusiva.
- Balking: ignorar trabajo cuando el estado no es valido.
- async/await orchestration: concurrencia estructurada.

## Selection cues
- Estado compartido mutable: Actor como opcion preferida.
- Carga con muchas lecturas y pocas escrituras: Read-Write.
- Fases paralelas con punto de union: Barrier.

## Anti-pattern watch
- Callback hell mezclado con async/await.
- Mutaciones UI fuera de main actor.
- Locking excesivo sin medir contencion real.

## Notes for this repo
Prioridad: soluciones con Swift Concurrency moderna antes que locks manuales.
