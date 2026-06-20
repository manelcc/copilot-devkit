# Behavioral Patterns (Reference - Python)

Source lineage:
- /Users/manelcc/Library/CloudStorage/OneDrive-SopraSteria/mac/KMP_APPS/PRUEBA-TECNICA/ANDROID/.github/skills/python-patterns/BEHAVIORAL-PATTERNS.md

## Core patterns
- **Observer**: notificación uno-a-muchos. En Python: callbacks, events, o librerías como `blinker`.
- **Strategy**: intercambio de algoritmos. En Python: callables o clases con `__call__`.
- **State**: comportamiento por estado. En Python: dict de handlers o clases de estado.
- **Command**: encapsular acciones. Util para colas, undo/redo.
- **Iterator**: recorrer colecciones. En Python: `__iter__`/`__next__` o generadores.
- **Template Method**: esqueleto fijo con pasos abstractos.

## Python strategy example
```python
from typing import Callable

type DiscountFn = Callable[[float], float]

def no_discount(price: float) -> float: return price
def ten_percent(price: float) -> float: return price * 0.9

def checkout(price: float, discount: DiscountFn) -> float:
    return discount(price)
```

## Anti-pattern watch
- Observer sin mecanismo de unsubscribe (leaks en long-lived objects).
- Template Method con subclases explosivas (preferir Strategy + composición).

## Notes
- En Python moderno, Strategy con callables es más idiomático que clases abstractas.
- `abc.ABC` para template method solo cuando sea realmente necesaria la herencia.
