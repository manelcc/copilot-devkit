# Creational Patterns (Reference)

Source lineage:
- /Users/manelcc/Documents/BANKINTER/apps-ios/appmovil-nbo-ios/.github/skills/ios-patterns/CREATIONAL-PATTERNS.md

## Intent
Controlar creacion de objetos para mejorar testabilidad, extensibilidad y control de dependencias.

## Core patterns
- Singleton: unica instancia global (uso restringido).
- Factory Method: creacion sin acoplar al tipo concreto.
- Abstract Factory: familias de objetos relacionados.
- Builder: construccion paso a paso de objetos complejos.
- Prototype: clonacion eficiente.
- Lazy Initialization: creacion bajo demanda.
- Dependency Injection: dependencias desde fuera del objeto.

## Selection cues
- Sustituir implementaciones facilmente: Factory/Abstract Factory.
- Constructor con demasiados parametros: Builder.
- Dependencias ocultas y test dificil: aplicar DI.
- Coste alto de inicializacion: Lazy Initialization.

## Anti-pattern watch
- Singleton abuse con estado mutable global.
- Factories excesivas para casos simples.
- DI incompleta que deja dependencias hardcodeadas.

## Notes for this repo
DI es la opcion por defecto; Singleton solo con justificacion y alcance controlado.
