---
title: "Python Design Pattern Finder"
description: "Encuentra el patrón de diseño adecuado para tu problema Python"
version: "1.0"
agent: "python-expert-pattern"
---

Carga y aplica la skill `python-patterns`.

# Python Design Pattern Finder

Describe el problema en tu código Python. No empieces con el nombre del patrón; empieza con el contexto del problema.

## Proceso de recomendación
1. Diagnosticar el problema raíz.
2. Recomendar 2-3 patrones candidatos.
3. Comparar trade-offs.
4. Proporcionar pasos de implementación Python idiomático.
5. Añadir estrategia de testing y tips de migración.

## Consulta rápida por escenario
- Flexibilidad de creación de objetos → Creational patterns
- Colaboración y estado → Behavioral patterns
- Composición y desacoplamiento → Structural patterns
- Threading/async → Concurrency patterns
- Idiomas y typing Python → Python-specific patterns

## Escenarios comunes
- Muchos args opcionales en __init__ → Builder, dataclass factories
- Algoritmos intercambiables → Strategy
- Comportamiento dependiente del estado → State
- Wrapping de API de terceros → Adapter, Facade
- Comportamiento transversal (logging, cache) → Decorator, Proxy
- Pipelines async → Producer-Consumer, task orchestration

## Salida esperada
- Diagnóstico del problema
- Shortlist de patrones con complejidad y riesgos
- Plan de implementación recomendado
- Código Python ejecutable
- Antipatrones detectados con severidad
