# Structural Patterns (Reference - Python)

Source lineage:
- /Users/manelcc/Library/CloudStorage/OneDrive-SopraSteria/mac/KMP_APPS/PRUEBA-TECNICA/ANDROID/.github/skills/python-patterns/STRUCTURAL-PATTERNS.md

## Core patterns
- **Adapter**: wrapper para compatibilizar interfaz externa con contrato interno.
- **Decorator**: `@functools.wraps` o clases wrapper para añadir comportamiento.
- **Facade**: simplificar acceso a subsistema complejo (ej: SDK externo, HTTP client).
- **Proxy**: control de acceso, logging, cache transparente.
- **Composite**: estructuras en árbol con tratamiento uniforme de hojas y nodos.

## Decorator example
```python
import functools
import logging

def log_calls(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        logging.info(f"Calling {func.__name__}")
        result = func(*args, **kwargs)
        logging.info(f"Done {func.__name__}")
        return result
    return wrapper
```

## Anti-pattern watch
- Herencia para añadir comportamiento (usar Decorator o composición).
- Facade que expone más de lo que oculta.
- Adapter sin protocolo objetivo bien definido.
