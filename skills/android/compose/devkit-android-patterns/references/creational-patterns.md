# Creational Patterns (Reference - Android/Kotlin)

Source lineage:
- /Users/manelcc/Library/CloudStorage/OneDrive-SopraSteria/mac/KMP_APPS/PRUEBA-TECNICA/ANDROID/.github/skills/android-patterns/CREATIONAL-PATTERNS.md

## Core patterns
- **Singleton**: instancia única. En Android: object Kotlin, o mejor: Hilt @Singleton.
- **Factory Method**: creación desacoplada del tipo concreto.
- **Abstract Factory**: familias de objetos relacionados (ej. themes, adapters por plataforma).
- **Builder/DSL**: construccion fluida de objetos complejos. En Kotlin: @DslMarker + lambdas.
- **Dependency Injection**: inyección desde fuera. En Android: Hilt como primera opción.

## Selection cues
- Crear objetos sin acoplar al tipo concreto: Factory.
- Objetos con muchos parámetros opcionales: Builder/DSL.
- Gestión de dependencias de forma escalable: Hilt DI.

## Anti-pattern watch
- Singleton con estado global mutable (riesgo CRITICAL).
- Constructores con más de 4-5 parámetros sin Builder.
- DI manual en lugar de Hilt cuando el proyecto escala.

## Android notes
- Hilt como estándar de DI en Android (no Koin excepto en proyectos KMP).
- Evitar ServiceLocator: oculta dependencias y dificulta test.
