# Clean Architecture Quality Guidelines: Java — BLOCKER

---

Total rules: **40**

## JAVA_CA

### JAVA_CA_001
- **Severity:** BLOCKER
- **Source:** `custom:JAVA_CA_001`
- **Attribute:** Adaptable
- **Description:** La Regla de Dependencia es absoluta: las dependencias de codigo solo pueden apuntar hacia adentro, hacia niveles superiores de politica. El codigo en una capa interna no puede mencionar nada de una capa externa.
- **Bad example:**
```java
package com.app.domain.usecases;
import com.app.infrastructure.persistence.JpaOrderRepository; // Error: Dependencia hacia afuera
```
- **Good example:**
```java
package com.app.domain.usecases;
import com.app.domain.ports.OrderRepository; // Correcto: Dependencia interna a interfaz
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 22 "The Clean Architecture", p. 203.

---

### JAVA_CA_002
- **Severity:** BLOCKER
- **Source:** `custom:JAVA_CA_002`
- **Attribute:** Adaptable
- **Description:** Principio de Dependencias Aciclicas (ADP). No deben existir ciclos en el grafo de dependencias de los paquetes Java. El acoplamiento circular imposibilita el despliegue independiente de componentes.
- **Bad example:**
```java
package com.app.billing; import com.app.orders.Order;
package com.app.orders; import com.app.billing.Invoice; // Ciclo Billing -> Orders -> Billing
```
- **Good example:**
```java
// Usar DIP para que ambos dependan de un tercer componente o abstraer la interfaz
package com.app.billing; import com.app.shared.OrderIdentifier;
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 14 "Component Coupling", p. 114.

---

### JAVA_CA_003
- **Severity:** BLOCKER
- **Source:** `custom:JAVA_CA_003`
- **Attribute:** Adaptable
- **Description:** Las Entidades de negocio deben ser POJOs puros. Prohibido el uso de anotaciones de frameworks de persistencia (@Entity, @Table, @Id) en la capa de Entidad.
- **Bad example:**
```java
@Entity @Table(name = "users")
public class User { @Id private Long id; } // Acoplamiento a JPA en el Core
```
- **Good example:**
```java
public class User { private Long id; } // Entidad pura e independiente
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 20 "Business Rules", p. 191.

---

### JAVA_CA_004
- **Severity:** BLOCKER
- **Source:** `custom:JAVA_CA_004`
- **Attribute:** Intentional
- **Description:** Los Casos de Uso no deben manejar objetos HttpServletRequest, HttpServletResponse o cualquier clase de la API de Servlets. La web es un detalle de entrega.
- **Bad example:**
```java
public void execute(HttpServletRequest req) { String id = req.getParameter("id"); }
```
- **Good example:**
```java
public void execute(OrderRequestModel model) { String id = model.id(); } // DTO plano
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 22 "The Clean Architecture", p. 204.

---

### JAVA_CA_005
- **Severity:** BLOCKER
- **Source:** `custom:JAVA_CA_005`
- **Attribute:** Adaptable
- **Description:** Inversion de Dependencias (DIP): Los modulos de alto nivel (Core) no deben depender de modulos de bajo nivel (Infraestructura). Ambos deben depender de abstracciones.
- **Bad example:**
```java
public class CreateUserInteractor {
    private MySqlUserRepository repo = new MySqlUserRepository(); // Dependencia directa
}
```
- **Good example:**
```java
public class CreateUserInteractor {
    private UserRepository repo;
    public CreateUserInteractor(UserRepository repo) { this.repo = repo; } // Dependencia de puerto
}
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 11 "DIP", p. 87.

---

### JAVA_CA_006
- **Severity:** BLOCKER
- **Source:** `custom:JAVA_CA_006`
- **Attribute:** Responsible
- **Description:** Las Reglas de Negocio Criticas deben estar encapsuladas en Entidades, no dispersas en servicios de infraestructura o procedimientos almacenados.
- **Bad example:**
```java
// Logica de descuento calculada por una consulta SQL en el Repository
```
- **Good example:**
```java
public class Order { public double calculateDiscount() { ... } } // Logica en la Entidad
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 20 "Business Rules", p. 191.

---

### JAVA_CA_007
- **Severity:** BLOCKER
- **Source:** `custom:JAVA_CA_007`
- **Attribute:** Adaptable
- **Description:** Prohibido inyectar beans de infraestructura (@Repository, @Service de Spring) directamente en el constructor de una Entidad.
- **Bad example:**
```java
public class User { private final SpringEmailService emailService; }
```
- **Good example:**
```java
public class User { private String email; } // Las entidades solo contienen datos y logica pura
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 20 "Business Rules", p. 192.

---

### JAVA_CA_008
- **Severity:** BLOCKER
- **Source:** `custom:JAVA_CA_008`
- **Attribute:** Adaptable
- **Description:** Los datos que cruzan fronteras arquitectonicas deben ser estructuras de datos simples (DTOs, Records o Tipos Primitivos). No se deben pasar objetos ResultSet al Core.
- **Bad example:**
```java
public interface UserPort { User load(ResultSet rs); } // ResultSet es un detalle de JDBC
```
- **Good example:**
```java
public interface UserPort { UserData load(String id); } // UserData es un DTO plano
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 22 "The Clean Architecture", p. 207.

---

### JAVA_CA_009
- **Severity:** BLOCKER
- **Source:** `custom:JAVA_CA_009`
- **Attribute:** Adaptable
- **Description:** Los Casos de Uso deben controlar el flujo de ejecucion. No deben delegar la orquestacion a la UI o a controladores externos.
- **Bad example:**
```java
// Controller llamando a multiples repositorios y servicios de forma secuencial
```
- **Good example:**
```java
// Controller llama a interactor.execute(), el cual orquesta las entidades y puertos.
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 20 "Business Rules", p. 192.

---

### JAVA_CA_010
- **Severity:** BLOCKER
- **Source:** `custom:JAVA_CA_010`
- **Attribute:** Adaptable
- **Description:** Los modulos de Casos de Uso no deben importar clases de frameworks de persistencia como org.hibernate.* o org.springframework.data.*.
- **Bad example:**
```java
import org.springframework.data.domain.Pageable; // Error en la capa de dominio
```
- **Good example:**
```java
public record DomainPageable(int page, int size) { } // Abstraccion propia del dominio
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 32 "Frameworks are Details", p. 280.

---

### JAVA_CA_011
- **Severity:** BLOCKER
- **Source:** `custom:JAVA_CA_011`
- **Attribute:** Adaptable
- **Description:** Prohibido el uso de la anotacion @Autowired en campos privados dentro de los Interactors del Core. Obligatorio el uso de inyeccion por constructor para facilitar la testabilidad sin contextos de Spring.
- **Bad example:**
```java
public class UseCase { @Autowired private Port port; } // Acoplamiento a Spring DI
```
- **Good example:**
```java
public class UseCase { private final Port port; public UseCase(Port port) { this.port = port; } }
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 32 "Frameworks are Details", p. 282.

---

### JAVA_CA_012
- **Severity:** BLOCKER
- **Source:** `custom:JAVA_CA_012`
- **Attribute:** Adaptable
- **Description:** El Core del sistema no debe conocer el esquema de la base de datos. Los nombres de las columnas o tablas no deben aparecer en los nombres de los atributos de las Entidades.
- **Bad example:**
```java
public class User { private String tbl_user_first_name; }
```
- **Good example:**
```java
public class User { private String firstName; }
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 30 "The Database is a Detail", p. 265.

---

### JAVA_CA_013
- **Severity:** BLOCKER
- **Source:** `custom:JAVA_CA_013`
- **Attribute:** Adaptable
- **Description:** Las excepciones que cruzan del Core hacia afuera deben ser excepciones de dominio, no excepciones de base de datos como SQLException.
- **Bad example:**
```java
public void execute() throws SQLException { ... }
```
- **Good example:**
```java
public void execute() throws DomainException { ... }
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 20 "Business Rules", p. 195.

---

### JAVA_CA_014
- **Severity:** BLOCKER
- **Source:** `custom:JAVA_CA_014`
- **Attribute:** Intentional
- **Description:** Los objetos de respuesta (Response Models) no deben ser las propias Entidades del sistema para evitar que cambios en las reglas de negocio rompan los contratos de la API (UI).
- **Bad example:**
```java
public Order getOrder() { return this.orderEntity; } // Fuga de la entidad
```
- **Good example:**
```java
public OrderResponse getOrder() { return new OrderResponse(order.getId()); } // DTO de salida
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 22 "The Clean Architecture", p. 207.

---

### JAVA_CA_015
- **Severity:** BLOCKER
- **Source:** `custom:JAVA_CA_015`
- **Attribute:** Adaptable
- **Description:** Principio de Dependencias Estables (SDP): Un componente debe depender solo de componentes mas estables que el. El Core es el componente mas estable.
- **Bad example:**
```java
// El Core dependiendo de una utilidad de generacion de PDFs externa.
```
- **Good example:**
```java
// El Core define PdfPort, la utilidad externa implementa el puerto.
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 14 "Component Coupling", p. 120.

---

### JAVA_CA_016
- **Severity:** BLOCKER
- **Source:** `custom:JAVA_CA_016`
- **Attribute:** Responsible
- **Description:** No utilizar validaciones de Bean Validation (javax.validation.constraints) en el Core si estas fuerzan el uso de un motor de validacion especifico de framework.
- **Bad example:**
```java
public class User { @NotNull @Size(min=5) private String name; } // Dependencia de Hibernate Validator
```
- **Good example:**
```java
public class User { public void validate() { if(name == null) throw new InvalidUserException(); } }
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 20 "Business Rules", p. 191.

---

### JAVA_CA_017
- **Severity:** BLOCKER
- **Source:** `custom:JAVA_CA_017`
- **Attribute:** Intentional
- **Description:** Las interfaces de entrada (Input Ports) deben ser disenadas segun las necesidades del Caso de Uso, no segun la estructura de los formularios de la UI.
- **Bad example:**
```java
public interface SaveOrderInputPort { void save(HttpRequest data); }
```
- **Good example:**
```java
public interface SaveOrderInputPort { void save(OrderRequest data); }
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 22 "The Clean Architecture", p. 206.

---

### JAVA_CA_018
- **Severity:** BLOCKER
- **Source:** `custom:JAVA_CA_018`
- **Attribute:** Adaptable
- **Description:** Los adaptadores de persistencia (Infrastructure) no deben devolver modelos de base de datos directamente al Core; deben mapearlos a Entidades del dominio.
- **Bad example:**
```java
public UserEntity findById(Long id) { return jpaRepo.findById(id); } // El Core recibe un @Entity
```
- **Good example:**
```java
public User findById(Long id) { return mapper.toDomain(jpaRepo.findById(id)); } // Devuelve POJO
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 22 "The Clean Architecture", p. 205.

---

### JAVA_CA_019
- **Severity:** BLOCKER
- **Source:** `custom:JAVA_CA_019`
- **Attribute:** Adaptable
- **Description:** Prohibido el uso de la palabra clave new para instanciar implementaciones de puertos (como Repositories) dentro de los Interactors. Use inyeccion de dependencias.
- **Bad example:**
```java
public class Interactor { private Repo repo = new MySqlRepo(); }
```
- **Good example:**
```java
public class Interactor { private Repo repo; public Interactor(Repo repo) { this.repo = repo; } }
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 11 "DIP", p. 89.

---

### JAVA_CA_020
- **Severity:** BLOCKER
- **Source:** `custom:JAVA_CA_020`
- **Attribute:** Intentional
- **Description:** El sistema debe ser capaz de ejecutarse y pasar sus tests unitarios sin que la base de datos o el servidor web esten activos.
- **Bad example:**
```java
@SpringBootTest // Requiere levantar todo el contexto y DB para un test de negocio
```
- **Good example:**
```java
class UseCaseTest { @Test void test() { UseCase uc = new UseCase(new MockRepo()); } }
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 21 "Screaming Architecture", p. 197.

---

### JAVA_CA_021
- **Severity:** BLOCKER
- **Source:** `custom:JAVA_CA_021`
- **Attribute:** Adaptable
- **Description:** Los Casos de Uso no deben importar clases de librerias de terceros (JSON, XML, Logging pesado) de forma directa si no son esenciales para la logica.
- **Bad example:**
```java
import com.fasterxml.jackson.databind.ObjectMapper; // El caso de uso sabe de JSON
```
- **Good example:**
```java
public void execute(String jsonData) { // El adaptador de entrada ya debio convertirlo a DTO
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 32 "Frameworks are Details", p. 280.

---

### JAVA_CA_022
- **Severity:** BLOCKER
- **Source:** `custom:JAVA_CA_022`
- **Attribute:** Adaptable
- **Description:** Las Entidades no deben implementar interfaces de frameworks externos (e.g., Serializable de Java solo si es estrictamente necesario para la arquitectura, evitar UserDetails de Spring Security).
- **Bad example:**
```java
public class User implements org.springframework.security.core.userdetails.UserDetails { ... }
```
- **Good example:**
```java
public class User { ... } // El adaptador de seguridad mapeara este objeto
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 32 "Frameworks are Details", p. 282.

---

### JAVA_CA_023
- **Severity:** BLOCKER
- **Source:** `custom:JAVA_CA_023`
- **Attribute:** Intentional
- **Description:** Los Casos de Uso deben tener nombres que reflejen una accion de negocio clara (e.g., PlaceOrder, CancelSubscription), no nombres genericos.
- **Bad example:**
```java
public class OrderService { ... } // Que hace?
```
- **Good example:**
```java
public class PlaceOrderInteractor { ... } // Intencion clara
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 21 "Screaming Architecture", p. 198.

---

### JAVA_CA_024
- **Severity:** BLOCKER
- **Source:** `custom:JAVA_CA_024`
- **Attribute:** Adaptable
- **Description:** La logica de persistencia (SQL, Queries, Transacciones manuales) debe estar estrictamente confinada en la capa de Adaptadores de Salida.
- **Bad example:**
```java
@Transactional // Anotacion de Spring en un Caso de Uso del Core
public void execute() { ... }
```
- **Good example:**
```java
// El Transactional se aplica en el adaptador o via configuracion en el Main
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 30 "The Database is a Detail", p. 265.

---

### JAVA_CA_025
- **Severity:** BLOCKER
- **Source:** `custom:JAVA_CA_025`
- **Attribute:** Adaptable
- **Description:** Uso del patron Factory para la creacion de objetos volatiles. El Core no debe instanciar objetos que pertenezcan a la capa de Infraestructura.
- **Bad example:**
```java
OrderRepository repo = new MySqlOrderRepository();
```
- **Good example:**
```java
// El Main o una Factoria inyecta la implementacion concreta en el Core.
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 11 "DIP", p. 89.

---

### JAVA_CA_026
- **Severity:** BLOCKER
- **Source:** `custom:JAVA_CA_026`
- **Attribute:** Adaptable
- **Description:** Las fronteras arquitectonicas deben ser explicitas. Si dos componentes tienen ciclos de vida diferentes, deben estar separados por interfaces.
- **Bad example:**
```java
public class OrderController { public void process() { /* logica directa */ } }
```
- **Good example:**
```java
public class OrderController { private OrderInputPort port; }
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 17 "Boundaries: Drawing Lines", p. 160.

---

### JAVA_CA_027
- **Severity:** BLOCKER
- **Source:** `custom:JAVA_CA_027`
- **Attribute:** Adaptable
- **Description:** Los plugins (capas externas) pueden depender del Core, pero el Core nunca debe depender de un plugin.
- **Bad example:**
```java
// Core importando una clase de una libreria de Excel para generar reportes.
```
- **Good example:**
```java
// Core define ReportExporter, la capa de infraestructura implementa ExcelExporter.
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 17 "Boundaries: Drawing Lines", p. 165.

---

### JAVA_CA_028
- **Severity:** BLOCKER
- **Source:** `custom:JAVA_CA_028`
- **Attribute:** Intentional
- **Description:** Las reglas de negocio de alto nivel (politicas) no deben verse afectadas por cambios en los mecanismos de bajo nivel (DB, UI).
- **Bad example:**
```java
// Cambiar el tipo de dato de una columna de DB obliga a cambiar la logica del Caso de Uso.
```
- **Good example:**
```java
// El adaptador de salida mapea el nuevo tipo de DB al tipo constante del dominio.
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 19 "Policy and Level", p. 185.

---

### JAVA_CA_029
- **Severity:** BLOCKER
- **Source:** `custom:JAVA_CA_029`
- **Attribute:** Adaptable
- **Description:** Prohibido el uso de reflexion para saltarse las fronteras arquitectonicas (e.g., acceder a campos privados de Entidades desde la UI).
- **Bad example:**
```java
Field field = order.getClass().getDeclaredField("internalStatus");
```
- **Good example:**
```java
String status = order.getStatus(); // Acceso via contrato publico
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 22 "The Clean Architecture", p. 203.

---

### JAVA_CA_030
- **Severity:** BLOCKER
- **Source:** `custom:JAVA_CA_030`
- **Attribute:** Responsible
- **Description:** Los datos de configuracion (application.properties, YAML) no deben ser leidos directamente por el Core usando @Value.
- **Bad example:**
```java
public class UseCase { @Value("${tax.rate}") private double tax; }
```
- **Good example:**
```java
public class UseCase { private final double tax; public UseCase(double tax) { this.tax = tax; } }
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 32 "Frameworks are Details", p. 280.

---

### JAVA_CA_031
- **Severity:** BLOCKER
- **Source:** `custom:JAVA_CA_031`
- **Attribute:** Adaptable
- **Description:** Evitar el "Acoplamiento de Transatlantico": un cambio en una capa externa no debe propagarse a traves de todas las capas internas.
- **Bad example:**
```java
// Cambiar de JSON a XML requiere modificar Interactors, Entidades y Repositorios.
```
- **Good example:**
```java
// Solo se modifica el adaptador de entrada (Controller/Consumer).
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 17 "Boundaries", p. 162.

---

### JAVA_CA_032
- **Severity:** BLOCKER
- **Source:** `custom:JAVA_CA_032`
- **Attribute:** Adaptable
- **Description:** Los Casos de Uso no deben implementar la logica de ordenamiento de resultados para la UI si esta depende de capacidades especificas de la DB (e.g., ORDER BY dinamico pasado desde el Core).
- **Bad example:**
```java
public List<User> get(String sqlOrderBy) { ... }
```
- **Good example:**
```java
public List<User> get(SortOrder order) { ... } // SortOrder es un Enum de dominio
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 30 "The Database is a Detail", p. 265.

---

### JAVA_CA_033
- **Severity:** BLOCKER
- **Source:** `custom:JAVA_CA_033`
- **Attribute:** Intentional
- **Description:** Las entidades deben poseer metodos que representen transiciones de estado de negocio, no solo setters genericos.
- **Bad example:**
```java
order.setStatus("CANCELLED");
```
- **Good example:**
```java
order.cancel(); // Contiene validacion interna
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 20 "Business Rules", p. 191.

---

### JAVA_CA_034
- **Severity:** BLOCKER
- **Source:** `custom:JAVA_CA_034`
- **Attribute:** Adaptable
- **Description:** El motor de Inyeccion de Dependencias es un detalle del componente Main. Ninguna logica de negocio debe depender de el para funcionar.
- **Bad example:**
```java
// Caso de uso que falla en test unitario porque no hay "ApplicationContext".
```
- **Good example:**
```java
// El caso de uso se instancia con 'new' en el test unitario.
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 26 "The Main Component", p. 232.

---

### JAVA_CA_035
- **Severity:** BLOCKER
- **Source:** `custom:JAVA_CA_035`
- **Attribute:** Adaptable
- **Description:** El Core no debe conocer los codigos de estado HTTP (e.g., no devolver ResponseEntity).
- **Bad example:**
```java
public ResponseEntity<String> execute() { return ResponseEntity.ok("Done"); }
```
- **Good example:**
```java
public String execute() { return "Done"; }
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 22 "The Clean Architecture", p. 204.

---

### JAVA_CA_036
- **Severity:** BLOCKER
- **Source:** `custom:JAVA_CA_036`
- **Attribute:** Adaptable
- **Description:** Principio de Inversion de Dependencias (DIP) en librerias externas: Si una libreria de logica de negocio nos obliga a heredar de sus clases, debe quedar aislada tras un adaptador.
- **Bad example:**
```java
public class MyLogic extends ExternalLibraryBase { ... }
```
- **Good example:**
```java
public class MyLogic implements DomainInterface { private ExternalLibrary tool; }
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 11 "DIP", p. 90.

---

### JAVA_CA_037
- **Severity:** BLOCKER
- **Source:** `custom:JAVA_CA_037`
- **Attribute:** Intentional
- **Description:** Los Interactors deben tener una unica responsabilidad (SRP): orquestar un unico Caso de Uso.
- **Bad example:**
```java
public class GeneralManager { public void createUser(); public void deleteProduct(); }
```
- **Good example:**
```java
public class CreateUserInteractor { public void execute(); }
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 7 "SRP", p. 62.

---

### JAVA_CA_038
- **Severity:** BLOCKER
- **Source:** `custom:JAVA_CA_038`
- **Attribute:** Adaptable
- **Description:** Las Entidades no deben ser conscientes de como se almacenan en disco. Evitar el uso de java.io.File o java.nio.path en el dominio.
- **Bad example:**
```java
public class Document { private Path localPath; }
```
- **Good example:**
```java
public class Document { private String contentIdentifier; }
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 30 "The Database is a Detail", p. 265.

---

### JAVA_CA_039
- **Severity:** BLOCKER
- **Source:** `custom:JAVA_CA_039`
- **Attribute:** Adaptable
- **Description:** Los puertos de salida (Output Ports) deben definirse en el paquete del Caso de Uso o en el paquete del Dominio, nunca en el paquete de Infraestructura.
- **Bad example:**
```java
package com.app.infra; public interface UserRepository { ... }
```
- **Good example:**
```java
package com.app.domain.ports; public interface UserRepository { ... }
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 22 "The Clean Architecture", p. 205.

---

### JAVA_CA_040
- **Severity:** BLOCKER
- **Source:** `custom:JAVA_CA_040`
- **Attribute:** Adaptable
- **Description:** Los Casos de Uso no deben usar tipos de datos que provengan de drivers de base de datos (e.g., org.postgresql.util.PGobject).
- **Bad example:**
```java
public void execute(PGobject rawData) { ... }
```
- **Good example:**
```java
public void execute(Map<String, Object> data) { ... }
```
- **Book references:**
  - Clean Architecture — Robert C. Martin — Cap. 30 "The Database is a Detail", p. 266.
