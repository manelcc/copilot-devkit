# Clean Architecture Quality Guidelines: Java — LOW

---

Total rules: **30**

## JAVA_CS

### JAVA_CS_001
- **Severity:** LOW
- **Source:** `custom / custom:JAVA_CS_001`
- **Description:** Los nombres de las clases deben ser sustantivos en PascalCase. Se deben evitar las abreviaturas a menos que sean mucho mas comunes que la forma larga.
- **Bad example:**
```java
class procData { ... }
```
- **Good example:**
```java
class DataProcessor { ... }
```
- **References:**
  - https://www.oracle.com/java/technologies/javase/codeconventions-namingconventions.html

---

### JAVA_CS_002
- **Severity:** LOW
- **Source:** `custom / custom:JAVA_CS_002`
- **Description:** Los nombres de los metodos deben ser verbos en camelCase.
- **Bad example:**
```java
public void calculation() { ... }
```
- **Good example:**
```java
public void calculateTotal() { ... }
```
- **References:**
  - https://www.oracle.com/java/technologies/javase/codeconventions-namingconventions.html

---

### JAVA_CS_003
- **Severity:** LOW
- **Source:** `custom / custom:JAVA_CS_003`
- **Description:** Evitar variables de una sola letra, excepto para variables temporales de corto alcance como contadores de bucles (i, j, k).
- **Bad example:**
```java
int d = 86400;
```
- **Good example:**
```java
int secondsPerDay = 86400;
```
- **References:**
  - https://www.oracle.com/java/technologies/javase/codeconventions-namingconventions.html

---

### JAVA_CS_004
- **Severity:** LOW
- **Source:** `custom / custom:JAVA_CS_004`
- **Description:** Las constantes de clase deben estar en UPPER_SNAKE_CASE con palabras separadas por guiones bajos.
- **Bad example:**
```java
static final int maxCount = 10;
```
- **Good example:**
```java
static final int MAX_COUNT = 10;
```
- **References:**
  - https://www.oracle.com/java/technologies/javase/codeconventions-namingconventions.html

---

### JAVA_CS_005
- **Severity:** LOW
- **Source:** `custom / custom:JAVA_CS_005`
- **Description:** Los nombres de los paquetes deben estar siempre en minusculas y comenzar con un dominio de nivel superior (com, org, etc.).
- **Bad example:**
```java
package Com.MyCompany.App;
```
- **Good example:**
```java
package com.mycompany.app;
```
- **References:**
  - https://www.oracle.com/java/technologies/javase/codeconventions-namingconventions.html

---

### JAVA_CS_006
- **Severity:** LOW
- **Source:** `custom / custom:JAVA_CS_006`
- **Description:** No utilizar prefijos o sufijos especiales para identificadores (como mName o name_).
- **Bad example:**
```java
private String mUser;
```
- **Good example:**
```java
private String user;
```
- **References:**
  - https://google.github.io/styleguide/javaguide.html

---

### JAVA_CS_007
- **Severity:** LOW
- **Source:** `custom / custom:JAVA_CS_007`
- **Description:** Utilizar siempre llaves {} para estructuras de control (if, else, for, do, while), incluso si el cuerpo esta vacio o tiene una sola linea.
- **Bad example:**
```java
if (condition) return;
```
- **Good example:**
```java
if (condition) { return; }
```
- **References:**
  - https://www.oracle.com/java/technologies/javase/codeconventions-statements.html

---

### JAVA_CS_008
- **Severity:** LOW
- **Source:** `custom / custom:JAVA_CS_008`
- **Description:** No incluir espacios antes de una coma , o un punto y coma ;.
- **Bad example:**
```java
doSomething(arg1 , arg2) ;
```
- **Good example:**
```java
doSomething(arg1, arg2);
```
- **References:**
  - https://google.github.io/styleguide/javaguide.html

---

### JAVA_CS_009
- **Severity:** LOW
- **Source:** `custom / custom:JAVA_CS_009`
- **Description:** No utilizar parentesis innecesarios en sentencias return a menos que aclaren el valor de retorno.
- **Bad example:**
```java
return (size);
```
- **Good example:**
```java
return size;
```
- **References:**
  - https://www.oracle.com/java/technologies/javase/codeconventions-statements.html

---

### JAVA_CS_010
- **Severity:** LOW
- **Source:** `custom / custom:JAVA_CS_010`
- **Description:** Evitar inicializar o actualizar mas de tres variables en la clausula de un bucle for mediante el uso del operador coma.
- **Bad example:**
```java
for (int i = 0, j = 0, k = 0, l = 0; ...) { ... }
```
- **Good example:**
```java
int l = 0;
for (int i = 0, j = 0, k = 0; ...) { ... }
```
- **References:**
  - https://www.oracle.com/java/technologies/javase/codeconventions-statements.html

---

### JAVA_CS_011
- **Severity:** LOW
- **Source:** `custom / custom:JAVA_CS_011`
- **Description:** Cada vez que un caso de switch permita el "fall-through" (caida al siguiente caso), debe incluirse un comentario explicativo indicandolo explicitamente.
- **Bad example:**
```java
case 1: doX();
case 2: ...
```
- **Good example:**
```java
case 1: doX(); /* falls through */
case 2: ...
```
- **References:**
  - https://www.oracle.com/java/technologies/javase/codeconventions-statements.html

---

### JAVA_CS_012
- **Severity:** LOW
- **Source:** `custom / custom:JAVA_CS_012`
- **Description:** Las sentencias switch deben incluir siempre un caso default, incluso si no contiene codigo.
- **Bad example:**
```java
switch (val) { case A: ... }
```
- **Good example:**
```java
switch (val) { case A: ... default: break; }
```
- **References:**
  - https://www.oracle.com/java/technologies/javase/codeconventions-statements.html

---

### JAVA_CS_013
- **Severity:** LOW
- **Source:** `custom / custom:JAVA_CS_013`
- **Description:** No ignorar excepciones capturadas. Como minimo deben registrarse en el log o, si es intencional, justificarse con un comentario.
- **Bad example:**
```java
catch (Exception e) {}
```
- **Good example:**
```java
catch (Exception e) { logger.error(e); }
```
- **References:**
  - https://google.github.io/styleguide/javaguide.html

---

### JAVA_CS_014
- **Severity:** LOW
- **Source:** `custom / custom:JAVA_CS_014`
- **Description:** Eliminar importaciones no utilizadas para evitar el desorden en el codigo y reducir el code bloat.
- **References:**
  - https://docs.sonarqube.org/latest/user-guide/rules/

---

### JAVA_CS_015
- **Severity:** LOW
- **Source:** `custom / custom:JAVA_CS_015`
- **Description:** No utilizar importaciones con comodines (wildcards). Se deben importar clases especificas.
- **Bad example:**
```java
import java.util.*;
```
- **Good example:**
```java
import java.util.List;
```
- **References:**
  - https://google.github.io/styleguide/javaguide.html

---

### JAVA_CS_016
- **Severity:** LOW
- **Source:** `custom / custom:JAVA_CS_016`
- **Description:** No dividir las sobrecargas de metodos. Deben aparecer en un grupo contiguo en el archivo fuente.
- **References:**
  - https://google.github.io/styleguide/javaguide.html

---

### JAVA_CS_017
- **Severity:** LOW
- **Source:** `custom / custom:JAVA_CS_017`
- **Description:** Mantener una sola sentencia por linea de codigo.
- **Bad example:**
```java
total = 0; count = 0;
```
- **Good example:**
```java
total = 0;
count = 0;
```
- **References:**
  - https://google.github.io/styleguide/javaguide.html

---

### JAVA_CS_018
- **Severity:** LOW
- **Source:** `custom / custom:JAVA_CS_018`
- **Description:** Utilizar la sintaxis de array de Java String[] args, evitando la sintaxis de estilo C String args[].
- **Bad example:**
```java
int numbers[];
```
- **Good example:**
```java
int[] numbers;
```
- **References:**
  - https://google.github.io/styleguide/javaguide.html

---

### JAVA_CS_019
- **Severity:** LOW
- **Source:** `custom / custom:JAVA_CS_019`
- **Description:** Los comentarios TODO deben incluir una referencia a un recurso (como un ID de bug) y una descripcion clara.
- **Bad example:**
```java
// TODO: fix this
```
- **Good example:**
```java
// TODO(id): refactor logic
```
- **References:**
  - https://google.github.io/styleguide/javaguide.html

---

### JAVA_CS_020
- **Severity:** LOW
- **Source:** `custom / custom:JAVA_CS_020`
- **Description:** El primer fragmento de un Javadoc debe ser una frase nominal o verbal resumida, no una oracion completa.
- **References:**
  - https://google.github.io/styleguide/javaguide.html

---

### JAVA_CS_021
- **Severity:** LOW
- **Source:** `custom / custom:JAVA_CS_021`
- **Description:** Los literales de tipo long deben usar siempre una 'L' mayuscula para evitar confusion con el numero 1.
- **Bad example:**
```java
long val = 3000l;
```
- **Good example:**
```java
long val = 3000L;
```
- **References:**
  - https://google.github.io/styleguide/javaguide.html

---

### JAVA_CS_022
- **Severity:** LOW
- **Source:** `custom / custom:JAVA_CS_022`
- **Description:** Indentar el contenido de los bloques con exactamente +2 espacios adicionales respecto al nivel anterior.
- **References:**
  - https://google.github.io/styleguide/javaguide.html

---

### JAVA_CS_023
- **Severity:** LOW
- **Source:** `custom / custom:JAVA_CS_023`
- **Description:** Colocar espacios en ambos lados de los operadores binarios y ternarios.
- **Bad example:**
```java
int x=a+b;
```
- **Good example:**
```java
int x = a + b;
```
- **References:**
  - https://google.github.io/styleguide/javaguide.html

---

### JAVA_CS_024
- **Severity:** LOW
- **Source:** `custom / custom:JAVA_CS_024`
- **Description:** No utilizar finalizadores (Object.finalize). Su soporte esta programado para ser eliminado.
- **References:**
  - https://google.github.io/styleguide/javaguide.html

---

### JAVA_CS_025
- **Severity:** LOW
- **Source:** `custom / custom:JAVA_CS_025`
- **Description:** Los miembros estaticos deben calificarse utilizando el nombre de la clase, no una referencia de instancia.
- **Bad example:**
```java
myInstance.staticMethod();
```
- **Good example:**
```java
MyClass.staticMethod();
```
- **References:**
  - https://google.github.io/styleguide/javaguide.html

---

### JAVA_CS_026
- **Severity:** LOW
- **Source:** `custom / custom:JAVA_CS_026`
- **Description:** Utilizar siempre la anotacion @Override cuando sea legal hacerlo.
- **References:**
  - https://google.github.io/styleguide/javaguide.html

---

### JAVA_CS_027
- **Severity:** LOW
- **Source:** `custom / custom:JAVA_CS_027`
- **Description:** Se recomienda el uso de parentesis de agrupacion para evitar ambiguedades en la precedencia de operadores, incluso si no son tecnicamente necesarios.
- **References:**
  - https://google.github.io/styleguide/javaguide.html

---

### JAVA_CS_028
- **Severity:** LOW
- **Source:** `custom / custom:JAVA_CS_028`
- **Description:** Los bloques vacios pueden ser concisos ({}) a menos que sean parte de una sentencia multi-bloque como if/else.
- **References:**
  - https://google.github.io/styleguide/javaguide.html

---

### JAVA_CS_029
- **Severity:** LOW
- **Source:** `custom / custom:JAVA_CS_029`
- **Description:** La coma debe permanecer pegada al token que la precede en una lista.
- **Bad example:**
```java
method(arg1 , arg2)
```
- **Good example:**
```java
method(arg1, arg2)
```
- **References:**
  - https://google.github.io/styleguide/javaguide.html

---

### JAVA_CS_030
- **Severity:** LOW
- **Source:** `custom / custom:JAVA_CS_030`
- **Description:** Las variables locales deben declararse cerca del punto donde se usan por primera vez para minimizar su alcance.
- **References:**
  - https://google.github.io/styleguide/javaguide.html
