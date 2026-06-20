# Structural Patterns (Reference)

Source lineage:
- /Users/manelcc/Documents/BANKINTER/apps-ios/appmovil-nbo-ios/.github/skills/ios-patterns/STRUCTURAL-PATTERNS.md

## Intent
Componer objetos y capas para aislar complejidad y reducir acoplamiento.

## Core patterns
- Adapter: compatibilizar interfaces incompatibles.
- Decorator: ampliar comportamiento sin herencia rigida.
- Facade: interfaz simple a subsistemas complejos.
- Proxy: control de acceso, lazy loading o cache.
- Delegate / Multicast Delegate: delegacion uno-a-uno o uno-a-muchos.
- Type Erasure: ocultar tipos concretos conservando contrato.
- Coordinator: centralizar navegacion y flujos.

## Selection cues
- Integracion de SDK legado: Adapter o Facade.
- Navegacion compleja de multiples pantallas: Coordinator.
- Necesidad de comportamiento opcional combinable: Decorator.

## Anti-pattern watch
- Coordinator sobredimensionado (god coordinator).
- Type Erasure prematuro sin beneficio real.
- Delegate con ownership no claro (retention issues).

## Notes for this repo
En SwiftUI, priorizar Coordinator cuando la navegacion supere flows lineales simples.
