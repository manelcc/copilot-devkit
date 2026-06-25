# Anti-patterns Checklist

## High
- Estado global mutable via singleton compartido.
- Navegación acoplada en múltiples vistas sin orquestador.
- Mezcla de lógica de dominio directamente en View SwiftUI.
- Mutaciones de UI fuera de `@MainActor`.

## Medium
- Uso excesivo de type erasure (`Any*`) sin necesidad.
- Sobreabstracción con fábricas/coordinadores innecesarios.
- Callbacks anidados en lugar de async/await.

## Low
- Duplicación de estrategias simples que podrían parametrizarse.
- Protocolos vacíos sin semántica real.

## Quick scoring
- 0-1 antipatrones high: riesgo controlado.
- 2+ antipatrones high: refactor prioritario.
- 3+ medium con alta frecuencia: deuda técnica acumulada.
