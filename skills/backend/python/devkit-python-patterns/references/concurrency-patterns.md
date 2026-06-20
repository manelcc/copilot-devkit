# Concurrency Patterns (Reference - Python)

Source lineage:
- /Users/manelcc/Library/CloudStorage/OneDrive-SopraSteria/mac/KMP_APPS/PRUEBA-TECNICA/ANDROID/.github/skills/python-patterns/CONCURRENCY-PATTERNS.md

## Core patterns
- **Producer-Consumer**: `asyncio.Queue` para desacoplar producción y consumo.
- **Actor-like model**: objetos con estado aislado y mensajes para comunicación.
- **Read-Write coordination**: `asyncio.Lock` o `threading.RLock` para exclusión mutua.
- **Task orchestration**: `asyncio.gather`, `asyncio.TaskGroup` para concurrencia estructurada.

## asyncio orchestration example
```python
import asyncio

async def fetch_all(urls: list[str]) -> list[dict]:
    async with asyncio.TaskGroup() as tg:
        tasks = [tg.create_task(fetch(url)) for url in urls]
    return [t.result() for t in tasks]
```

## Producer-Consumer example
```python
async def producer(queue: asyncio.Queue):
    for item in data_source():
        await queue.put(item)
    await queue.put(None)  # sentinel

async def consumer(queue: asyncio.Queue):
    while (item := await queue.get()) is not None:
        await process(item)
        queue.task_done()
```

## Anti-pattern watch
- `time.sleep` en contexto async (bloquea event loop: usar `asyncio.sleep`).
- Shared mutable state sin lock.
- `asyncio.gather` sin manejo de excepciones individuales.
- Mezcla de threading y asyncio sin puente explícito.
