# Copilot Guidelines: iOS (Swift) — LOW

---

Total rules: **6** (2 custom + 1 SonarQube + 3 SwiftLint)

## Naming

### IOS_NAMING_001
- **Severity:** LOW
- **Description:** Seguir Swift naming conventions: camelCase para variables/funciones, PascalCase para tipos.
- **Conditions:** language: swift
- **Action:** Renombrar identificadores para seguir convenciones de Swift.
- **Bad example:**
```
let user_name: String
func FetchData() { }
```
- **Good example:**
```
let userName: String
func fetchData() { }
```
- **References:**
  - https://medium.com/ios-lab/6-swiftui-components-you-didnt-know-existed-bb7d0f21da9e
  - https://medium.com/@eu.barquin/how-to-run-ai-models-locally-on-ios-with-core-ml-part-1-f69bd82de69c

### IOS_NAMING_002
- **Severity:** LOW
- **Description:** Usar nombres descriptivos y evitar abreviaturas no obvias.
- **Conditions:** language: swift
- **Action:** Expandir abreviaturas y usar nombres que describan el propósito.
- **Bad example:**
```
let usrMgr = UserManager()
func proc() { }
```
- **Good example:**
```
let userManager = UserManager()
func processUserData() { }
```
- **References:**
  - https://medium.com/ios-lab/6-swiftui-components-you-didnt-know-existed-bb7d0f21da9e
  - https://medium.com/@eu.barquin/how-to-run-ai-models-locally-on-ios-with-core-ml-part-1-f69bd82de69c

---

## SonarQube — Security Awareness

### IOS_SQ_S1313
- **Severity:** LOW
- **Sonar Rule:** S1313 | MINOR | SECURITY_HOTSPOT
- **Description:** Las direcciones IP hardcodeadas en el código son un hotspot de seguridad. Dificultan los cambios de infraestructura y pueden exponer información sobre la arquitectura interna.
- **Conditions:** language: swift, pattern: hardcoded IP address
- **Action:** Mover las IPs a archivos de configuración externos o usar nombres de host DNS resolubles.
- **Bad example:**
```
let serverURL = "http://192.168.1.100:8080/api" // ⚠️ IP hardcodeada
let backupServer = "10.0.0.5"
```
- **Good example:**
```
// Config.plist o .xcconfig no versionado
let serverURL = Configuration.apiBaseURL
```
- **References:**
  - https://rules.sonarsource.com/swift/RSPEC-1313/

---

## SwiftLint

### IOS_SL_008
- **Severity:** LOW
- **SwiftLint Rule:** `line_length` | warning (> 120 caracteres) | enabled by default
- **Description:** Las líneas de código no deben superar 120 caracteres (warning). Las líneas largas dificultan la revisión side-by-side en pull requests y en monitores estándar.
- **Conditions:** language: swift, pattern: line length > 120 characters
- **Action:** Partir la línea en formato multilínea, extraer subexpresiones en variables locales con nombre o usar trailing closure syntax.
- **Bad example:**
```
let result = someObject.someMethod(withParameter: aVeryLongParameterName, andAnother: anotherVeryLongParameter, finally: lastParam)
```
- **Good example:**
```
let result = someObject.someMethod(
    withParameter: aVeryLongParameterName,
    andAnother: anotherVeryLongParameter,
    finally: lastParam
)
```
- **References:**
  - https://github.com/realm/SwiftLint/blob/main/Rules.md#line-length

---

### IOS_SL_009
- **Severity:** LOW
- **SwiftLint Rule:** `mark` | warning | enabled by default
- **Description:** Los comentarios `// MARK:` deben seguir el formato exacto reconocido por Xcode y SwiftLint. Un formato incorrecto es ignorado silenciosamente por las herramientas de navegación.
- **Conditions:** language: swift, pattern: MARK comment format
- **Action:** Usar `// MARK: - Nombre` (con guión y espacio) para separadores de sección, y `// MARK: Descripción` para anotaciones simples.
- **Bad example:**
```
//MARK: Setup           // sin espacio después de //
// Mark: - Lifecycle   // 'M' minúscula
// MARK:- Init         // sin espacio después de los dos puntos
```
- **Good example:**
```
// MARK: - Lifecycle
// MARK: - Setup
// MARK: Helpers
```
- **References:**
  - https://github.com/realm/SwiftLint/blob/main/Rules.md#mark

---

### IOS_SL_010
- **Severity:** LOW
- **SwiftLint Rule:** `trailing_whitespace` | warning | enabled by default
- **Description:** Las líneas no deben terminar con espacios en blanco. Los espacios finales generan ruido en diffs y pueden causar conflictos de merge innecesarios.
- **Conditions:** language: swift, pattern: trailing whitespace
- **Action:** Configurar Xcode (Preferences → Text Editing → Editing → "Trim trailing whitespace") o un pre-commit hook para eliminar automáticamente los espacios finales.
- **Bad example:**
```
let value = 42   // ← espacios invisibles al final de línea
```
- **Good example:**
```
let value = 42
```
- **References:**
  - https://github.com/realm/SwiftLint/blob/main/Rules.md#trailing-whitespace
