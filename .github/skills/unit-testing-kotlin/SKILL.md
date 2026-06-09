---
name: "unit-testing-kotlin"
description: >
  Define los patrones de unit testing del proyecto: JUnit5 + MockK + Kotest assertions,
  cobertura JaCoCo ≥40%, naming given/when/then y tests de repositorio con H2 in-memory.
applyTo:
  - "**/*Test.kt"
  - "**/*Spec.kt"
  - "**/build.gradle.kts"
triggers:
  - "crea los tests"
  - "escribe el test unitario"
  - "crea el unit test"
  - "testea el use case"
  - "testea el repositorio"
  - "cobertura de tests"
  - "jacoco"
  - "mockk"
  - "añade tests para"
  - "test del repositorio"
nonTriggers:
  - Implementación de lógica de negocio (usar clean-architecture o kotlin-mcp-expert)
  - Configuración de pipelines CI/CD (usar las skills *-cicd)
  - Revisión de calidad de código (usar clean-code-guardian)
---

# Unit Testing Kotlin

## Propósito

Define los patrones, estructura y herramientas de testing del proyecto.
Garantiza cobertura mínima del 40% con JUnit5, MockK y Kotest assertions,
con tests de repositorio usando H2 in-memory.

## Cuándo usar esta skill

- Al crear tests para use cases (capa `application/`).
- Al crear tests para repositorios (capa `infrastructure/db/`).
- Al configurar JaCoCo en `build.gradle.kts`.
- Cuando el agente necesita validar una implementación con tests.

## Cuándo NO usar esta skill

- Para implementar lógica de negocio → `clean-architecture`.
- Para configurar pipelines → skills `*-cicd`.

---

## Stack de testing

| Dependencia | Uso |
|---|---|
| `org.junit.jupiter:junit-jupiter` | Motor de ejecución de tests |
| `io.mockk:mockk` | Mocks y stubs en Kotlin idiomático |
| `io.kotest:kotest-assertions-core` | Assertions expresivas (`shouldBe`, `shouldThrow`) |
| `org.jetbrains.kotlinx:kotlinx-coroutines-test` | Testing de suspending functions con `runTest` |
| `com.h2database:h2` | Base de datos in-memory para tests de repositorio |

---

## Configuración en build.gradle.kts

```kotlin
// build.gradle.kts
dependencies {
    testImplementation("org.junit.jupiter:junit-jupiter:5.10.x")
    testImplementation("io.mockk:mockk:1.13.x")
    testImplementation("io.kotest:kotest-assertions-core:5.x.x")
    testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.x.x")
    testImplementation("com.h2database:h2:2.x.x")
}

tasks.test {
    useJUnitPlatform()
}

// JaCoCo — cobertura mínima 40%
plugins {
    jacoco
}

tasks.jacocoTestReport {
    dependsOn(tasks.test)
    reports {
        xml.required.set(true)
        html.required.set(true)
    }
}

tasks.jacocoTestCoverageVerification {
    violationRules {
        rule {
            limit {
                minimum = "0.40".toBigDecimal()
            }
        }
    }
}

tasks.check {
    dependsOn(tasks.jacocoTestCoverageVerification)
}
```

---

## Pasos de ejecución

### 1. Estructura de carpetas de tests

```
src/test/kotlin/com/mcp/shareresources/
│
├── application/
│   └── usecase/
│       └── RegisterResourceUseCaseTest.kt   ← tests de use cases
│
└── infrastructure/
    └── db/
        └── ExposedResourceRepositoryTest.kt  ← tests de repositorio con H2
```

Los tests replican la misma estructura de packages que el código de producción.

### 2. Naming de métodos de test

**Formato obligatorio:** `given_<estado_inicial>_when_<accion>_then_<resultado_esperado>`

```kotlin
@Test
fun given_valid_input_when_register_resource_then_resource_is_persisted()

@Test
fun given_duplicate_name_when_register_resource_then_domain_exception_is_thrown()

@Test
fun given_non_existing_id_when_find_by_id_then_returns_null()
```

**Reglas del naming:**
- Todo en minúsculas con guiones bajos.
- `given_` describe el estado o precondición.
- `when_` describe la acción que se ejecuta.
- `then_` describe el resultado observable esperado.
- Sin palabras redundantes: no `test_`, no `should_`, no `check_`.

### 3. Test de Use Case (con MockK)

```kotlin
// application/usecase/RegisterResourceUseCaseTest.kt
class RegisterResourceUseCaseTest {

    private val resourceRepository: ResourceRepository = mockk()
    private val useCase = RegisterResourceUseCaseImpl(resourceRepository)

    @Test
    fun given_valid_input_when_register_resource_then_repository_save_is_called() = runTest {
        // Given
        val request = RegisterResourceRequest(name = "MyResource", content = "content")
        coEvery { resourceRepository.save(any()) } just Runs

        // When
        val response = useCase(request)

        // Then
        response.name shouldBe "MyResource"
        coVerify(exactly = 1) { resourceRepository.save(any()) }
    }

    @Test
    fun given_blank_name_when_register_resource_then_throws_illegal_argument() = runTest {
        // Given
        val request = RegisterResourceRequest(name = "", content = "content")

        // When / Then
        shouldThrow<IllegalArgumentException> {
            useCase(request)
        }
    }

    @Test
    fun given_repository_throws_when_register_resource_then_exception_propagates() = runTest {
        // Given
        val request = RegisterResourceRequest(name = "MyResource", content = "content")
        coEvery { resourceRepository.save(any()) } throws RuntimeException("DB error")

        // When / Then
        shouldThrow<RuntimeException> {
            useCase(request)
        }
    }
}
```

### 4. Test de Repositorio (con H2 in-memory)

```kotlin
// infrastructure/db/ExposedResourceRepositoryTest.kt
class ExposedResourceRepositoryTest {

    private val repository = ExposedResourceRepository()

    companion object {
        @JvmStatic
        @BeforeAll
        fun setupDatabase() {
            // Conectar H2 in-memory
            Database.connect(
                url      = "jdbc:h2:mem:test;DB_CLOSE_DELAY=-1",
                driver   = "org.h2.Driver",
                user     = "sa",
                password = ""
            )
            // Crear schema
            transaction {
                SchemaUtils.create(ResourceTable)
            }
        }
    }

    @BeforeEach
    fun cleanUp() {
        transaction { ResourceTable.deleteAll() }
    }

    @Test
    fun given_resource_when_save_then_can_be_found_by_id() = runTest {
        // Given
        val resource = Resource(
            id      = ResourceId("test-id-1"),
            name    = "TestResource",
            content = "content"
        )

        // When
        repository.save(resource)

        // Then
        val found = repository.findById(ResourceId("test-id-1"))
        found shouldNotBe null
        found!!.name shouldBe "TestResource"
    }

    @Test
    fun given_non_existing_id_when_find_by_id_then_returns_null() = runTest {
        // When
        val result = repository.findById(ResourceId("non-existing"))

        // Then
        result shouldBe null
    }

    @Test
    fun given_saved_resource_when_delete_then_not_found() = runTest {
        // Given
        val resource = Resource(id = ResourceId("del-id"), name = "ToDelete", content = "c")
        repository.save(resource)

        // When
        repository.delete(ResourceId("del-id"))

        // Then
        repository.findById(ResourceId("del-id")) shouldBe null
    }
}
```

### 5. Fakes vs Mocks

| Situación | Usar |
|---|---|
| Aislar el use case de sus dependencias | **MockK** (`mockk<Interface>()`) |
| Verificar que se llama a un método | **MockK** con `coVerify` |
| Testear el repositorio con datos reales | **H2 in-memory** (no mockear la DB) |
| Simular múltiples escenarios de respuesta | **MockK** con `coEvery { } returns` |
| Dependencias complejas con estado | **Fake** manual que implementa la interface |

### 6. Ejecutar tests y cobertura

```bash
# Ejecutar todos los tests
./gradlew test --no-daemon

# Generar reporte de cobertura JaCoCo
./gradlew jacocoTestReport --no-daemon

# Verificar que se cumple el 40% mínimo (falla el build si no)
./gradlew jacocoTestCoverageVerification --no-daemon

# Todo junto (lo que ejecuta el CI)
./gradlew test jacocoTestReport jacocoTestCoverageVerification --no-daemon
```

El reporte HTML se genera en: `build/reports/jacoco/test/html/index.html`

---

## Checklist de revisión

- [ ] **UT-01** Naming `given_X_when_Y_then_Z` en todos los métodos de test
- [ ] **UT-02** Use cases testeados con MockK, sin dependencias reales
- [ ] **UT-03** Repositorios testeados con H2 in-memory (no mocks de la DB)
- [ ] **UT-04** Suspending functions testeadas con `runTest { }`
- [ ] **UT-05** `coEvery / coVerify` para funciones suspend en MockK
- [ ] **UT-06** JaCoCo configurado con threshold 0.40
- [ ] **UT-07** Estructura de test replica la estructura del código de producción
- [ ] **UT-08** Cada test prueba un único comportamiento (un `when` por test)
- [ ] **UT-09** Cada `TC-U-XXX` del fichero `docs/test-cases/TC-<US>-*.md` tiene su test correspondiente

---

## Generación de tests guiada por Test Cases

Cuando existe un fichero `docs/test-cases/TC-<US-number>-*.md` para la US actual, los tests se generan en dos pasos:

### Paso 1 — Extraer TC-U del fichero

Leer la sección `## Nivel 1 - Unit Tests` del TC file. Por cada `TC-U-XXX`:
- Extraer: `Given`, `When`, `Then`, `Clase de test`, `Método`.
- Si el TC especifica nombre de método → usarlo exactamente.
- Si no especifica nombre → derivarlo con el formato `given_<given>_when_<when>_then_<then>`.

Ejemplo de TC entry:
```markdown
### TC-U-001: Activar nueva plantilla por defecto desactiva la anterior
- **Given**: Existe una plantilla activa marcada como default y otra plantilla activa candidata.
- **When**: Se ejecuta SetDefaultTemplateUseCase con el id de la plantilla candidata.
- **Then**: La plantilla candidata queda con is_default=true y la plantilla previa queda con is_default=false.
- **Clase de test**: SetDefaultTemplateUseCaseTest
- **Método**: given_activeTemplateAndPreviousDefault_when_setDefault_then_newDefaultIsSetAndPreviousUnset()
```

### Paso 2 — Implementar todos los TC-U antes de añadir tests adicionales

1. Implementar primero los tests derivados de `TC-U-XXX` (cobertura mínima obligatoria).
2. Después, añadir tests de edge-cases o caminos no cubiertos por los TC.

### Paso 3 — Emitir tabla de cobertura

Antes de cerrar la fase de tests, producir la tabla de cobertura TC:

```
| TC ID    | Test class                    | Test method                                      | Status |
|----------|-------------------------------|--------------------------------------------------|--------|
| TC-U-001 | SetDefaultTemplateUseCaseTest | given_activeTemplate..._when_..._then_...()      | ✅     |
| TC-U-002 | SetDefaultTemplateUseCaseTest | given_nonExistingTemplate_when_..._then_...()    | ✅     |
```

Si algún `TC-U-XXX` está sin implementar (❌), escribir el test antes de continuar.

---

## Outputs esperados

- Tests unitarios para use cases con MockK y Kotest assertions.
- Tests de repositorio con H2 in-memory.
- Cobertura JaCoCo configurada con threshold ≥40%.
- Reporte HTML generado en `build/reports/jacoco/`.

---

## Referencias

- [references/testing-patterns.md](references/testing-patterns.md) — Patrones avanzados y casos especiales
