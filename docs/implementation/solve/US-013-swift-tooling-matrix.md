# US-013 - Matriz de tooling Swift/iOS considerada

## Contexto
Se incorpora la tabla de herramientas y recursos Swift/iOS aportada por usuario como criterio de diseño para la US-013.

## Decision de uso por categoria

| Recurso | Categoria | Decision en US-013 |
|---|---|---|
| MCP de Xcode (mcpbridge) | MCP nativo | Referencia preferida para diagnostico y operaciones de proyecto Xcode cuando el entorno lo soporte |
| XcodeBuildMCP | MCP comunidad | Referencia preferida para build/test estructurado en simulador |
| Foundation Models framework | Framework Apple | Referencia para futuros casos de IA on-device; no bloqueante para esta US |
| swiftui-expert-skill | Skill | Referencia complementaria para patrones/review SwiftUI |
| swift-patterns-skill | Skill | Referencia complementaria para estado/navegacion/rendimiento |
| GitHub Copilot for Xcode | Asistente | Recomendado para flujo local Xcode |
| MLX Framework | Framework Apple | Referencia para inferencia local en Apple Silicon cuando aplique |
| SwiftMCP | Protocolo/implementacion | Considerar en casos de interoperabilidad agente-herramienta |

## Aplicacion concreta en artefactos de US-013
- Se actualiza `instructions/devkit-ios-swiftui.instructions.md` con una seccion de matriz de herramientas y criterios de decision.
- Se mantienen referencias oficiales de Apple en skills SwiftUI y en instrucciones.

## Restricciones
- Las decisiones de tooling estan condicionadas a version de Xcode, macOS y soporte de plataforma indicado por cada proveedor.
- No se introduce dependencia obligatoria de herramientas no disponibles en CI/equipo.