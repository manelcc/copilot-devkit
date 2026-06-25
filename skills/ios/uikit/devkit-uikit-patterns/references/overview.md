# UIKit Patterns — Overview

## Workflow

```mermaid
flowchart TD
    A["Objetivo: nueva feature / refactor / migración"] --> B["Clasificar problema\n(arquitectura · layout · datos · integración)"]
    B --> C["Seleccionar patrón\n(MVC · MVVM · Coordinator · Repository)"]
    C --> D["Detectar antipatrones\n(Massive VC · retain cycles · layout erróneo)"]
    D --> E{"¿Migración\na SwiftUI?"}
    E -- Sí --> F["Boundary UIHostingController\no UIViewRepresentable"]
    E -- No --> G["Implementar patrón\nen UIKit puro"]
    F --> H["Validar:\nmemory · testabilidad · ciclo de vida"]
    G --> H
    H --> I["Entrega: código · antipatrones · plan refactor"]
```

## Patrones cubiertos

| Categoría | Patrón | Uso principal |
|---|---|---|
| Arquitectura | MVC | App sencilla, pantallas aisladas |
| Arquitectura | MVVM | Lógica compleja, testabilidad |
| Arquitectura | Coordinator | Navegación desacoplada |
| UI | UITableView DataSource separado | Separación responsabilidades |
| UI | Auto Layout programático | Sin Storyboard, control total |
| Datos | Repository + Service | Abstracción de red y persistencia |
| Datos | CoreData NSFetchedResultsController | Listas reactivas con persistencia |
| Integración | UIHostingController | UIKit → SwiftUI |
| Integración | UIViewRepresentable | SwiftUI → UIKit |

## Antipatrones detectables

- **Massive ViewController** (CRITICAL) — lógica de negocio en `viewDidLoad`
- **Retain cycle** (CRITICAL) — closure sin `[weak self]`
- **Delegate fuerte** (HIGH) — `var delegate: MyDelegate?` sin `weak`
- **Layout en viewWillAppear** (MEDIUM) — debe ser en `viewDidLayoutSubviews`
- **Magic strings en segues** (LOW) — usar constantes o Coordinator
