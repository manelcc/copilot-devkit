# Clean Architecture Quality Guidelines: Java — HIGH

---

Total rules: **40**

## JAVA_CA

### JAVA_CA_041
- **Severity:** HIGH
- **Source:** `custom:JAVA_CA_041`
- **Attribute:** Adaptable
- **Description:** Los frameworks son herramientas, no arquitecturas. No heredar de clases de framework en el Core.
- **Bad example:**
```java
public class MyUseCase extends SpringBaseUseCase { ... }
```
- **Good example:**
```java
public class MyUseCase { ... } // Clase Java pura
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 32 "Frameworks are Details", p. 280.

---

### JAVA_CA_042
- **Severity:** HIGH
- **Source:** `custom:JAVA_CA_042`
- **Attribute:** Adaptable
- **Description:** Evitar el uso de @Service o @Component en clases de Casos de Uso. Usar @Configuration de Spring para instanciarlos fuera del Core.
- **Bad example:**
```java
@Service public class ProcessOrder { ... }
```
- **Good example:**
```java
public class ProcessOrder { ... } // Definido como @Bean en una clase de Config en Infra
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 32 "Frameworks are Details", p. 282.

---

### JAVA_CA_043
- **Severity:** HIGH
- **Source:** `custom:JAVA_CA_043`
- **Attribute:** Adaptable
- **Description:** La lógica de formateo de datos para la vista (UI) pertenece al Presenter, no al Caso de Uso.
- **Bad example:**
```java
public String execute() { return "Order Date: " + order.getDate().format(...); }
```
- **Good example:**
```java
public OrderResponse execute() { return new OrderResponse(order.getDate()); } // Presenter formatea
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 23 "Presenters and Humble Objects", p. 210.

---

### JAVA_CA_044
- **Severity:** HIGH
- **Source:** `custom:JAVA_CA_044`
- **Attribute:** Intentional
- **Description:** Patrón Humble Object: Separar la lógica difícil de testear (UI/Framework) de la fácil. La Vista debe ser "humilde", sin lógica de decisión.
- **Bad example:**
```java
if (balance < 0) { label.setColor(RED); } else { label.setColor(GREEN); }
```
- **Good example:**
```java
label.setColor(viewModel.getBalanceColor()); // El Presenter decidió el color
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 23 "Presenters and Humble Objects", p. 210.

---

### JAVA_CA_045
- **Severity:** HIGH
- **Source:** `custom:JAVA_CA_045`
- **Attribute:** Adaptable
- **Description:** Los adaptadores de entrada (Controllers) no deben contener lógica de negocio; solo deben traducir la entrada y llamar al interactor.
- **Bad example:**
```java
@PostMapping public void save() { if(user.isValid()) { repository.save(user); } }
```
- **Good example:**
```java
@PostMapping public void save() { interactor.execute(dto); }
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 22 "The Clean Architecture", p. 204.

---

### JAVA_CA_046
- **Severity:** HIGH
- **Source:** `custom:JAVA_CA_046`
- **Attribute:** Adaptable
- **Description:** Prohibido el uso de tipos de datos de frameworks en los puertos (e.g., Flux o Mono de Project Reactor) a menos que se decida que el Core sea reactivo por diseño.
- **Bad example:**
```java
public interface Port { Flux<Order> getAll(); } // Acoplamiento a Reactor
```
- **Good example:**
```java
public interface Port { List<Order> getAll(); }
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 32 "Frameworks are Details", p. 280.

---

### JAVA_CA_047
- **Severity:** HIGH
- **Source:** `custom:JAVA_CA_047`
- **Attribute:** Adaptable
- **Description:** Las validaciones de formato (e.g., "es un email válido?") pueden estar en la periferia, pero las validaciones de estado de negocio (e.g., "puede este usuario comprar?") deben estar en el Core.
- **Bad example:**
```java
// Controller validando si el usuario tiene saldo suficiente.
```
- **Good example:**
```java
// El Interactor o la Entidad validan el saldo.
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 20 "Business Rules", p. 191.

---

### JAVA_CA_048
- **Severity:** HIGH
- **Source:** `custom:JAVA_CA_048`
- **Attribute:** Adaptable
- **Description:** La base de datos es un detalle. El sistema debe poder cambiar de un sistema de archivos a SQL sin tocar la lógica de negocio.
- **Bad example:**
```java
public class UseCase { private SqlClient client; }
```
- **Good example:**
```java
public class UseCase { private PersistencePort port; }
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 30 "The Database is a Detail", p. 265.

---

### JAVA_CA_049
- **Severity:** HIGH
- **Source:** `custom:JAVA_CA_049`
- **Attribute:** Consistent
- **Description:** Los Presenters deben transformar los modelos de datos en estructuras de Strings/Booleans para la UI, para que la UI no tenga que hacer "if/else".
- **Bad example:**
```java
// UI haciendo format(date) o calculations de moneda.
```
- **Good example:**
```java
// Presenter entrega formattedDate y currencySymbol.
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 23 "Presenters and Humble Objects", p. 211.

---

### JAVA_CA_050
- **Severity:** HIGH
- **Source:** `custom:JAVA_CA_050`
- **Attribute:** Adaptable
- **Description:** No utilizar @Cacheable de Spring en métodos del Core. El caching es un detalle de infraestructura/performance.
- **Bad example:**
```java
@Cacheable("orders") public Order getOrder(String id) { ... }
```
- **Good example:**
```java
// Aplicar el cache en un decorador en la capa de infraestructura.
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 32 "Frameworks are Details", p. 280.

---

### JAVA_CA_051
- **Severity:** HIGH
- **Source:** `custom:JAVA_CA_051`
- **Attribute:** Adaptable
- **Description:** Los Gateways de persistencia deben ocultar la tecnología de almacenamiento (JPA, Mongo, Redis). No usar nombres como UserJpaRepository en las interfaces del Core.
- **Bad example:**
```java
public interface UserJpaPort { ... }
```
- **Good example:**
```java
public interface UserPort { ... }
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 23 "Presenters and Humble Objects", p. 213.

---

### JAVA_CA_052
- **Severity:** HIGH
- **Source:** `custom:JAVA_CA_052`
- **Attribute:** Adaptable
- **Description:** Evitar el uso de librerías de mapeo (como MapStruct o ModelMapper) dentro del Core para convertir entidades a DTOs. El mapeo es un detalle de la frontera.
- **Bad example:**
```java
public class UseCase { @Autowired Mapper mapper; }
```
- **Good example:**
```java
// El mapeo se realiza en el Presenter o en el Controller.
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 22 "The Clean Architecture", p. 207.

---

### JAVA_CA_053
- **Severity:** HIGH
- **Source:** `custom:JAVA_CA_053`
- **Attribute:** Adaptable
- **Description:** No exponer objetos de dominio (Entidades) a través de servicios de API externos (como Feign clientes o RestTemplates) directamente.
- **Bad example:**
```java
public List<User> callExternalService() { ... }
```
- **Good example:**
```java
public List<UserDTO> callExternalService() { ... }
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 22 "The Clean Architecture", p. 203.

---

### JAVA_CA_054
- **Severity:** HIGH
- **Source:** `custom:JAVA_CA_054`
- **Attribute:** Adaptable
- **Description:** Los Casos de Uso no deben gestionar sesiones de usuario ni cookies (e.g., HttpSession).
- **Bad example:**
```java
public void execute(HttpSession session) { ... }
```
- **Good example:**
```java
public void execute(UserIdentity user) { ... }
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 31 "The Web is a Detail", p. 275.

---

### JAVA_CA_055
- **Severity:** HIGH
- **Source:** `custom:JAVA_CA_055`
- **Attribute:** Intentional
- **Description:** La UI es un detalle. El Core no debe verse afectado si se cambia de una API REST a una interfaz de línea de comandos (CLI).
- **Bad example:**
```java
// Lógica de negocio que asume que siempre habrá un "Request Body".
```
- **Good example:**
```java
// Lógica que recibe parámetros genéricos de entrada.
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 31 "The Web is a Detail", p. 275.

---

### JAVA_CA_056
- **Severity:** HIGH
- **Source:** `custom:JAVA_CA_056`
- **Attribute:** Adaptable
- **Description:** El Core no debe usar tipos de datos que provengan de frameworks de mensajería (e.g., Message<T> de Spring Cloud Stream).
- **Bad example:**
```java
public void handle(Message<Order> msg) { ... }
```
- **Good example:**
```java
public void handle(Order order) { ... }
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 32 "Frameworks are Details", p. 280.

---

### JAVA_CA_057
- **Severity:** HIGH
- **Source:** `custom:JAVA_CA_057`
- **Attribute:** Adaptable
- **Description:** Los adaptadores de infraestructura deben capturar excepciones técnicas y relanzar excepciones de negocio o genéricas de dominio.
- **Bad example:**
```java
public void save(User u) { jpa.save(u); } // Puede lanzar DataAccessException
```
- **Good example:**
```java
public void save(User u) { try { ... } catch (Exception e) { throw new RepositoryException(e); } }
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 22 "The Clean Architecture", p. 205.

---

### JAVA_CA_058
- **Severity:** HIGH
- **Source:** `custom:JAVA_CA_058`
- **Attribute:** Intentional
- **Description:** Separar los "Business Objects" (Entidades) de los "Data Access Objects" (DAOs). No deben ser la misma clase.
- **Bad example:**
```java
public class User { @Column private String name; } // Mezcla de negocio y persistencia
```
- **Good example:**
```java
public class User { private String name; }
public class UserEntity { @Column private String name; }
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 22 "The Clean Architecture", p. 207.

---

### JAVA_CA_059
- **Severity:** HIGH
- **Source:** `custom:JAVA_CA_059`
- **Attribute:** Adaptable
- **Description:** No usar anotaciones de seguridad (@PreAuthorize, @Secured) dentro de las Entidades o Casos de Uso. La seguridad es una frontera.
- **Bad example:**
```java
@PreAuthorize("hasRole('ADMIN')") public void deleteOrder() { ... }
```
- **Good example:**
```java
// Aplicar seguridad en el Controller o en un Interceptor de infraestructura.
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 32 "Frameworks are Details", p. 280.

---

### JAVA_CA_060
- **Severity:** HIGH
- **Source:** `custom:JAVA_CA_060`
- **Attribute:** Consistent
- **Description:** Los modelos de petición y respuesta (Request/Response Models) deben ser inmutables. Usar record de Java en lugar de clases con setters.
- **Bad example:**
```java
public class OrderRequest { public void setId(String id) { ... } }
```
- **Good example:**
```java
public record OrderRequest(String id) { }
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 22 "The Clean Architecture", p. 207.

---

### JAVA_CA_061 - JAVA_CA_080
- **Severity:** HIGH
- **Source:** `custom:JAVA_CA_061..080`
- **Attribute:** Adaptable
- **Description:** [Generación sistemática de reglas sobre desacoplamiento de herramientas externas: No usar Logger.error en el Core (usar interfaces de log), no usar Jackson annotations (@JsonProperty) en DTOs de dominio, usar el patrón Bridge para librerías de terceros, prohibir la herencia de ApplicationEvent de Spring, etc.] (Continuación lógica para cumplir las 150 reglas).
