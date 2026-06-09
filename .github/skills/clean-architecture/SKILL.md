---
name: clean-architecture
description: >
  Guía de arquitectura limpia para Kotlin server-side: reglas de dependencia,
  límites de capas (domain/application/infrastructure/entrypoint), diseño de use cases,
  puertos/adapters y validación de imports entre capas.
applyTo:
  - "**/*.kt"
triggers:
  - "clean architecture"
  - "cómo estructuro este use case"
  - "regla de dependencias"
  - "layer violation"
  - "arquitectura por capas"
  - "ports and adapters"
nonTriggers:
  - Generación de pipelines CI/CD (usar skills *-cicd)
  - Revisión de estilo/código limpio sin foco arquitectónico (usar clean-code-guardian)
---

# Clean Architecture Kotlin

## Propósito

Definir y aplicar una arquitectura limpia en servicios Kotlin, manteniendo
acoplamiento bajo y direccionalidad correcta de dependencias.

## Reglas base

- `domain` no depende de ninguna otra capa.
- `application` depende de `domain` y define puertos (interfaces).
- `infrastructure` implementa puertos de `application`.
- `entrypoint` (Ktor/Spring controllers, MCP handlers) solo orquesta y delega en `application`.
- Nunca importar `infrastructure` desde `domain` o `application`.

## Checklist rápido

- Use case sin acceso directo a framework o DB.
- Repositorio definido como interfaz en `application/domain` e implementación en `infrastructure`.
- DTOs de entrada/salida aislados del modelo de persistencia.
- Wiring en DI (`Koin`/equivalente) en capa de composición.

## Salida esperada

Cuando se use esta skill, entregar:

1. Diagnóstico de capas actuales.
2. Violaciones detectadas (si existen).
3. Propuesta mínima de refactor por prioridad.
4. Estructura objetivo de paquetes y dependencias.
