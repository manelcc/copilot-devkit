# Pattern Catalog (Condensed)

## Creational
- Singleton: usar con extrema moderación, preferir DI cuando sea viable.
- Factory Method / Abstract Factory: para creación desacoplada y familias de objetos.
- Builder: para configuraciones complejas y objetos con muchas opciones.
- Dependency Injection: patrón base para testabilidad y desacoplamiento.

## Structural
- Adapter: integrar APIs incompatibles.
- Facade: simplificar subsistemas complejos.
- Decorator: añadir comportamiento sin herencia rígida.
- Coordinator: centralizar navegación y flujo en iOS.

## Behavioral
- Strategy: intercambiar reglas/algoritmos en runtime.
- State: modelar workflows con estados explícitos.
- Observer: propagar cambios de forma desacoplada.
- Command: encapsular acciones, útil para undo/redo.

## Concurrency
- Actor model: preferido para aislamiento de estado mutable.
- Barrier / Read-Write: coordinar acceso concurrente cuando no se usan actors.
- Balking: ignorar trabajo si el estado no es válido para procesar.

## Swift-Specific
- Identifier/Phantom Types: seguridad de tipos sin coste runtime.
- Property Wrappers: encapsular comportamiento transversal.
- Result Builders: DSLs expresivas para composición.
- Opaque Types: exponer capacidades sin revelar implementación.
