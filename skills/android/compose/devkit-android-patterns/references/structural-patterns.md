# Structural Patterns (Reference - Android/Kotlin)

Source lineage:
- /Users/manelcc/Library/CloudStorage/OneDrive-SopraSteria/mac/KMP_APPS/PRUEBA-TECNICA/ANDROID/.github/skills/android-patterns/STRUCTURAL-PATTERNS.md

## Core patterns
- **Adapter**: compatibilizar interfaces. En Android: adaptar DTOs a domain models.
- **Decorator**: ampliar comportamiento sin herencia. En Kotlin: extension functions o wrappers.
- **Facade**: simplificar subsistemas complejos. Ej: NetworkFacade sobre Retrofit.
- **Proxy**: control de acceso, cache, logging transparente.
- **Composite**: estructuras en árbol. En Android: navigation graphs, jerarquías de vistas.
- **Bridge**: desacoplar abstracción de implementación. Ej: repositorio abstracto + impls.

## Selection cues
- Integracion de SDK externo: Adapter + Facade.
- Repository con múltiples fuentes de datos: Bridge.
- Logging/monitoring transparente sobre API: Proxy (ej. OkHttp interceptor).

## Anti-pattern watch
- Facade que expone demasiado (god facade).
- Adapter sin interfaz objetivo bien definida.
- Herencia profunda donde Decorator bastaría.
