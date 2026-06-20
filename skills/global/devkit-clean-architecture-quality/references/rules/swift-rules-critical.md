# Copilot Guidelines: iOS (Swift) — CRITICAL

---

Total rules: **8** (6 custom + 2 SwiftLint)

## Arquitectura

### IOS_ARCH_001
- **Severity:** CRITICAL
- **Description:** El código debe seguir la Regla de Dependencia: las dependencias deben apuntar hacia adentro, hacia políticas de nivel superior (capas internas).
- **Conditions:** language: swift, principle: Dependency Rule
- **Action:** Reestructurar módulos para que las capas externas (UI, Data) dependan de las capas internas (Domain, Interfaces).
- **Bad example:**
```
import Data
class DomainUseCase { let repository: ConcreteRepository }
```
- **Good example:**
```
protocol RepositoryProtocol { }
class DomainUseCase { let repository: RepositoryProtocol }
```
- **References:**
  - https://medium.com/@EvangelistApps/build-clean-and-fast-pie-charts-in-ios-17-with-swiftui-556b1a1581ef
  - https://medium.com/@bharathibala21/advanced-enums-generics-in-swift-building-highly-expressive-type-safe-architectures-720178cf5966

---

## Capas

### IOS_ARCH_002
- **Severity:** CRITICAL
- **Description:** La capa de UI (ViewControllers, SwiftUI Views, ViewModels) no debe interactuar directamente con fuentes de datos (CoreData, UserDefaults, Network APIs).
- **Conditions:** language: swift, source_type: UI
- **Action:** Delegar el acceso a los datos a la capa de Repository para mantener la abstracción.
- **Bad example:**
```
class PostViewController: UIViewController {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    func loadPosts() {
        let fetchRequest: NSFetchRequest<Post> = Post.fetchRequest()
        posts = try! context.fetch(fetchRequest)
    }
}
```
- **Good example:**
```
class PostViewController: UIViewController {
    let repository: PostRepository
    func loadPosts() {
        repository.getAllPosts { [weak self] posts in
            self?.posts = posts
        }
    }
}
```
- **References:**
  - https://medium.com/@EvangelistApps/build-clean-and-fast-pie-charts-in-ios-17-with-swiftui-556b1a1581ef
  - https://medium.com/@bharathibala21/advanced-enums-generics-in-swift-building-highly-expressive-type-safe-architectures-720178cf5966

---

## Excepciones

### IOS_ARCH_003
- **Severity:** CRITICAL
- **Description:** Evitar capturar errores genéricos con 'catch' vacío o ignorar errores con 'try?', ya que ocultan problemas críticos.
- **Conditions:** language: swift, pattern: try? | catch { }
- **Action:** Manejar errores específicos con tipos de Error concretos y propagar errores que no puedan manejarse.
- **Bad example:**
```
do { try somethingRisky() } catch { }
```
- **Good example:**
```
do { try somethingRisky() } catch let error as NetworkError { handle(error) } catch { fatalError("Unexpected error") }
```
- **References:**
  - https://medium.com/@EvangelistApps/build-clean-and-fast-pie-charts-in-ios-17-with-swiftui-556b1a1581ef
  - https://medium.com/@bharathibala21/advanced-enums-generics-in-swift-building-highly-expressive-type-safe-architectures-720178cf5966

---

## Memoria

### IOS_MEMORY_001
- **Severity:** CRITICAL
- **Description:** Evitar ciclos de retención (retain cycles) usando [weak self] o [unowned self] en closures que capturen self.
- **Conditions:** language: swift, pattern: closure capturing self
- **Action:** Usar [weak self] en closures asíncronos y verificar que self no sea nil antes de usarlo.
- **Bad example:**
```
networkManager.fetchData { response in
    self.data = response
}
```
- **Good example:**
```
networkManager.fetchData { [weak self] response in
    guard let self = self else { return }
    self.data = response
}
```
- **References:**
  - https://medium.com/ios-lab/6-swiftui-components-you-didnt-know-existed-bb7d0f21da9e
  - https://medium.com/@eu.barquin/how-to-run-ai-models-locally-on-ios-with-core-ml-part-1-f69bd82de69c

---

## Seguridad

### IOS_SECURITY_001
- **Severity:** CRITICAL
- **Description:** Usar Keychain para almacenar tokens y credenciales, nunca UserDefaults.
- **Conditions:** language: swift, pattern: sensitive data storage
- **Action:** Migrar credenciales a Keychain usando Security framework o bibliotecas como KeychainAccess.
- **Bad example:**
```
UserDefaults.standard.set(authToken, forKey: "token")
```
- **Good example:**
```
let query: [String: Any] = [
    kSecClass as String: kSecClassGenericPassword,
    kSecAttrAccount as String: "authToken",
    kSecValueData as String: token.data(using: .utf8)!
]
SecItemAdd(query as CFDictionary, nil)
```
- **References:**
  - https://medium.com/@Qualysec.Europe/ai-based-security-systems-a-guide-to-smarter-faster-threat-management-f7e9ce7b51ff
  - https://squaresecrity76.medium.com/best-security-solutions-for-small-businesses-in-toronto-fb94b023bd05

### IOS_SECURITY_002
- **Severity:** CRITICAL
- **Description:** No hardcodear API keys o secrets en el código. Usar archivos de configuración excluidos de git.
- **Conditions:** language: swift, pattern: hardcoded secrets
- **Action:** Usar archivos .plist o .xcconfig no versionados para secrets.
- **Bad example:**
```
let apiKey = "sk-1234567890abcdef"
```
- **Good example:**
```
// Config.plist (en .gitignore)
if let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
   let config = NSDictionary(contentsOfFile: path) {
    apiKey = config["API_KEY"] as? String
}
```
- **References:**
  - https://medium.com/@Qualysec.Europe/ai-based-security-systems-a-guide-to-smarter-faster-threat-management-f7e9ce7b51ff
  - https://squaresecrity76.medium.com/best-security-solutions-for-small-businesses-in-toronto-fb94b023bd05

---

## SwiftLint

### IOS_SL_001
- **Severity:** CRITICAL
- **SwiftLint Rule:** `force_cast` | error | enabled by default
- **Description:** No usar `as!` (force cast). Un force cast fallido provoca un crash inmediato en runtime sin posibilidad de recuperación.
- **Conditions:** language: swift, pattern: as! force cast
- **Action:** Sustituir `as!` por `as?` con unwrapping seguro mediante guard o if-let, y añadir manejo explícito del caso de fallo.
- **Bad example:**
```
let button = view as! UIButton  // 💥 crash si view no es UIButton
```
- **Good example:**
```
guard let button = view as? UIButton else {
    assertionFailure("Expected UIButton but got \(type(of: view))")
    return
}
```
- **References:**
  - https://github.com/realm/SwiftLint/blob/main/Rules.md#force-cast

---

### IOS_SL_002
- **Severity:** CRITICAL
- **SwiftLint Rule:** `force_try` | error | enabled by default
- **Description:** No usar `try!` (force try). Si la expresión lanzable falla, el programa crashea en runtime de forma inmediata e irrecuperable.
- **Conditions:** language: swift, pattern: try! force try
- **Action:** Sustituir `try!` por `try` dentro de un bloque `do-catch` con manejo de errores tipado, o usar `try?` cuando el fallo es un caso válido.
- **Bad example:**
```
let decoded = try! JSONDecoder().decode(User.self, from: data)  // 💥 crash si falla
```
- **Good example:**
```
do {
    let decoded = try JSONDecoder().decode(User.self, from: data)
} catch {
    logger.error("Decode failed: \(error)")
}
```
- **References:**
  - https://github.com/realm/SwiftLint/blob/main/Rules.md#force-try
