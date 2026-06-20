---
title: "iOS Expert Patterns Finder"
description: "Encuentra el patrón de diseño adecuado para tu problema iOS/Swift"
version: "1.0"
agent: "devkit-ios-swiftui-expert"
---

Carga y aplica la skill `ios-patterns`.

# iOS Expert Patterns Finder

Describe el problema en tu código iOS/Swift. No empieces con el nombre del patrón; empieza con el contexto del problema.

## Proceso de recomendación
1. Diagnosticar el problema raíz.
2. Recomendar 2-3 patrones candidatos.
3. Comparar trade-offs.
4. Proporcionar pasos de implementación en Swift/SwiftUI.
5. Añadir estrategia de testing y notas de migración.

## Consulta rápida por escenario
- Creación y gestión de dependencias → Creational patterns
- Colaboración y estado → Behavioral patterns
- Composición y desacoplamiento → Structural patterns
- Async/await y concurrencia → Concurrency patterns
- Idiomas Swift → Swift-specific patterns

## Escenarios comunes
- Navegación embebida en vistas → Coordinator pattern
- Reglas de negocio intercambiables → Strategy
- Flujo con estados definidos → State
- Integración con SDK externo → Adapter o Facade
- Múltiples observadores de estado → Observer o Combine
- Estado mutable entre actores → Actor model

## Salida esperada
- Diagnóstico del problema
- Shortlist de patrones con complejidad y riesgos
- Opción recomendada con código Swift
- Antipatrones detectados con severidad
- Checklist de implementación y tests
