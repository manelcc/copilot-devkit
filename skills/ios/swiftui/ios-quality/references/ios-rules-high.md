# Copilot Guidelines: iOS (Swift) — HIGH

---

Total rules: **21** (16 custom + 4 SonarQube + 1 SwiftLint)

## ViewModel

### IOS_VM_001
- **Severity:** HIGH
- **Description:** Los ViewModels deben ser independientes de UIKit: no deben importar UIKit ni contener referencias a UIViewController, UIView o UIApplication.
- **Conditions:** language: swift, source_type: ViewModel
- **Action:** Mantener ViewModels como POMO (Plain Old Model Objects) sin dependencias de frameworks UI.
- **Bad example:**
```
import UIKit
class LoginViewModel {
    func showAlert() {
        UIAlertController(...)
    }
}
```
- **Good example:**
```
class LoginViewModel {
    @Published var errorMessage: String?
    func login() {
        // View observa errorMessage y muestra la alerta
    }
}
```
- **References:**
  - https://medium.com/@chandra.welim/swiftui-state-management-state-binding-stateobject-observedobject-explained-78d871f6418b
  - https://hanisahilole.medium.com/state-vs-binding-in-swiftui-6bcc633d5176

### IOS_VM_002
- **Severity:** HIGH
- **Description:** Los ViewModels deben exponer estado mediante @Published (Combine) o callbacks, nunca permitir mutación directa desde la vista.
- **Conditions:** language: swift, source_type: ViewModel
- **Action:** Usar @Published para propiedades de estado y métodos para acciones.
- **Bad example:**
```
class ProfileViewModel {
    var userName: String = ""
}
// En la vista:
viewModel.userName = "New Name"
```
- **Good example:**
```
class ProfileViewModel {
    @Published private(set) var userName: String = ""
    func updateUserName(_ name: String) {
        userName = name
    }
}
```
- **References:**
  - https://medium.com/@chandra.welim/swiftui-state-management-state-binding-stateobject-observedobject-explained-78d871f6418b
  - https://hanisahilole.medium.com/state-vs-binding-in-swiftui-6bcc633d5176

---

## Memoria

### IOS_MEMORY_002
- **Severity:** HIGH
- **Description:** Los delegates deben declararse como weak para evitar ciclos de retención.
- **Conditions:** language: swift, pattern: protocol delegate
- **Action:** Declarar delegates como weak var y asegurar que el protocolo sea class-only (AnyObject).
- **Bad example:**
```
protocol MyDelegate { }
class MyClass {
    var delegate: MyDelegate?
}
```
- **Good example:**
```
protocol MyDelegate: AnyObject { }
class MyClass {
    weak var delegate: MyDelegate?
}
```
- **References:**
  - https://medium.com/ios-lab/6-swiftui-components-you-didnt-know-existed-bb7d0f21da9e
  - https://medium.com/@eu.barquin/how-to-run-ai-models-locally-on-ios-with-core-ml-part-1-f69bd82de69c

---

## Async/Await

### IOS_ASYNC_001
- **Severity:** HIGH
- **Description:** Usar async/await en lugar de completion handlers para código asíncrono cuando el target es iOS 13+.
- **Conditions:** language: swift, ios_version: >=13
- **Action:** Migrar completion handlers a async/await para mejor legibilidad y manejo de errores.
- **Bad example:**
```
func fetchUser(completion: @escaping (User?, Error?) -> Void) {
    URLSession.shared.dataTask(...) { data, response, error in
        completion(user, error)
    }.resume()
}
```
- **Good example:**
```
func fetchUser() async throws -> User {
    let (data, _) = try await URLSession.shared.data(from: url)
    return try JSONDecoder().decode(User.self, from: data)
}
```
- **References:**
  - https://medium.com/@ums_ngg/swift-modern-concurrency-%D0%BE%D1%81%D0%BD%D0%BE%D0%B2%D1%8B-866da979e204
  - https://medium.com/@maatheusgois/data-flow-in-swiftui-unidirectional-async-and-resilient-f6429dd0f273

### IOS_ASYNC_002
- **Severity:** HIGH
- **Description:** Usar Task en lugar de DispatchQueue.global() para trabajo asíncrono en iOS 13+.
- **Conditions:** language: swift, ios_version: >=13
- **Action:** Reemplazar DispatchQueue con Task para aprovechar structured concurrency.
- **Bad example:**
```
DispatchQueue.global().async {
    let data = fetchData()
    DispatchQueue.main.async {
        self.updateUI(data)
    }
}
```
- **Good example:**
```
Task {
    let data = await fetchData()
    await MainActor.run {
        updateUI(data)
    }
}
```
- **References:**
  - https://medium.com/@ums_ngg/swift-modern-concurrency-%D0%BE%D1%81%D0%BD%D0%BE%D0%B2%D1%8B-866da979e204
  - https://medium.com/@maatheusgois/data-flow-in-swiftui-unidirectional-async-and-resilient-f6429dd0f273

---

## Concurrencia

### IOS_ASYNC_003
- **Severity:** HIGH
- **Description:** Actualizar la UI siempre en el Main Thread usando @MainActor o DispatchQueue.main.
- **Conditions:** language: swift, pattern: UI update
- **Action:** Marcar ViewModels con @MainActor o usar await MainActor.run { } para actualizaciones UI.
- **Bad example:**
```
Task {
    let data = await fetchData()
    self.tableView.reloadData() // ⚠️ No garantiza main thread
}
```
- **Good example:**
```
@MainActor
class ViewModel: ObservableObject {
    func loadData() async {
        data = await fetchData()
        // Ya está en main thread
    }
}
```
- **References:**
  - https://medium.com/@ums_ngg/swift-modern-concurrency-%D0%BE%D1%81%D0%BD%D0%BE%D0%B2%D1%8B-866da979e204
  - https://medium.com/@maatheusgois/data-flow-in-swiftui-unidirectional-async-and-resilient-f6429dd0f273

---

## SwiftUI

### IOS_SWIFTUI_001
- **Severity:** HIGH
- **Description:** Las Views de SwiftUI deben ser structs, no classes, para aprovechar la naturaleza value-type y rendimiento.
- **Conditions:** language: swift, framework: SwiftUI
- **Action:** Declarar todas las Views como struct, nunca como class.
- **Bad example:**
```
class LoginView: View { var body: some View { ... } }
```
- **Good example:**
```
struct LoginView: View { var body: some View { ... } }
```
- **References:**
  - https://medium.com/ios-lab/6-swiftui-components-you-didnt-know-existed-bb7d0f21da9e
  - https://medium.com/%E5%BD%BC%E5%BE%97%E6%BD%98%E7%9A%84-swift-ios-app-%E9%96%8B%E7%99%BC%E5%95%8F%E9%A1%8C%E8%A7%A3%E7%AD%94%E9%9B%86/font-%E7%B8%AE%E6%94%BE%E5%AD%97%E9%AB%94%E7%9A%84-scaled-by-ios-26-%E6%96%B0%E5%8A%9F%E8%83%BD-bbf302a25f0b

### IOS_SWIFTUI_002
- **Severity:** HIGH
- **Description:** Usar @StateObject para ViewModels creados por la vista, @ObservedObject para ViewModels pasados desde el padre.
- **Conditions:** language: swift, framework: SwiftUI
- **Action:** StateObject mantiene la propiedad del objeto, ObservedObject solo observa.
- **Bad example:**
```
struct ContentView: View {
    @ObservedObject var viewModel = ViewModel() // ⚠️ Se recrea en cada render
}
```
- **Good example:**
```
struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
}
```
- **References:**
  - https://medium.com/ios-lab/6-swiftui-components-you-didnt-know-existed-bb7d0f21da9e
  - https://medium.com/%E5%BD%BC%E5%BE%97%E6%BD%98%E7%9A%84-swift-ios-app-%E9%96%8B%E7%99%BC%E5%95%8F%E9%A1%8C%E8%A7%A3%E7%AD%94%E9%9B%86/font-%E7%B8%AE%E6%94%BE%E5%AD%97%E9%AB%94%E7%9A%84-scaled-by-ios-26-%E6%96%B0%E5%8A%9F%E8%83%BD-bbf302a25f0b

---

## Combine

### IOS_COMBINE_001
- **Severity:** HIGH
- **Description:** Almacenar suscripciones de Combine en un Set<AnyCancellable> para evitar memory leaks.
- **Conditions:** language: swift, framework: Combine
- **Action:** Usar .store(in: &cancellables) para todas las suscripciones.
- **Bad example:**
```
viewModel.$data.sink { data in
    print(data)
}
```
- **Good example:**
```
private var cancellables = Set<AnyCancellable>()

viewModel.$data.sink { data in
    print(data)
}.store(in: &cancellables)
```
- **References:**
  - https://medium.com/@eu.barquin/building-a-reactive-search-in-swiftui-with-combine-b5e187ee0cab
  - https://medium.com/@surajglokhande/combine-framework-learning-roadmap-for-ios-development-part-1-4-7ace07a8b628

### IOS_COMBINE_002
- **Severity:** HIGH
- **Description:** Usar operadores de Combine (.map, .filter, .flatMap) en lugar de lógica en sink.
- **Conditions:** language: swift, framework: Combine
- **Action:** Mantener sink simple, mover transformaciones a la cadena de operadores.
- **Bad example:**
```
viewModel.$users.sink { users in
    let activeUsers = users.filter { $0.isActive }
    self.displayUsers = activeUsers
}.store(in: &cancellables)
```
- **Good example:**
```
viewModel.$users
    .map { $0.filter { $0.isActive } }
    .assign(to: &$displayUsers)
```
- **References:**
  - https://medium.com/@eu.barquin/building-a-reactive-search-in-swiftui-with-combine-b5e187ee0cab
  - https://medium.com/@surajglokhande/combine-framework-learning-roadmap-for-ios-development-part-1-4-7ace07a8b628

---

## Networking

### IOS_NETWORK_001
- **Severity:** HIGH
- **Description:** No usar URLSession.shared directamente. Inyectar URLSession para permitir testing.
- **Conditions:** language: swift, pattern: URLSession.shared
- **Action:** Crear un protocolo NetworkSession y usar dependency injection.
- **Bad example:**
```
class APIClient {
    func fetchData() async throws -> Data {
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
}
```
- **Good example:**
```
protocol NetworkSession {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

class APIClient {
    let session: NetworkSession
    init(session: NetworkSession = URLSession.shared) {
        self.session = session
    }
}
```
- **References:**
  - https://medium.com/ios-lab/6-swiftui-components-you-didnt-know-existed-bb7d0f21da9e
  - https://medium.com/@eu.barquin/how-to-run-ai-models-locally-on-ios-with-core-ml-part-1-f69bd82de69c

### IOS_NETWORK_002
- **Severity:** HIGH
- **Description:** Manejar errores de red de forma específica, no capturar Error genérico.
- **Conditions:** language: swift, pattern: network error handling
- **Action:** Crear enums de Error personalizados para diferentes fallos de red.
- **Bad example:**
```
do {
    let data = try await fetchData()
} catch {
    print("Error: \(error)")
}
```
- **Good example:**
```
enum NetworkError: Error {
    case noConnection
    case timeout
    case serverError(Int)
    case decodingFailed
}

do {
    let data = try await fetchData()
} catch let error as NetworkError {
    handle(error)
}
```
- **References:**
  - https://medium.com/ios-lab/6-swiftui-components-you-didnt-know-existed-bb7d0f21da9e
  - https://medium.com/@eu.barquin/how-to-run-ai-models-locally-on-ios-with-core-ml-part-1-f69bd82de69c

---

## CoreData

### IOS_COREDATA_001
- **Severity:** HIGH
- **Description:** No usar NSManagedObjectContext en el main thread para operaciones pesadas.
- **Conditions:** language: swift, framework: CoreData
- **Action:** Usar performBackgroundTask para inserts/updates masivos.
- **Bad example:**
```
let context = container.viewContext
for item in largeDataSet {
    let entity = Entity(context: context)
    entity.data = item
}
try! context.save()
```
- **Good example:**
```
container.performBackgroundTask { context in
    for item in largeDataSet {
        let entity = Entity(context: context)
        entity.data = item
    }
    try? context.save()
}
```
- **References:**
  - https://levelup.gitconnected.com/the-definitive-guide-to-migrating-from-core-data-to-swiftdata-the-hard-parts-5de8b2c545c3
  - https://medium.com/reversebits/mastering-core-data-migration-in-swift-a-complete-guide-2025-ec9633321b85

### IOS_COREDATA_002
- **Severity:** HIGH
- **Description:** Usar NSFetchedResultsController para tablas dinámicas, no arrays manuales.
- **Conditions:** language: swift, framework: CoreData
- **Action:** FetchedResultsController maneja actualizaciones automáticamente y es más eficiente.
- **Bad example:**
```
var items: [Item] = []

func loadItems() {
    let request: NSFetchRequest<Item> = Item.fetchRequest()
    items = try! context.fetch(request)
    tableView.reloadData()
}
```
- **Good example:**
```
lazy var fetchedResultsController: NSFetchedResultsController<Item> = {
    let request: NSFetchRequest<Item> = Item.fetchRequest()
    request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
    return NSFetchedResultsController(fetchRequest: request, ...)
}()
```
- **References:**
  - https://levelup.gitconnected.com/the-definitive-guide-to-migrating-from-core-data-to-swiftdata-the-hard-parts-5de8b2c545c3
  - https://medium.com/reversebits/mastering-core-data-migration-in-swift-a-complete-guide-2025-ec9633321b85

---

## Testing

### IOS_TESTING_001
- **Severity:** HIGH
- **Description:** Usar protocolos para dependencias en lugar de clases concretas para facilitar testing.
- **Conditions:** language: swift, pattern: dependency injection
- **Action:** Definir protocolos para servicios y usar mocks en tests.
- **Bad example:**
```
class ViewModel {
    let apiClient = APIClient()
}
```
- **Good example:**
```
protocol APIClientProtocol {
    func fetchData() async throws -> Data
}

class ViewModel {
    let apiClient: APIClientProtocol
    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
}
```
- **References:**
  - https://medium.com/@bhumibhuva18/ui-integration-testing-in-swiftui-using-xctest-device-farms-1f018d13e7c3
  - https://medium.com/@mrhotfix/swift-6-result-type-xctest-error-handling-ios-18-functional-programming-developer-writing-33b5c1930730

---

## Optionals

### IOS_OPTIONALS_001
- **Severity:** HIGH
- **Description:** Evitar force unwrapping (!) salvo que sea absolutamente seguro. Usar guard let o if let.
- **Conditions:** language: swift, pattern: force unwrap
- **Action:** Reemplazar ! con optional binding seguro.
- **Bad example:**
```
let userName = user.name!
```
- **Good example:**
```
guard let userName = user.name else { return }
// o
if let userName = user.name { ... }
```
- **References:**
  - https://medium.com/ios-lab/6-swiftui-components-you-didnt-know-existed-bb7d0f21da9e
  - https://medium.com/@eu.barquin/how-to-run-ai-models-locally-on-ios-with-core-ml-part-1-f69bd82de69c

---

## SonarQube — Code Clarity

### IOS_SQ_S1186
- **Severity:** HIGH
- **Sonar Rule:** S1186 | CRITICAL | CODE_SMELL
- **Description:** Las funciones y métodos no deben tener el cuerpo vacío sin documentación. Si la implementación vacía es intencional, debe justificarse con un comentario.
- **Conditions:** language: swift
- **Action:** Implementar el cuerpo de la función o añadir un comentario que justifique por qué está vacío.
- **Bad example:**
```
func onDataReceived(_ data: Data) { }
override func viewWillDisappear(_ animated: Bool) { }
```
- **Good example:**
```
func onDataReceived(_ data: Data) {
    // Deliberadamente vacío: este módulo ignora los datos de entrada
}
```
- **References:**
  - https://rules.sonarsource.com/swift/RSPEC-1186/

### IOS_SQ_S1192
- **Severity:** HIGH
- **Sonar Rule:** S1192 | CRITICAL | CODE_SMELL
- **Description:** Los literales de String no deben duplicarse más de 3 veces. La duplicación hace que cualquier cambio sea propenso a errores al tener que actualizar múltiples lugares.
- **Conditions:** language: swift, threshold: 3 occurrences
- **Action:** Extraer el string duplicado a una constante estática o enum de strings.
- **Bad example:**
```
label.text = "user_profile"
Analytics.track("user_profile")
Logger.log("user_profile")
navigate(to: "user_profile") // ⚠️ Cuarta duplicación
```
- **Good example:**
```
enum Screen {
    static let userProfile = "user_profile"
}
label.text = Screen.userProfile
Analytics.track(Screen.userProfile)
```
- **References:**
  - https://rules.sonarsource.com/swift/RSPEC-1192/

### IOS_SQ_S3661
- **Severity:** HIGH
- **Sonar Rule:** S3661 | CRITICAL | CODE_SMELL
- **Description:** Las propiedades y variables con tipo inferido cuyo tipo no sea obvio del contexto inmediato deben declararse con tipo explícito para mejorar la legibilidad y mantenibilidad.
- **Conditions:** language: swift
- **Action:** Añadir anotaciones de tipo explícito donde el tipo no sea evidente a primera vista.
- **Bad example:**
```
let result = apiClient.processOrder(order) // ¿Qué tipo devuelve?
let config = buildConfiguration(for: environment)
```
- **Good example:**
```
let result: OrderResponse = apiClient.processOrder(order)
let config: AppConfiguration = buildConfiguration(for: environment)
```
- **References:**
  - https://rules.sonarsource.com/swift/RSPEC-3661/

### IOS_SQ_S3776
- **Severity:** HIGH
- **Sonar Rule:** S3776 | CRITICAL | CODE_SMELL
- **Description:** La complejidad cognitiva de una función no debe superar el umbral de 15. Las funciones muy complejas son difíciles de entender, testear y mantener.
- **Conditions:** language: swift, threshold: 15
- **Action:** Refactorizar extrayendo lógica a métodos auxiliares privados con responsabilidad única.
- **Bad example:**
```
func processOrder(_ order: Order) { // Complejidad cognitiva > 15
    if order.isValid {
        if order.user != nil {
            for item in order.items {
                if item.inStock {
                    if item.price > 0 { /* ... */ }
                }
            }
        }
    }
}
```
- **Good example:**
```
func processOrder(_ order: Order) {
    guard order.isValid, order.user != nil else { return }
    processItems(order.items)
}

private func processItems(_ items: [Item]) {
    items.filter { $0.inStock && $0.price > 0 }.forEach(processItem)
}
```
- **References:**
  - https://rules.sonarsource.com/swift/RSPEC-3776/

---

## SwiftLint

### IOS_SL_003
- **Severity:** HIGH
- **SwiftLint Rule:** `cyclomatic_complexity` | error (threshold > 20) | enabled by default
- **Description:** La complejidad ciclomática de una función no debe superar 20 (error) ni 10 (warning). Las funciones muy complejas son difíciles de testear, revisar y mantener. Nota: el SonarQube IOS_SQ_S3776 cubre complejidad cognitiva; esta regla cubre complejidad ciclomática (caminos lógicos).
- **Conditions:** language: swift, pattern: cyclomatic complexity > threshold
- **Action:** Extraer lógica en métodos privados con responsabilidad única, usar early returns con guard y dividir responsabilidades en subprocedimientos.
- **Bad example:**
```
func processOrder(_ order: Order) { // complexity > 20
    if order.isValid {
        if order.items.isEmpty { return }
        for item in order.items {
            if item.inStock {
                if item.price > 0 {
                    if order.paymentMethod == .card {
                        // más branches anidados...
                    }
                }
            }
        }
    }
}
```
- **Good example:**
```
func processOrder(_ order: Order) {
    guard order.isValid, !order.items.isEmpty else { return }
    let validItems = order.items.filter { $0.inStock && $0.price > 0 }
    charge(validItems, with: order.paymentMethod)
}

private func charge(_ items: [Item], with method: PaymentMethod) {
    guard method == .card else { return }
    // lógica de cobro simplificada
}
```
- **References:**
  - https://github.com/realm/SwiftLint/blob/main/Rules.md#cyclomatic-complexity
