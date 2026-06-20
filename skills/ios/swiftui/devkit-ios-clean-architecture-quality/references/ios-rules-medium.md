# Copilot Guidelines: iOS (Swift) — MEDIUM

---

Total rules: **46** (11 custom + 31 SonarQube + 4 SwiftLint)

## SwiftUI

### IOS_SWIFTUI_003
- **Severity:** MEDIUM
- **Description:** Evitar lógica compleja en el body de la View. Extraer a computed properties o métodos privados.
- **Conditions:** language: swift, framework: SwiftUI
- **Action:** Mantener body simple y legible, delegando lógica a properties o subviews.
- **Bad example:**
```
var body: some View {
    VStack {
        if user.isAdmin && settings.showAdminPanel && !isLoading {
            AdminPanel()
        }
    }
}
```
- **Good example:**
```
var body: some View {
    VStack {
        if shouldShowAdminPanel {
            AdminPanel()
        }
    }
}

private var shouldShowAdminPanel: Bool {
    user.isAdmin && settings.showAdminPanel && !isLoading
}
```
- **References:**
  - https://medium.com/ios-lab/6-swiftui-components-you-didnt-know-existed-bb7d0f21da9e
  - https://medium.com/%E5%BD%BC%E5%BE%97%E6%BD%98%E7%9A%84-swift-ios-app-%E9%96%8B%E7%99%BC%E5%95%8F%E9%A1%8C%E8%A7%A3%E7%AD%94%E9%9B%86/font-%E7%B8%AE%E6%94%BE%E5%AD%97%E9%AB%94%E7%9A%84-scaled-by-ios-26-%E6%96%B0%E5%8A%9F%E8%83%BD-bbf302a25f0b

---

## Codable

### IOS_CODABLE_001
- **Severity:** MEDIUM
- **Description:** Usar CodingKeys para mapear nombres JSON diferentes a propiedades Swift.
- **Conditions:** language: swift, pattern: Codable
- **Action:** Definir enum CodingKeys cuando los nombres JSON no coincidan con Swift conventions.
- **Bad example:**
```
struct User: Codable {
    let user_id: String // ⚠️ Snake case
    let first_name: String
}
```
- **Good example:**
```
struct User: Codable {
    let userId: String
    let firstName: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case firstName = "first_name"
    }
}
```
- **References:**
  - https://medium.com/ios-lab/6-swiftui-components-you-didnt-know-existed-bb7d0f21da9e
  - https://medium.com/@eu.barquin/how-to-run-ai-models-locally-on-ios-with-core-ml-part-1-f69bd82de69c

---

## Testing

### IOS_TESTING_002
- **Severity:** MEDIUM
- **Description:** No usar sleeps o waits arbitrarios en tests. Usar expectations de XCTest.
- **Conditions:** language: swift, framework: XCTest
- **Action:** Usar XCTestExpectation para código asíncrono.
- **Bad example:**
```
func testAsync() {
    viewModel.loadData()
    sleep(2)
    XCTAssertEqual(viewModel.data.count, 10)
}
```
- **Good example:**
```
func testAsync() {
    let expectation = expectation(description: "Load data")
    viewModel.loadData {
        XCTAssertEqual(self.viewModel.data.count, 10)
        expectation.fulfill()
    }
    wait(for: [expectation], timeout: 5)
}
```
- **References:**
  - https://medium.com/@bhumibhuva18/ui-integration-testing-in-swiftui-using-xctest-device-farms-1f018d13e7c3
  - https://medium.com/@mrhotfix/swift-6-result-type-xctest-error-handling-ios-18-functional-programming-developer-writing-33b5c1930730

---

## Performance

### IOS_PERF_001
- **Severity:** MEDIUM
- **Description:** Usar lazy var para propiedades costosas que no siempre se necesitan.
- **Conditions:** language: swift, pattern: expensive initialization
- **Action:** Marcar propiedades costosas como lazy para inicialización bajo demanda.
- **Bad example:**
```
class ViewController: UIViewController {
    let heavyObject = ExpensiveClass() // Se crea siempre
}
```
- **Good example:**
```
class ViewController: UIViewController {
    lazy var heavyObject = ExpensiveClass() // Solo se crea si se usa
}
```
- **References:**
  - https://medium.com/@brphzc/optimizing-ios-app-performance-and-memory-lessons-from-a-decade-of-development-9b5992d49e52
  - https://medium.com/@simon223397/swift-static-vs-dynamic-dispatches-performance-6a2926e5f012

### IOS_PERF_002
- **Severity:** MEDIUM
- **Description:** Usar cell reuse en UITableView/UICollectionView, no crear celdas nuevas cada vez.
- **Conditions:** language: swift, framework: UIKit
- **Action:** Usar dequeueReusableCell con identificadores registrados.
- **Bad example:**
```
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return CustomCell() // ⚠️ Crea nueva celda siempre
}
```
- **Good example:**
```
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath)
    return cell
}
```
- **References:**
  - https://medium.com/@brphzc/optimizing-ios-app-performance-and-memory-lessons-from-a-decade-of-development-9b5992d49e52
  - https://medium.com/@simon223397/swift-static-vs-dynamic-dispatches-performance-6a2926e5f012

---

## Optionals

### IOS_OPTIONALS_002
- **Severity:** MEDIUM
- **Description:** Usar nil coalescing (??) para valores por defecto en lugar de múltiples if-let.
- **Conditions:** language: swift, pattern: optional default value
- **Action:** Simplificar con operador ?? cuando solo se necesita un valor por defecto.
- **Bad example:**
```
let displayName: String
if let name = user.name {
    displayName = name
} else {
    displayName = "Guest"
}
```
- **Good example:**
```
let displayName = user.name ?? "Guest"
```
- **References:**
  - https://medium.com/ios-lab/6-swiftui-components-you-didnt-know-existed-bb7d0f21da9e
  - https://medium.com/@eu.barquin/how-to-run-ai-models-locally-on-ios-with-core-ml-part-1-f69bd82de69c

---

## Access Control

### IOS_ACCESS_001
- **Severity:** MEDIUM
- **Description:** Usar el nivel de acceso más restrictivo posible (private, fileprivate, internal, public, open).
- **Conditions:** language: swift
- **Action:** Marcar propiedades y métodos como private si solo se usan internamente.
- **Bad example:**
```
class ViewModel {
    var internalState: String = ""
    func helperMethod() { }
}
```
- **Good example:**
```
class ViewModel {
    private var internalState: String = ""
    private func helperMethod() { }
}
```
- **References:**
  - https://medium.com/ios-lab/6-swiftui-components-you-didnt-know-existed-bb7d0f21da9e
  - https://medium.com/@eu.barquin/how-to-run-ai-models-locally-on-ios-with-core-ml-part-1-f69bd82de69c

---

## Extensions

### IOS_EXTENSIONS_001
- **Severity:** MEDIUM
- **Description:** Usar extensions para organizar código por funcionalidad (conformance a protocolos, helpers, etc).
- **Conditions:** language: swift
- **Action:** Separar conformances de protocolo en extensions para mejor legibilidad.
- **Bad example:**
```
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // Todo mezclado
}
```
- **Good example:**
```
class ViewController: UIViewController { }

extension ViewController: UITableViewDelegate { }
extension ViewController: UITableViewDataSource { }
```
- **References:**
  - https://medium.com/ios-lab/6-swiftui-components-you-didnt-know-existed-bb7d0f21da9e
  - https://medium.com/@eu.barquin/how-to-run-ai-models-locally-on-ios-with-core-ml-part-1-f69bd82de69c

---

## Control Flow

### IOS_GUARD_001
- **Severity:** MEDIUM
- **Description:** Usar guard para validaciones early-return en lugar de if anidados.
- **Conditions:** language: swift, pattern: early return
- **Action:** Reemplazar if-else profundos con guard statements.
- **Bad example:**
```
func process(user: User?) {
    if let user = user {
        if user.isActive {
            if let email = user.email {
                sendEmail(email)
            }
        }
    }
}
```
- **Good example:**
```
func process(user: User?) {
    guard let user = user, user.isActive, let email = user.email else { return }
    sendEmail(email)
}
```
- **References:**
  - https://medium.com/ios-lab/6-swiftui-components-you-didnt-know-existed-bb7d0f21da9e
  - https://medium.com/@eu.barquin/how-to-run-ai-models-locally-on-ios-with-core-ml-part-1-f69bd82de69c

---

## Enums

### IOS_ENUM_001
- **Severity:** MEDIUM
- **Description:** Usar enums para estados finitos en lugar de múltiples booleans.
- **Conditions:** language: swift, pattern: state management
- **Action:** Reemplazar flags booleanos con enums que representen estados mutuamente excluyentes.
- **Bad example:**
```
var isLoading: Bool = false
var hasError: Bool = false
var isSuccess: Bool = false
```
- **Good example:**
```
enum ViewState {
    case idle
    case loading
    case success(Data)
    case error(Error)
}
var state: ViewState = .idle
```
- **References:**
  - https://medium.com/ios-lab/6-swiftui-components-you-didnt-know-existed-bb7d0f21da9e
  - https://medium.com/@eu.barquin/how-to-run-ai-models-locally-on-ios-with-core-ml-part-1-f69bd82de69c

---

## Value Types

### IOS_STRUCT_001
- **Severity:** MEDIUM
- **Description:** Preferir struct sobre class para tipos de datos simples sin identidad.
- **Conditions:** language: swift
- **Action:** Usar struct para modelos de datos, class para objetos con identidad y ciclo de vida.
- **Bad example:**
```
class User {
    let id: String
    let name: String
}
```
- **Good example:**
```
struct User {
    let id: String
    let name: String
}
// Usar class si necesitas herencia o identidad de referencia
```
- **References:**
  - https://medium.com/ios-lab/6-swiftui-components-you-didnt-know-existed-bb7d0f21da9e
  - https://medium.com/@eu.barquin/how-to-run-ai-models-locally-on-ios-with-core-ml-part-1-f69bd82de69c

---

## SonarQube — Code Style

### IOS_SQ_S122
- **Severity:** MEDIUM
- **Sonar Rule:** S122 | MAJOR | CODE_SMELL
- **Description:** No deben incluirse múltiples sentencias en la misma línea. Dificulta la legibilidad y el uso de herramientas de debugging.
- **Conditions:** language: swift
- **Action:** Separar cada sentencia en su propia línea.
- **Bad example:**
```
let x = 1; let y = 2; doSomething()
```
- **Good example:**
```
let x = 1
let y = 2
doSomething()
```
- **References:**
  - https://rules.sonarsource.com/swift/RSPEC-122/

### IOS_SQ_S125
- **Severity:** MEDIUM
- **Sonar Rule:** S125 | MAJOR | CODE_SMELL
- **Description:** Las secciones de código comentado no deben dejarse en el código fuente. Generan ruido, confunden a otros desarrolladores y deben gestionarse mediante control de versiones.
- **Conditions:** language: swift
- **Action:** Eliminar el código comentado. Si es necesario recuperarlo, usar git history.
- **Bad example:**
```
// func oldFetchUser() {
//     let url = URL(string: "api/old")!
//     URLSession.shared.dataTask(with: url) { ... }
// }
func fetchUser() { ... }
```
- **Good example:**
```
func fetchUser() { ... }
```
- **References:**
  - https://rules.sonarsource.com/swift/RSPEC-125/

### IOS_SQ_S1110
- **Severity:** MEDIUM
- **Sonar Rule:** S1110 | MAJOR | CODE_SMELL
- **Description:** Los paréntesis redundantes alrededor de expresiones deben eliminarse. Añaden ruido visual sin aportar claridad.
- **Conditions:** language: swift
- **Action:** Eliminar paréntesis innecesarios en condiciones y expresiones.
- **Bad example:**
```
if (isValid) { }
let result = (a + b)
return (value)
```
- **Good example:**
```
if isValid { }
let result = a + b
return value
```
- **References:**
  - https://rules.sonarsource.com/swift/RSPEC-1110/

### IOS_SQ_S1134
- **Severity:** MEDIUM
- **Sonar Rule:** S1134 | MAJOR | CODE_SMELL
- **Description:** Los tags FIXME en el código indican problemas conocidos sin resolver. Deben rastrearse en el sistema de tickets, no dejarse como comentarios.
- **Conditions:** language: swift, pattern: FIXME tag
- **Action:** Crear un ticket en el sistema de seguimiento y eliminar el tag FIXME, o resolver el problema inmediatamente.
- **Bad example:**
```
// FIXME: esto falla cuando el array está vacío
func processItems(_ items: [Item]) {
    let first = items[0]
}
```
- **Good example:**
```
func processItems(_ items: [Item]) {
    guard let first = items.first else { return }
    // ...
}
```
- **References:**
  - https://rules.sonarsource.com/swift/RSPEC-1134/

### IOS_SQ_S3358
- **Severity:** MEDIUM
- **Sonar Rule:** S3358 | MAJOR | CODE_SMELL
- **Description:** Los operadores ternarios no deben anidarse dentro de otros ternarios. Generan código extremadamente difícil de leer y mantener.
- **Conditions:** language: swift, pattern: nested ternary
- **Action:** Reemplazar ternarios anidados con if-else o guard explícitos.
- **Bad example:**
```
let label = isAdmin ? "Admin" : (isGuest ? "Guest" : "User")
```
- **Good example:**
```
let label: String
if isAdmin {
    label = "Admin"
} else if isGuest {
    label = "Guest"
} else {
    label = "User"
}
```
- **References:**
  - https://rules.sonarsource.com/swift/RSPEC-3358/

---

## SonarQube — Unused Code

### IOS_SQ_S1065
- **Severity:** MEDIUM
- **Sonar Rule:** S1065 | MAJOR | CODE_SMELL
- **Description:** Los casts redundantes no deben usarse. Hacer un cast a un tipo cuando el objeto ya es de ese tipo añade ruido y puede indicar un error de diseño.
- **Conditions:** language: swift
- **Action:** Eliminar casts innecesarios.
- **Bad example:**
```
let view = UIView()
let sameView = view as UIView // ⚠️ Cast redundante
```
- **Good example:**
```
let view = UIView()
// Usar view directamente
```
- **References:**
  - https://rules.sonarsource.com/swift/RSPEC-1065/

### IOS_SQ_S1144
- **Severity:** MEDIUM
- **Sonar Rule:** S1144 | MAJOR | CODE_SMELL
- **Description:** Los métodos privados no utilizados deben eliminarse. Aumentan el tamaño del código y generan confusión sobre qué código es relevante.
- **Conditions:** language: swift, access: private
- **Action:** Eliminar métodos privados que nunca son invocados.
- **Bad example:**
```
class ViewModel {
    private func oldLoadData() { // ⚠️ Nunca llamado
        // ...
    }
    func loadData() { ... }
}
```
- **Good example:**
```
class ViewModel {
    func loadData() { ... }
}
```
- **References:**
  - https://rules.sonarsource.com/swift/RSPEC-1144/

### IOS_SQ_S1172
- **Severity:** MEDIUM
- **Sonar Rule:** S1172 | MAJOR | CODE_SMELL
- **Description:** Los parámetros de función no utilizados deben eliminarse o reemplazarse con `_` para indicar que son intencionales.
- **Conditions:** language: swift
- **Action:** Eliminar el parámetro o usar `_` si debe mantenerse por conformance de protocolo.
- **Bad example:**
```
func processUser(_ user: User, context: Context) { // context nunca se usa
    user.activate()
}
```
- **Good example:**
```
func processUser(_ user: User, context _: Context) {
    user.activate()
}
```
- **References:**
  - https://rules.sonarsource.com/swift/RSPEC-1172/

### IOS_SQ_S1854
- **Severity:** MEDIUM
- **Sonar Rule:** S1854 | MAJOR | CODE_SMELL
- **Description:** Las asignaciones muertas (valores asignados a una variable pero nunca leídos antes de ser sobreescritos o descartados) deben eliminarse.
- **Conditions:** language: swift
- **Action:** Eliminar la asignación innecesaria o corregir la lógica para usar el valor asignado.
- **Bad example:**
```
var result = fetchData()  // ⚠️ Asignación muerta: se sobreescribe a continuación
result = processData()
return result
```
- **Good example:**
```
let result = processData()
return result
```
- **References:**
  - https://rules.sonarsource.com/swift/RSPEC-1854/

---

## SonarQube — Code Structure

### IOS_SQ_S107
- **Severity:** MEDIUM
- **Sonar Rule:** S107 | MAJOR | CODE_SMELL
- **Description:** Las funciones no deben tener más de 7 parámetros. Un número excesivo de parámetros indica que la función hace demasiado o que los parámetros deberían agruparse en un tipo.
- **Conditions:** language: swift, functionMax: 7, initializerMax: 7
- **Action:** Agrupar parámetros relacionados en una struct o usar el patrón Builder.
- **Bad example:**
```
func createUser(name: String, email: String, age: Int, role: Role,
                country: String, language: String, theme: Theme,
                notifications: Bool) { } // ⚠️ 8 parámetros
```
- **Good example:**
```
struct UserConfig {
    let name: String; let email: String; let age: Int
    let role: Role; let country: String; let language: String
    let theme: Theme; let notifications: Bool
}
func createUser(config: UserConfig) { }
```
- **References:**
  - https://rules.sonarsource.com/swift/RSPEC-107/

### IOS_SQ_S108
- **Severity:** MEDIUM
- **Sonar Rule:** S108 | MAJOR | CODE_SMELL
- **Description:** Los bloques de control anidados no deben dejarse vacíos sin un comentario justificativo.
- **Conditions:** language: swift
- **Action:** Implementar el bloque o añadir un comentario que explique por qué está vacío.
- **Bad example:**
```
for item in items {
    if item.isActive {
        // vacío
    }
}
```
- **Good example:**
```
for item in items where item.isActive {
    processItem(item)
}
```
- **References:**
  - https://rules.sonarsource.com/swift/RSPEC-108/

### IOS_SQ_S1066
- **Severity:** MEDIUM
- **Sonar Rule:** S1066 | MAJOR | CODE_SMELL
- **Description:** Los `if` anidados que pueden combinarse deben fusionarse en una sola condición compuesta para reducir el nivel de anidamiento.
- **Conditions:** language: swift
- **Action:** Combinar las condiciones usando `&&` o usar guard.
- **Bad example:**
```
if isLoggedIn {
    if hasPermission {
        showDashboard()
    }
}
```
- **Good example:**
```
if isLoggedIn && hasPermission {
    showDashboard()
}
```
- **References:**
  - https://rules.sonarsource.com/swift/RSPEC-1066/

### IOS_SQ_S1479
- **Severity:** MEDIUM
- **Sonar Rule:** S1479 | MAJOR | CODE_SMELL
- **Description:** Los `switch` no deben tener más de 30 casos. Un número excesivo de casos indica que la lógica debe refactorizarse usando tablas de datos, diccionarios o polimorfismo.
- **Conditions:** language: swift, Max: 30
- **Action:** Refactorizar con un diccionario, tabla de datos o patrón Strategy.
- **Bad example:**
```
switch errorCode { // ⚠️ Más de 30 casos
case 1: ...
case 2: ...
// ... 30+ casos
}
```
- **Good example:**
```
let handlers: [Int: () -> Void] = [
    1: handleNotFound,
    2: handleUnauthorized,
    // ...
]
handlers[errorCode]?()
```
- **References:**
  - https://rules.sonarsource.com/swift/RSPEC-1479/

---

## SonarQube — Naming

### IOS_SQ_S1117
- **Severity:** MEDIUM
- **Sonar Rule:** S1117 | MAJOR | CODE_SMELL
- **Description:** Las variables locales no deben ocultar (shadow) propiedades de la clase. Provoca confusión sobre qué valor se está utilizando en cada ámbito.
- **Conditions:** language: swift
- **Action:** Renombrar la variable local para evitar el shadowing.
- **Bad example:**
```
class UserViewModel {
    var username: String = ""
    
    func updateProfile(username: String) { // ⚠️ Oculta self.username
        print(username) // ¿Local o propiedad?
    }
}
```
- **Good example:**
```
class UserViewModel {
    var username: String = ""
    
    func updateProfile(newUsername: String) {
        self.username = newUsername
    }
}
```
- **References:**
  - https://rules.sonarsource.com/swift/RSPEC-1117/

### IOS_SQ_S1700
- **Severity:** MEDIUM
- **Sonar Rule:** S1700 | MAJOR | CODE_SMELL
- **Description:** Una propiedad no debe tener el mismo nombre que el tipo que la contiene. Genera ambigüedad y confusión en el acceso.
- **Conditions:** language: swift
- **Action:** Renombrar la propiedad para que sea descriptiva de su propósito, no del tipo.
- **Bad example:**
```
class Cart {
    var cart: [Item] = [] // ⚠️ Igual que el nombre del tipo
}
```
- **Good example:**
```
class Cart {
    var items: [Item] = []
}
```
- **References:**
  - https://rules.sonarsource.com/swift/RSPEC-1700/

---

## SonarQube — Bug Patterns

### IOS_SQ_S1751
- **Severity:** MEDIUM
- **Sonar Rule:** S1751 | MAJOR | BUG
- **Description:** Los bucles cuyo cuerpo contiene siempre un `return`, `break` o `throw` en la primera iteración deben refactorizarse. El bucle es efectivamente innecesario.
- **Conditions:** language: swift
- **Action:** Refactorizar para eliminar el bucle o usar `first(where:)` si se busca un elemento.
- **Bad example:**
```
for item in items {
    return item.id // ⚠️ Siempre retorna en la primera iteración
}
```
- **Good example:**
```
return items.first?.id
```
- **References:**
  - https://rules.sonarsource.com/swift/RSPEC-1751/

### IOS_SQ_S1763
- **Severity:** MEDIUM
- **Sonar Rule:** S1763 | MAJOR | BUG
- **Description:** El código después de un `return`, `throw`, `break` o `continue` es inalcanzable y nunca se ejecutará. Indica un error lógico.
- **Conditions:** language: swift
- **Action:** Eliminar el código inalcanzable o corregir la lógica.
- **Bad example:**
```
func resolve() -> String {
    return "done"
    Logger.log("resolved") // ⚠️ Código inalcanzable
}
```
- **Good example:**
```
func resolve() -> String {
    Logger.log("resolved")
    return "done"
}
```
- **References:**
  - https://rules.sonarsource.com/swift/RSPEC-1763/

### IOS_SQ_S1764
- **Severity:** MEDIUM
- **Sonar Rule:** S1764 | MAJOR | BUG
- **Description:** Las expresiones idénticas no deben usarse en ambos lados de un operador binario. Casi siempre indica un error de copia-pega.
- **Conditions:** language: swift
- **Action:** Verificar si ambas expresiones deben ser diferentes o eliminar la redundancia.
- **Bad example:**
```
if userId == userId { } // ⚠️ Siempre true
let result = value / value // ⚠️ Siempre 1
```
- **Good example:**
```
if userId == expectedId { }
let result = numerator / denominator
```
- **References:**
  - https://rules.sonarsource.com/swift/RSPEC-1764/

### IOS_SQ_S1862
- **Severity:** MEDIUM
- **Sonar Rule:** S1862 | MAJOR | BUG
- **Description:** Las ramas `if/else if` relacionadas no deben tener la misma condición. La segunda rama con la misma condición nunca se ejecutará.
- **Conditions:** language: swift
- **Action:** Corregir la condición duplicada o eliminar la rama redundante.
- **Bad example:**
```
if status == .active {
    handleActive()
} else if status == .active { // ⚠️ Condición duplicada, nunca se ejecuta
    handleActiveAgain()
}
```
- **Good example:**
```
if status == .active {
    handleActive()
} else if status == .pending {
    handlePending()
}
```
- **References:**
  - https://rules.sonarsource.com/swift/RSPEC-1862/

### IOS_SQ_S1871
- **Severity:** MEDIUM
- **Sonar Rule:** S1871 | MAJOR | CODE_SMELL
- **Description:** Dos ramas de una estructura condicional no deben tener exactamente la misma implementación. O es código duplicado o una de las ramas es incorrecta.
- **Conditions:** language: swift
- **Action:** Unificar las ramas o corregir la implementación de la rama incorrecta.
- **Bad example:**
```
if isPremium {
    showContent()
    trackEvent("view")
} else {
    showContent()    // ⚠️ Implementación idéntica
    trackEvent("view")
}
```
- **Good example:**
```
showContent()
trackEvent("view")
```
- **References:**
  - https://rules.sonarsource.com/swift/RSPEC-1871/

### IOS_SQ_S2201
- **Severity:** MEDIUM
- **Sonar Rule:** S2201 | MAJOR | BUG
- **Description:** Los valores de retorno de funciones sin efectos secundarios no deben ignorarse. Ignorarlos probablemente indica un error lógico.
- **Conditions:** language: swift
- **Action:** Usar el valor de retorno o usar `@discardableResult` si el ignore es intencional.
- **Bad example:**
```
array.sorted() // ⚠️ El resultado se ignora; sorted() no modifica el array
"hello".uppercased() // ⚠️ Sin efecto
```
- **Good example:**
```
let sorted = array.sorted()
let uppercased = "hello".uppercased()
```
- **References:**
  - https://rules.sonarsource.com/swift/RSPEC-2201/

### IOS_SQ_S3923
- **Severity:** MEDIUM
- **Sonar Rule:** S3923 | MAJOR | BUG
- **Description:** Todas las ramas de una estructura condicional no deben tener exactamente la misma implementación. Si todas hacen lo mismo, la condición es innecesaria.
- **Conditions:** language: swift
- **Action:** Eliminar la condición o corregir la implementación de alguna de las ramas.
- **Bad example:**
```
if networkAvailable {
    fetchData()
    updateUI()
} else {
    fetchData()  // ⚠️ Todas las ramas son idénticas
    updateUI()
}
```
- **Good example:**
```
fetchData()
updateUI()
```
- **References:**
  - https://rules.sonarsource.com/swift/RSPEC-3923/

### IOS_SQ_S3981
- **Severity:** MEDIUM
- **Sonar Rule:** S3981 | MAJOR | BUG
- **Description:** El tamaño de una colección o array no debe compararse con valores negativos. `count` siempre es >= 0, por lo que la comparación siempre será `true` o `false`.
- **Conditions:** language: swift
- **Action:** Corregir la comparación usando `isEmpty` o comparando con 0.
- **Bad example:**
```
if items.count >= 0 { } // ⚠️ Siempre true
if items.count < 0 { }  // ⚠️ Siempre false
```
- **Good example:**
```
if !items.isEmpty { }
if items.count > 0 { }
```
- **References:**
  - https://rules.sonarsource.com/swift/RSPEC-3981/

### IOS_SQ_S4143
- **Severity:** MEDIUM
- **Sonar Rule:** S4143 | MAJOR | BUG
- **Description:** Los valores en colecciones (diccionarios, sets) no deben reemplazarse incondicionalmente con la misma clave. La primera inserción se pierde siempre.
- **Conditions:** language: swift
- **Action:** Revisar la lógica de inserción; probablemente una de las asignaciones es incorrecta.
- **Bad example:**
```
var config: [String: String] = [:]
config["timeout"] = "30"
config["timeout"] = "60" // ⚠️ La primera asignación se pierde siempre
```
- **Good example:**
```
var config: [String: String] = [:]
config["connectTimeout"] = "30"
config["readTimeout"] = "60"
```
- **References:**
  - https://rules.sonarsource.com/swift/RSPEC-4143/

### IOS_SQ_S4144
- **Severity:** MEDIUM
- **Sonar Rule:** S4144 | MAJOR | CODE_SMELL
- **Description:** Los métodos no deben tener implementaciones idénticas a otro método existente. Indica código duplicado que debería factorizarse.
- **Conditions:** language: swift
- **Action:** Extraer la implementación común a un método compartido o eliminar el duplicado.
- **Bad example:**
```
func handleSuccess(_ data: Data) {
    parse(data)
    updateUI()
}

func handleRetry(_ data: Data) { // ⚠️ Implementación idéntica
    parse(data)
    updateUI()
}
```
- **Good example:**
```
func processResponse(_ data: Data) {
    parse(data)
    updateUI()
}
```
- **References:**
  - https://rules.sonarsource.com/swift/RSPEC-4144/

---

## SonarQube — Swift-Specific

### IOS_SQ_S2960
- **Severity:** MEDIUM
- **Sonar Rule:** S2960 | MAJOR | CODE_SMELL
- **Description:** Los opcionales no deben compararse con `nil` usando `==` o `!=`. En Swift, es preferible usar pattern matching con `if let`, `guard let` o `?.` para mayor claridad e idiomatismo.
- **Conditions:** language: swift, pattern: optional nil comparison
- **Action:** Reemplazar comparaciones `== nil` con optional binding o `?.`.
- **Bad example:**
```
if user.email != nil {
    sendEmail(user.email!)
}
```
- **Good example:**
```
if let email = user.email {
    sendEmail(email)
}
```
- **References:**
  - https://rules.sonarsource.com/swift/RSPEC-2960/

### IOS_SQ_S2961
- **Severity:** MEDIUM
- **Sonar Rule:** S2961 | MAJOR | CODE_SMELL
- **Description:** Los tipos opcionales anidados (`Optional<Optional<T>>` o `T??`) no deben usarse. Son difíciles de desencadenar correctamente y generan comportamientos inesperados.
- **Conditions:** language: swift, pattern: nested optional
- **Action:** Aplanar el opcional anidado o rediseñar la estructura de datos.
- **Bad example:**
```
var name: String?? = "Alice" // ⚠️ Optional anidado
if let outer = name, let inner = outer {
    print(inner)
}
```
- **Good example:**
```
var name: String? = "Alice"
if let name = name {
    print(name)
}
```
- **References:**
  - https://rules.sonarsource.com/swift/RSPEC-2961/

### IOS_SQ_S3083
- **Severity:** MEDIUM
- **Sonar Rule:** S3083 | MAJOR | BUG
- **Description:** Las condiciones de un `guard` o `if` que siempre evalúan al mismo valor hacen que una rama sea permanentemente inalcanzable.
- **Conditions:** language: swift
- **Action:** Revisar las condiciones de control de flujo y eliminar las invariantes.
- **Bad example:**
```
let isEnabled = true
guard isEnabled else { // ⚠️ La cláusula else nunca se ejecuta
    return
}
```
- **Good example:**
```
func process(isEnabled: Bool) {
    guard isEnabled else { return }
    // ...
}
```
- **References:**
  - https://rules.sonarsource.com/swift/RSPEC-3083/

### IOS_SQ_S3087
- **Severity:** MEDIUM
- **Sonar Rule:** S3087 | MAJOR | CODE_SMELL
- **Description:** Los getters y setters de una propiedad deben acceder al campo esperado asociado a esa propiedad, no a un campo diferente (máximo 2 campos distintos).
- **Conditions:** language: swift, max: 2 distinct fields
- **Action:** Asegurarse de que el getter devuelve y el setter modifica la propiedad correcta.
- **Bad example:**
```
class Config {
    private var _timeout: Int = 30
    private var _retries: Int = 3
    var timeout: Int {
        get { return _retries } // ⚠️ Getter devuelve el campo equivocado
        set { _timeout = newValue }
    }
}
```
- **Good example:**
```
class Config {
    private var _timeout: Int = 30
    var timeout: Int {
        get { return _timeout }
        set { _timeout = newValue }
    }
}
```
- **References:**
  - https://rules.sonarsource.com/swift/RSPEC-3087/

### IOS_SQ_S3110
- **Severity:** MEDIUM
- **Sonar Rule:** S3110 | MAJOR | CODE_SMELL
- **Description:** Los módulos deben importarse de forma explícita y específica. Las importaciones innecesarias o duplicadas de módulos incrementan el tiempo de compilación y ocultan dependencias reales.
- **Conditions:** language: swift
- **Action:** Eliminar importaciones duplicadas o innecesarias. Importar solo los módulos realmente utilizados.
- **Bad example:**
```
import Foundation
import Foundation // ⚠️ Importación duplicada
import UIKit
import Foundation // ⚠️ Tercera importación de Foundation
```
- **Good example:**
```
import Foundation
import UIKit
```
- **References:**
  - https://rules.sonarsource.com/swift/RSPEC-3110/

### IOS_SQ_S4186
- **Severity:** MEDIUM
- **Sonar Rule:** S4186 | MAJOR | CODE_SMELL
- **Description:** Los opcionales deben desencadenarse de forma segura usando `if let`, `guard let` o `??`. Comparar con `nil` explícitamente antes de usar force unwrap sigue siendo peligroso si hay concurrencia.
- **Conditions:** language: swift, pattern: optional unwrapping
- **Action:** Usar optional binding o nil-coalescing en lugar de combinar comprobación con force unwrap.
- **Bad example:**
```
if optional != nil {
    useValue(optional!) // ⚠️ Force unwrap tras comparación explícita
}
```
- **Good example:**
```
if let value = optional {
    useValue(value) // ✅ Seguro y idiomático
}
```
- **References:**
  - https://rules.sonarsource.com/swift/RSPEC-4186/

---

## SwiftLint

### IOS_SL_004
- **Severity:** MEDIUM
- **SwiftLint Rule:** `force_unwrapping` | warning | opt-in (no habilitado por defecto)
- **Description:** No usar `!` para desempaquetar opcionales salvo en @IBOutlet o contextos donde nil es imposible en tiempo de ejecución. Un force-unwrap sobre nil crashea la app.
- **Conditions:** language: swift, pattern: optional force unwrap (!)
- **Action:** Usar guard-let, if-let o ?? para desempaquetar opcionales de forma segura.
- **Bad example:**
```
let name = user.name!         // 💥 crash si name es nil
let url = URL(string: path)!  // 💥 crash si path es inválida
```
- **Good example:**
```
guard let name = user.name else { return }
guard let url = URL(string: path) else { return }
```
- **References:**
  - https://github.com/realm/SwiftLint/blob/main/Rules.md#force-unwrapping

---

### IOS_SL_005
- **Severity:** MEDIUM
- **SwiftLint Rule:** `function_body_length` | warning (> 40 líneas) | enabled by default
- **Description:** El cuerpo de una función no debe superar 40 líneas (warning) ni 100 líneas (error). Las funciones largas mezclan responsabilidades y dificultan el testing unitario.
- **Conditions:** language: swift, pattern: function body > 40 lines
- **Action:** Extraer bloques lógicos en métodos privados con nombre descriptivo aplicando Single Responsibility Principle.
- **Bad example:**
```
func setup() {
    // 80 líneas mezclando UI, red y lógica de negocio
}
```
- **Good example:**
```
func setup() {
    setupUI()
    bindViewModel()
    configureNavigationBar()
}

private func setupUI() { ... }
private func bindViewModel() { ... }
private func configureNavigationBar() { ... }
```
- **References:**
  - https://github.com/realm/SwiftLint/blob/main/Rules.md#function-body-length

---

### IOS_SL_006
- **Severity:** MEDIUM
- **SwiftLint Rule:** `file_length` | warning (> 400 líneas) | enabled by default
- **Description:** Un fichero Swift no debe superar 400 líneas (warning) ni 1000 líneas (error). Los ficheros excesivos indican violación del Single Responsibility Principle.
- **Conditions:** language: swift, pattern: file > 400 lines
- **Action:** Dividir el fichero en múltiples tipos o extensiones con responsabilidades separadas; mover conformances de protocolo a extensiones en ficheros dedicados.
- **Bad example:**
```
// UserViewController.swift — 600 líneas
// Mezcla de UI, networking, CoreData y lógica de negocio
```
- **Good example:**
```
// UserViewController.swift               — UIViewController principal
// UserViewController+TableView.swift    — UITableViewDelegate/DataSource
// UserViewController+Networking.swift  — lógica de llamadas de red
```
- **References:**
  - https://github.com/realm/SwiftLint/blob/main/Rules.md#file-length

---

### IOS_SL_007
- **Severity:** MEDIUM
- **SwiftLint Rule:** `todo` | warning | enabled by default
- **Description:** No dejar comentarios `// TODO:` en código productivo. Representan deuda técnica no registrada que puede llegar inadvertidamente a producción. Nota: los tags `// FIXME:` están cubiertos por SonarQube `IOS_SQ_S1134`.
- **Conditions:** language: swift, pattern: TODO comment
- **Action:** Convertir los TODOs en tickets de backlog, resolverlos antes del merge o eliminarlos, según la política del equipo.
- **Bad example:**
```
func calculateTotal() -> Double {
    // TODO: aplicar descuentos
    return subtotal
}
```
- **Good example:**
```
// Ticket: PROJ-234 — implementar descuentos antes del release
func calculateTotal() -> Double {
    return applyDiscounts(to: subtotal)
}
```
- **References:**
  - https://github.com/realm/SwiftLint/blob/main/Rules.md#todo
