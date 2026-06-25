---
name: devkit-uikit-patterns
description: >
  Skill de patrones UIKit clásicos para desarrollar y mantener apps iOS legacy.
  Cubre ViewControllers, Auto Layout, UITableView/UICollectionView, MVVM legacy,
  networking con URLSession, persistencia con CoreData y migración incremental a SwiftUI.
triggers:
  - "patron uikit"
  - "uikit viewcontroller"
  - "uitableview patron"
  - "uicollectionview patron"
  - "auto layout programatico"
  - "mvvm uikit"
  - "networking uikit urlsession"
  - "coredata patron"
  - "migrar uikit a swiftui"
  - "uihostingcontroller"
  - "antipatron uikit"
  - "storyboard vs xib"
non_triggers:
  - "swiftui exclusivamente (usar ios-patterns)"
  - "android compose o kotlin"
  - "backend o servidor"
  - "infraestructura ci/cd"
---

# UIKit Patterns

## Purpose

Proporcionar una guía práctica de patrones UIKit para implementar, auditar y mantener
apps iOS legacy con buenas prácticas. Cubre desde estructura de ViewControllers y layouts
hasta networking, persistencia y convivencia con SwiftUI mediante `UIHostingController`.

La skill es aplicable tanto para nuevas features en proyectos UIKit como para planificar
migraciones incrementales hacia SwiftUI.

## When to use

- Estás implementando una feature en una app UIKit y necesitas decidir el patrón correcto.
- Quieres auditar código UIKit existente para detectar antipatrones.
- Necesitas integrar un componente SwiftUI en un proyecto UIKit legacy.
- Quieres decidir entre Storyboard, XIB o Auto Layout programático.
- Necesitas implementar networking o persistencia con patrones probados en UIKit.

**Trigger phrases:**
- "¿Qué patrón uso para este ViewController UIKit?"
- "Revisa este código UIKit, ¿hay antipatrones?"
- "¿Cómo integro SwiftUI en mi proyecto UIKit?"
- "¿Cómo implemento el patrón MVVM en UIKit?"

## When NOT to use

- El proyecto es 100% SwiftUI → usar `ios-patterns`
- Tareas de CI/CD o infraestructura cloud
- Código Android, Kotlin o Compose
- Preguntas sobre Swift Concurrency aisladas → usar `ios-swift-concurrency`

## Inputs

**Contexto requerido:**
- `view_controller_code`: Fragmento del ViewController o clase a analizar
- `objetivo`: Qué quieres conseguir (nueva feature, refactor, migración parcial)

**Contexto opcional:**
- `ios_target`: Versión mínima de iOS del proyecto (ej. iOS 14, iOS 16)
- `arquitectura_actual`: MVC, MVVM, VIPER u otra
- `usa_storyboard`: Si el proyecto usa Storyboard, XIB o Auto Layout programático

## Steps

1. **Clasificar el problema:**
   - Identificar si es un problema de arquitectura (MVC vs MVVM), layout (Auto Layout), navegación, datos (networking/persistencia) o integración SwiftUI.

2. **Seleccionar patrón candidato:**
   - Evaluar 2-3 opciones con trade-offs (ver catálogos en `references/`).
   - Descartar según constraints del proyecto (versión iOS, tiempo, deuda técnica).

3. **Detectar antipatrones existentes:**
   - Massive ViewController (lógica de negocio en `viewDidLoad`)
   - Layout en `viewWillAppear` en lugar de `viewDidLayoutSubviews`
   - Retain cycles en closures sin `[weak self]`
   - Delegates sin `weak` — memory leak
   - Hardcoded strings y magic numbers en UIKit
   - Uso de `performSegue` para navegación compleja

4. **Proponer implementación:**
   - Código Swift idiomático UIKit con el patrón recomendado
   - Separación clara: ViewController (UI) · ViewModel (lógica) · Service (datos)
   - Gestión de ciclo de vida: `viewDidLoad`, `viewWillAppear`, `deinit`

5. **Integración SwiftUI (si aplica):**
   - Usar `UIHostingController` para embeber vistas SwiftUI
   - Usar `UIViewRepresentable` / `UIViewControllerRepresentable` en sentido inverso
   - Definir boundary de datos entre UIKit y SwiftUI con protocolos

6. **Validar con checklist:**
   - Sin lógica de negocio en ViewController
   - Memory management correcto (`weak`, `unowned`)
   - Layout definido en un único punto del ciclo de vida
   - Tests unitarios posibles sin UIKit (ViewModel testeable en aislamiento)

## Expected outputs

- Patrón recomendado con justificación y trade-offs descartados
- Fragmento de código Swift UIKit con el patrón aplicado
- Lista de antipatrones detectados con severidad (CRITICAL / HIGH / MEDIUM / LOW)
- Plan de refactor si aplica (pasos ordenados, sin romper funcionalidad existente)
- Guía de integración UIKit ↔ SwiftUI si se solicita migración

## Validation

- [ ] El patrón recomendado tiene trade-offs documentados vs alternativas descartadas
- [ ] El código propuesto no tiene retain cycles evidentes
- [ ] La separación ViewController / ViewModel / Service está clara
- [ ] Si hay integración SwiftUI, usa `UIHostingController` o `UIViewRepresentable`
- [ ] Los antipatrones detectados tienen nivel de severidad asignado
- [ ] El plan de refactor (si existe) es incremental y no rompe la app en ningún paso

## Examples

### Ejemplo 1 — Refactorizar Massive ViewController

**Prompt del usuario:**
> "Tengo un ViewController de 800 líneas con la llamada a la API, el parsing JSON y la lógica
> de presentación mezclados. ¿Cómo lo refactorizo sin romper nada?"

**Acción del agente:**
1. Identificar antipatrón: **Massive ViewController** (CRITICAL)
2. Recomendar patrón **MVVM** con separación en 3 capas:
   ```swift
   // ViewModel — lógica de negocio + estado
   final class UserListViewModel {
       private let userService: UserServiceProtocol
       var onUsersLoaded: (([User]) -> Void)?
       var onError: ((Error) -> Void)?

       init(userService: UserServiceProtocol = UserService()) {
           self.userService = userService
       }

       func loadUsers() {
           userService.fetchUsers { [weak self] result in
               switch result {
               case .success(let users): self?.onUsersLoaded?(users)
               case .failure(let error): self?.onError?(error)
               }
           }
       }
   }

   // ViewController — solo UI
   final class UserListViewController: UIViewController {
       private let viewModel = UserListViewModel()

       override func viewDidLoad() {
           super.viewDidLoad()
           bindViewModel()
           viewModel.loadUsers()
       }

       private func bindViewModel() {
           viewModel.onUsersLoaded = { [weak self] users in
               DispatchQueue.main.async { self?.updateUI(with: users) }
           }
       }
   }
   ```
3. Plan de refactor incremental: extraer servicio primero → extraer ViewModel → limpiar VC

---

### Ejemplo 2 — Integración SwiftUI en proyecto UIKit

**Prompt del usuario:**
> "Quiero añadir una pantalla nueva en SwiftUI a mi app UIKit legacy sin reescribir todo."

**Acción del agente:**
1. Recomendar `UIHostingController` como boundary UIKit → SwiftUI:
   ```swift
   // Navegar a una vista SwiftUI desde UIKit
   func showNewFeature() {
       let swiftUIView = NewFeatureView()
       let hostingVC = UIHostingController(rootView: swiftUIView)
       navigationController?.pushViewController(hostingVC, animated: true)
   }
   ```
2. Para pasar datos: usar `@ObservedObject` + clase `ObservableObject` compartida
3. Señalar que el NavigationController UIKit gestiona el back button automáticamente

---

### Ejemplo 3 — UITableView con patrón MVVM

**Prompt del usuario:**
> "¿Cómo implemento una UITableView con MVVM correctamente?"

**Acción del agente:**
1. Separar `UITableViewDataSource` en clase dedicada (no en el ViewController):
   ```swift
   final class UserTableDataSource: NSObject, UITableViewDataSource {
       var users: [User] = []

       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           users.count
       }

       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.reuseID, for: indexPath) as! UserCell
           cell.configure(with: users[indexPath.row])
           return cell
       }
   }
   ```
2. El ViewController solo conecta DataSource + ViewModel:
   ```swift
   private let dataSource = UserTableDataSource()

   override func viewDidLoad() {
       super.viewDidLoad()
       tableView.dataSource = dataSource
       viewModel.onUsersLoaded = { [weak self] users in
           self?.dataSource.users = users
           DispatchQueue.main.async { self?.tableView.reloadData() }
       }
   }
   ```
