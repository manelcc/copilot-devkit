---
title: "Android Kotlin Design Pattern Finder"
description: "Encuentra el patrón de diseño adecuado para tu problema Android/Kotlin"
version: "1.0"
agent: "devkit-android-expert-pattern"
---

Carga y aplica la skill `android-patterns`.

# Android Kotlin Design Pattern Finder

Describe el problema en tu código Android. No empieces con el nombre del patrón; empieza con el contexto del problema.

## Proceso de recomendación
1. Diagnosticar el problema raíz.
2. Recomendar 2-3 patrones candidatos.
3. Comparar trade-offs.
4. Proporcionar pasos de implementación en Kotlin/Compose.
5. Añadir estrategia de testing y notas de migración.

## Consulta rápida por escenario
- Creación y cableado de objetos → Creational patterns
- Colaboración y estado entre componentes → Behavioral patterns
- Composición y desacoplamiento → Structural patterns
- Coroutines/Flow/threading → Concurrency patterns
- Idiomas Kotlin y Android → Kotlin/Android-specific patterns

## Escenarios comunes
- ViewModel con muchas ramas condicionales → State
- Reglas de negocio intercambiables → Strategy
- Cola de acciones con undo/retry → Command
- Integración con SDK incompatible → Adapter o Facade
- Pantallas y servicios muy acoplados → Mediator o Observer
- Estado mutable compartido entre coroutines → Actor-style isolation
- Constructor con muchos parámetros → Builder + DI

## Salida esperada
- Diagnóstico del problema
- Shortlist de patrones con complejidad y riesgos
- Opción recomendada con código Kotlin/Compose
- Antipatrones detectados con severidad
- Checklist de implementación y tests
