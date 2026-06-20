# Swift-Specific Patterns (Reference)

Source lineage:
- /Users/manelcc/Documents/BANKINTER/apps-ios/appmovil-nbo-ios/.github/skills/ios-patterns/SWIFT-PATTERNS.md

## Intent
Aplicar patrones que aprovechan capacidades propias del lenguaje Swift.

## Core patterns
- Identifier / Phantom Types: IDs type-safe sin coste runtime.
- Value Binding: desempaquetado seguro de optionals y patrones.
- Wildcard: ignorar valores de forma explicita.
- Property Wrappers: comportamiento transversal reutilizable.
- Result Builders: DSL declarativa para composicion.
- Opaque Types (`some`): exponer capacidades sin revelar tipo concreto.

## Selection cues
- Riesgo de mezclar IDs de dominios: Identifier.
- Mucho boilerplate de validacion repetido: Property Wrappers.
- API publica que no debe filtrar implementacion: Opaque Types.

## Anti-pattern watch
- Any y type erasure por defecto sin necesidad.
- Uso excesivo de wrappers para logica que deberia vivir en dominio.

## Notes for this repo
Aprovechar estas tecnicas para reforzar type-safety y legibilidad en planning e implementacion.
