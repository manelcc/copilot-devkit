# Behavioral Patterns (Reference)

Source lineage:
- /Users/manelcc/Documents/BANKINTER/apps-ios/appmovil-nbo-ios/.github/skills/ios-patterns/BEHAVIORAL-PATTERNS.md

## Intent
Definir como colaboran objetos y como se distribuyen responsabilidades sin acoplamiento excesivo.

## Core patterns
- Observer: notificacion uno-a-muchos para cambios de estado.
- Strategy: intercambio de algoritmos en runtime.
- State: comportamiento dependiente del estado interno.
- Command: encapsular acciones para cola, logging, undo/redo.
- Mediator: reducir dependencias directas entre componentes.
- Iterator: recorrer colecciones sin exponer estructura interna.
- Chain of Responsibility: resolver peticiones por cadena de handlers.

## Selection cues
- Multiples listeners necesitan reaccionar: Observer.
- Reglas de negocio intercambiables: Strategy.
- Flujo por estados bien definidos: State.
- Acciones auditables/reversibles: Command.
- Demasiadas referencias cruzadas entre objetos: Mediator.

## Anti-pattern watch
- Observer sin limpieza de suscripciones (fugas).
- Strategy para casos triviales (sobreingenieria).
- State con transiciones no centralizadas.
- Cadenas de handlers opacas y sin trazabilidad.

## Notes for this repo
Para planning o review, siempre documentar:
1. Patron candidato.
2. Patron finalmente aplicado.
3. Antipatrones encontrados y severidad.
