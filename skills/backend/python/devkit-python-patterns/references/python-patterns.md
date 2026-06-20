# Python-Specific Patterns (Reference)

Source lineage:
- /Users/manelcc/Library/CloudStorage/OneDrive-SopraSteria/mac/KMP_APPS/PRUEBA-TECNICA/ANDROID/.github/skills/python-patterns/PYTHON-PATTERNS.md

## Core patterns
- **Context Manager**: gestión de recursos con `with`. Limpieza garantizada incluso con excepciones.
- **Descriptor**: customizar acceso a atributos de clase con `__get__`/`__set__`/`__delete__`.
- **Protocol-based typing**: definir contratos con `typing.Protocol` sin herencia.
- **Dataclasses**: clases de datos con boilerplate mínimo (`@dataclass`, `@dataclass(frozen=True)`).
- **Callable DI**: inyectar dependencias como callables para máxima flexibilidad y testabilidad.

## Context Manager example
```python
from contextlib import contextmanager

@contextmanager
def db_transaction(session):
    try:
        yield session
        session.commit()
    except Exception:
        session.rollback()
        raise
```

## Protocol-based typing example
```python
from typing import Protocol

class Repository(Protocol):
    def get(self, id: int) -> dict: ...
    def save(self, entity: dict) -> None: ...

class UserService:
    def __init__(self, repo: Repository) -> None:
        self._repo = repo
```

## Dataclass example
```python
from dataclasses import dataclass

@dataclass(frozen=True)
class UserId:
    value: int

@dataclass
class User:
    id: UserId
    name: str
    email: str
```

## Callable DI example
```python
from typing import Callable

def make_handler(get_user: Callable[[int], dict]):
    def handle(user_id: int):
        user = get_user(user_id)
        return {"status": "ok", "user": user}
    return handle
```

## Selection cues
- Recurso externo con apertura/cierre garantizado: Context Manager.
- Contrato de tipo sin herencia: Protocol.
- Clase principalmente de datos: Dataclass.
- Dependencias intercambiables fácilmente testeables: Callable DI.

## Anti-pattern watch
- Usar `__init__` con muchos parámetros sin dataclass o builder.
- Herencia múltiple compleja donde Protocol bastaría.
- Any en lugar de Protocol para tipado flexible.
