---
title: "Python Quality Analyzer"
description: "Auditoría de calidad Python con hallazgos priorizados por severidad"
version: "1.0"
agent: "python-quality"
---

Carga y aplica la skill `python-quality`.

# Python Quality Analyzer

Especifica el scope de análisis. Puede ser: repositorio completo, módulo específico o path concreto.

## Parámetros opcionales
- Focus: arquitectura, typing, testing, seguridad, performance
- Constraints: ignorar carpetas, solo código runtime, incluir/excluir tests

## Proceso de auditoría
1. Validar ficheros de reglas Python obligatorios.
2. Inspeccionar código Python con las reglas cargadas.
3. Registrar hallazgos verificables.
4. Clasificar por severidad CRITICAL/HIGH/MEDIUM/LOW.
5. Proponer plan de remediación 7/30 días.

## Salida esperada
- Resumen ejecutivo
- Estado de reglas (ok/missing)
- Tabla de hallazgos priorizados
- Quick wins
- Riesgos sistémicos
- Plan de remediación
