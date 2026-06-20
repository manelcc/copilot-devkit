# Creational Patterns (Reference - Python)

Source lineage:
- /Users/manelcc/Library/CloudStorage/OneDrive-SopraSteria/mac/KMP_APPS/PRUEBA-TECNICA/ANDROID/.github/skills/python-patterns/CREATIONAL-PATTERNS.md

## Core patterns
- **Singleton**: un módulo Python ya es singleton por defecto. Evitar clases singleton manuales.
- **Factory Method**: `@classmethod` o funciones de fábrica para creación desacoplada.
- **Abstract Factory**: familias de objetos relacionados via Protocol o ABC.
- **Builder**: construcción fluida con dataclass + métodos encadenados o funciones step.
- **Dependency Injection**: inyectar desde fuera, no crear internamente.
- **Lazy Initialization**: propiedades `@cached_property` o `functools.lru_cache`.

## Factory example
```python
from typing import Protocol

class Notifier(Protocol):
    def send(self, message: str) -> None: ...

def make_notifier(channel: str) -> Notifier:
    match channel:
        case "email": return EmailNotifier()
        case "sms": return SmsNotifier()
        case _: raise ValueError(f"Unknown channel: {channel}")
```

## Anti-pattern watch
- Singleton manual con estado mutable: prefer inyección.
- `__init__` con más de 5 parámetros sin Builder ni dataclass.
- Importación directa de módulo de infraestructura desde dominio.
