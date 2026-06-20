---
title: "iOS Quality Analyzer"
description: "Auditoría de calidad iOS/Swift con hallazgos priorizados por severidad"
version: "1.0"
agent: "ios-quality"
---

Carga y aplica la skill `ios-quality`.

# iOS Quality Analyzer

Especifica el scope de análisis. Puede ser: repositorio completo, módulo específico o path concreto.

## Parámetros opcionales
- Focus: arquitectura, concurrencia, seguridad, testing, SwiftUI patterns
- Constraints: ignorar módulos, solo Swift, incluir/excluir config files

## Proceso de auditoría
1. Validar ficheros de reglas iOS obligatorios.
2. Inspeccionar código Swift/SwiftUI con las reglas cargadas.
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
