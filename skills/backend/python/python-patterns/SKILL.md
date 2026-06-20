---
name: python-patterns
description: >
  Skill de patrones de diseño Python para decidir patrón aplicable en una
  implementación, identificar el patrón existente en código y detectar
  antipatrones con acciones de remediación.
triggers:
  - "que patron aplica python"
  - "identifica patron en este codigo python"
  - "esto es antipatron en python"
  - "plan de implementacion con patrones python"
  - "review de patrones python"
non_triggers:
  - "pipeline ci"
  - "android compose"
  - "ios swiftui"
---

# Python Patterns

## Purpose
Aportar una metodología práctica para seleccionar patrones de diseño en Python, reconocer patrones ya presentes y detectar antipatrones antes de implementar o refactorizar.

## When to use
- Estás planificando una implementación Python y necesitas decidir patrón.
- Quieres auditar una feature para saber qué patrón ya está aplicado.
- Quieres detectar antipatrones de diseño y proponer una ruta de mejora.
- Quieres justificar arquitectura en una review técnica.

## When NOT to use
- Tareas puramente de configuración o infraestructura.
- Código no Python.
- Revisión de formato sin impacto en diseño.

## Inputs
- Objetivo de negocio y constraints técnicos.
- Fragmentos de código relevantes (servicios, repositorios, handlers, modelos).
- Requisitos no funcionales: testabilidad, concurrencia, performance, mantenibilidad.
- Contexto de versión (Python 3.10+, asyncio, tipado).

## Steps
1. Clasificar el problema: creación, estructura, comportamiento, concurrencia o patrón Python-específico.
2. Evaluar 2-3 patrones candidatos con trade-offs y criterio de descarte.
3. Identificar el patrón actualmente aplicado (si existe) y su grado de correcta implementación.
4. Detectar antipatrones asociados y su severidad (CRITICAL/HIGH/MEDIUM/LOW).
5. Verificar evidencia en código; si no hay evidencia suficiente, marcarlo como hipótesis-no-verificada.
6. Recomendar decisión final: mantener, ajustar o migrar de patrón.
7. Proponer plan de implementación o refactor con pasos verificables.
8. Definir checklist de validación (tests, acoplamiento, extensibilidad, concurrencia).

### Per-file references
- `references/overview.md`
- `references/behavioral-patterns.md`
- `references/creational-patterns.md`
- `references/structural-patterns.md`
- `references/concurrency-patterns.md`
- `references/python-patterns.md`
- `references/anti-patterns.md`

### Pattern families covered
- Creacionales: Singleton, Factory Method, Abstract Factory, Builder, Dependency Injection, Lazy Initialization.
- Estructurales: Adapter, Decorator, Facade, Proxy, Composite.
- Comportamiento: Observer, Strategy, State, Command, Mediator, Iterator, Template Method.
- Concurrencia: Producer-Consumer, Actor-like model, Read-Write coordination, asyncio orchestration.
- Python-específicos: Context Manager, Descriptor, Protocol-based typing, dataclasses, callable DI.

### Anti-pattern heuristics
- God object con responsabilidades mezcladas.
- Estado global mutable sin scope definido.
- Singleton abuse donde DI es más claro.
- Catch-all exceptions que ocultan fallos.
- Concurrencia sin cancelación ni timeouts.
- Tipado opcional ignorado en código crítico.

## Expected outputs
- Diagnóstico de patrón recomendado con razonamiento y trade-offs.
- Identificación del patrón actual en el código (o ausencia de patrón claro).
- Lista priorizada de antipatrones detectados con severidad e impacto.
- Estado de evidencia: verificado o hipótesis-no-verificada (no bloqueante).
- Plan de implementación/refactor en pasos concretos.

## Validation
- [ ] Se identifica la familia de patrón aplicable.
- [ ] Se comparan al menos 2 candidatos cuando hay ambigüedad.
- [ ] Se indica patrón actualmente aplicado (o "ninguno").
- [ ] Se listan antipatrones con severidad y remediación.
- [ ] Si falta evidencia, se marca como hipótesis-no-verificada sin bloquear recomendación.
- [ ] Se entrega checklist de verificación técnica.
- [ ] `references/overview.md` existe con diagrama Mermaid.

## Examples

### Example 1 - Selección de patrón

```text
Input: "Tengo un servicio de notificaciones que debe dispararse en 5 canales distintos"

Salida esperada:
1) Candidatos: Observer, Strategy, Command.
2) Decisión: Observer (desacoplamiento) + Strategy (canal específico).
3) Patrón actual detectado: llamadas directas acopladas (antipatrón HIGH).
4) Plan:
   - Crear NotificationEvent como modelo de datos.
   - Implementar NotificationChannel como Protocol.
   - Registrar handlers en un dispatcher Observable.
```

### Example 2 - Detección de antipatrón

```python
class Config:
    _instance = None
    db_url = "sqlite:///prod.db"
    secret_key = "hardcoded_secret"

    @classmethod
    def get(cls):
        if not cls._instance:
            cls._instance = cls()
        return cls._instance
```

```text
Diagnóstico:
- Patrón detectado: Singleton.
- Antipatrón: singleton con secreto hardcodeado y estado global.
- Riesgo: CRITICAL (seguridad) + HIGH (testabilidad).
- Remediación:
  - Leer configuración desde variables de entorno.
  - Inyectar Config como dependencia, no como singleton global.
```

## Sources
- Source origin: /Users/manelcc/Library/CloudStorage/OneDrive-SopraSteria/mac/KMP_APPS/PRUEBA-TECNICA/ANDROID/.github/skills/python-patterns/
- Python official docs: https://docs.python.org/3/
