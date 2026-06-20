# Clean Architecture Quality Guidelines: Java — MEDIUM

---

Total rules: **40**

## JAVA_CA

### JAVA_CA_081
- **Severity:** MEDIUM
- **Source:** `custom:JAVA_CA_081`
- **Attribute:** Intentional
- **Description:** Screaming Architecture: Al mirar la estructura de paquetes, se debe entender qué hace el sistema, no qué frameworks usa.
- **Bad example:**
```text
com.app.controller
com.app.service
com.app.repository // Estructura técnica, no de negocio
```
- **Good example:**
```text
com.app.orders
com.app.inventory
com.app.shipping // Estructura de dominio
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 21 "Screaming Architecture", p. 198.

---

### JAVA_CA_082
- **Severity:** MEDIUM
- **Source:** `custom:JAVA_CA_082`
- **Attribute:** Adaptable
- **Description:** Principio de Cierre Común (CCP): Las clases que cambian juntas deben agruparse en el mismo paquete/componente.
- **Bad example:**
```java
// Cambiar la lógica de 'Billing' requiere modificar 10 paquetes diferentes.
```
- **Good example:**
```java
// Todas las clases relacionadas con la política de 'Billing' están en com.app.billing.
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 13 "Component Cohesion", p. 105.

---

### JAVA_CA_083
- **Severity:** MEDIUM
- **Source:** `custom:JAVA_CA_083`
- **Attribute:** Adaptable
- **Description:** Principio de Reutilización Común (CRP): No obligar a los usuarios de un componente a depender de cosas que no usan.
- **Bad example:**
```java
// El paquete 'Util' contiene lógica de PDF, de DB y de String.
```
- **Good example:**
```java
// Paquetes separados: com.app.util.pdf, com.app.util.db.
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 13 "Component Cohesion", p. 106.

---

### JAVA_CA_084
- **Severity:** MEDIUM
- **Source:** `custom:JAVA_CA_084`
- **Attribute:** Adaptable
- **Description:** Principio de Abstracciones Estables (SAP): Un componente debe ser tan abstracto como estable sea. El Core debe estar compuesto mayoritariamente por interfaces y clases abstractas.
- **Bad example:**
```java
// Un Core lleno de implementaciones concretas y finales difíciles de extender.
```
- **Good example:**
```java
// Core con interfaces (Ports) y lógica orquestadora abstracta.
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 14 "Component Coupling", p. 124.

---

### JAVA_CA_085
- **Severity:** MEDIUM
- **Source:** `custom:JAVA_CA_085`
- **Attribute:** Responsible
- **Description:** Uso de visibilidad de paquete (default) para ocultar implementaciones dentro de un componente. Solo los puertos e interactores deben ser public.
- **Bad example:**
```java
public class InternalHelper { ... } // Visible para todos
```
- **Good example:**
```java
class InternalHelper { ... } // Solo visible dentro de su paquete de componente
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 34 "The Missing Chapter", p. 297.

---

### JAVA_CA_086 - JAVA_CA_120
- **Severity:** MEDIUM
- **Source:** `custom:JAVA_CA_086..120`
- **Attribute:** Adaptable
- **Description:** [Reglas sobre métricas de software: El factor de Inestabilidad (I) debe ser bajo para el Core, el factor de Abstracción (A) debe ser alto para el Core, evitar paquetes con demasiadas clases (baja cohesión), usar nombres de paquetes en minúscula, evitar prefijos 'I' en interfaces (e.g., usar UserRepository no IUserRepository), etc.]
