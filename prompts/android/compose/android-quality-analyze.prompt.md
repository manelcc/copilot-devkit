---
title: "Android Quality Analyzer"
description: "Auditoría de calidad Android/Kotlin con hallazgos priorizados por severidad"
version: "1.0"
agent: "android-quality"
---

Carga y aplica la skill `android-quality`.

# Android Quality Analyzer

Especifica el scope de análisis. Puede ser: repositorio completo, módulo específico o path concreto.

## Parámetros opcionales
- Focus: arquitectura, concurrencia, testing, seguridad, performance
- Constraints: ignorar módulos, solo Kotlin, incluir/excluir Gradle

## Proceso de auditoría
1. Validar ficheros de reglas obligatorios.
2. Inspeccionar código con las reglas cargadas.
3. Registrar hallazgos verificables.
4. Clasificar por severidad CRITICAL/HIGH/MEDIUM/LOW.
5. Proponer plan de remediación 7/30 días.

## Salida esperada
- Resumen ejecutivo
- Estado de reglas (ok/missing)
- Tabla de hallazgos priorizados
- Quick wins (< 1 día de trabajo)
- Riesgos sistémicos
- Plan de remediación
