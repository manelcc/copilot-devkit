# MR — US-042: Skill UIKit Patterns para stack iOS UIKit

## Descripción

Añade la skill `uikit-patterns` al namespace `ios/uikit`, cubriendo los patrones UIKit
clásicos necesarios para desarrollar y mantener apps iOS legacy con buenas prácticas.

## Commits incluidos

| Hash | Tipo | Descripción |
|---|---|---|
| `a784fe4` | `feat` | add uikit-patterns skill for iOS UIKit stack |

## Artefactos creados

| Artefacto | Ruta |
|---|---|
| Skill principal | `skills/ios/uikit/uikit-patterns/SKILL.md` |
| Diagrama Mermaid | `skills/ios/uikit/uikit-patterns/references/overview.md` |

## Criterios de aceptación cubiertos

- [x] `skills/ios/uikit/uikit-patterns/` creado con SKILL.md válido
- [x] Cubre: Storyboard · Auto Layout · ViewControllers · networking · persistencia
- [x] Incluye ejemplos de migración incremental hacia SwiftUI (`UIHostingController`, `UIViewRepresentable`)
- [x] `references/overview.md` con diagrama Mermaid del flujo UIKit
- [x] `devkit-validate-skill.sh` retorna exit code 0 (pre-commit hook pasó)

## Contenido de la skill

**Patrones cubiertos:**
- Arquitectura: MVC, MVVM, Coordinator
- UI: UITableView/UICollectionView con DataSource separado, Auto Layout programático
- Datos: Repository + Service, CoreData con `NSFetchedResultsController`
- Integración: `UIHostingController` (UIKit → SwiftUI), `UIViewRepresentable` (SwiftUI → UIKit)

**Antipatrones detectables:**
- Massive ViewController (CRITICAL)
- Retain cycles sin `[weak self]` (CRITICAL)
- Delegate fuerte sin `weak` (HIGH)
- Layout en `viewWillAppear` (MEDIUM)
- Magic strings en segues (LOW)

**Ejemplos incluidos:**
1. Refactorizar Massive ViewController con MVVM
2. Integrar SwiftUI en proyecto UIKit legacy con `UIHostingController`
3. UITableView con DataSource separado + ViewModel

## Validación

```
[OK] SKILL.md exists
[OK] YAML frontmatter found
[OK] All frontmatter fields present
[OK] All 8 required sections present
[OK] references/overview.md exists
[OK] Mermaid diagram found
[OK] VALIDATION PASSED
```

## Impacto

- Namespace `skills/ios/uikit/` pasa de vacío a operativo
- Simetría `agents/` · `skills/` · `prompts/` mantenida
- Sin cambios en ficheros existentes

## Rama origen → destino

`feature/US-042-skill-uikit-patterns` → `develop`
