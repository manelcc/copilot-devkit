---
name: kotlin-mcp-server-generator
description: >-
  Generate a complete Kotlin MCP server project with Clean Architecture, PostgreSQL/Exposed,
  unit testing JaCoCo ≥40%, KMP support and the official io.modelcontextprotocol:kotlin-sdk library.
applyTo:
  - "**/*.kt"
  - "**/build.gradle.kts"
triggers:
  - "genera el proyecto mcp"
  - "crea el servidor mcp"
  - "bootstrap del mcp server"
  - "scaffolding del proyecto"
  - "genera la estructura del proyecto"
nonTriggers:
  - Implementar una tool concreta dentro de un proyecto ya existente
  - Revisión de calidad de código (usar clean-code-guardian)
  - Configurar CI/CD (usar las skills *-cicd)
---

# Kotlin MCP Server Project Generator

Generate a complete, production-ready MCP server project in Kotlin aligned with the official Kotlin SDK current APIs.

Source baseline:
- Repository: https://github.com/modelcontextprotocol/kotlin-sdk
- API docs: https://kotlin.sdk.modelcontextprotocol.io/
- Recommended baseline release: `0.11.1` (or newer stable)

## Required Output

When invoked, generate:

1. **Project structure** with clear package boundaries
2. **Gradle Kotlin DSL** setup for JVM (and optional multiplatform)
3. **MCP server bootstrap** with capabilities and tool registration
4. **2-3 practical tools** with validated JSON input
5. **Run instructions** for local and inspector validation
6. **Tests** for server wiring and tool behavior
7. **README** with setup, transport choices, and security notes

## Canonical Project Structure (Clean Architecture)

El proyecto sigue **Clean Architecture** con separación estricta de capas.
Ver skill `clean-architecture` para la regla de dependencia completa.

```text
{{PROJECT_NAME}}/
  build.gradle.kts
  settings.gradle.kts
  gradle.properties
  Dockerfile
  src/
    main/
      kotlin/{{PACKAGE_PATH}}/
        domain/
          model/            ← Entidades y value objects
          repository/       ← Interfaces (ports)
          exception/        ← Excepciones de dominio
        application/
          usecase/          ← UseCase<Input, Output> interface + impl
          dto/              ← Request / Response DTOs
        infrastructure/
          db/               ← Exposed repositories (adapters)
          db/table/         ← Definición de tablas Exposed
          di/               ← Módulos Koin
        entrypoint/
          mcp/              ← Registro de MCP tools
          Application.kt    ← Bootstrap Ktor + Koin + Flyway
      resources/
        application.conf
        db/migration/
          V1__init.sql
    test/
      kotlin/{{PACKAGE_PATH}}/
        application/usecase/
          RegisterResourceUseCaseTest.kt
        infrastructure/db/
          ExposedResourceRepositoryTest.kt
  README.md
```

## Dependency Guidance (Current)

Use official MCP artifacts and avoid stale hardcoded versions.

```kotlin
val mcpVersion = "0.11.1" // or latest stable

dependencies {
    // MCP SDK
    implementation("io.modelcontextprotocol:kotlin-sdk:$mcpVersion")

    // Ktor (transport)
    implementation("io.ktor:ktor-server-cio:<ktorVersion>")
    implementation("io.ktor:ktor-server-netty:<ktorVersion>")
    implementation("io.ktor:ktor-client-cio:<ktorVersion>")

    // Serialization + Coroutines
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:<serializationVersion>")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:<coroutinesVersion>")

    // PostgreSQL + Exposed + Flyway
    implementation("org.jetbrains.exposed:exposed-core:<exposedVersion>")
    implementation("org.jetbrains.exposed:exposed-jdbc:<exposedVersion>")
    implementation("org.jetbrains.exposed:exposed-kotlin-datetime:<exposedVersion>")
    implementation("org.flywaydb:flyway-core:<flywayVersion>")
    implementation("org.postgresql:postgresql:<pgVersion>")
    implementation("com.zaxxer:HikariCP:<hikariVersion>")

    // DI
    implementation("io.insert-koin:koin-ktor:<koinVersion>")

    // Testing
    testImplementation("org.junit.jupiter:junit-jupiter:<junitVersion>")
    testImplementation("io.mockk:mockk:<mockkVersion>")
    testImplementation("io.kotest:kotest-assertions-core:<kotestVersion>")
    testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:<coroutinesVersion>")
    testImplementation("com.h2database:h2:<h2Version>")
}

plugins {
    jacoco
}

tasks.jacocoTestCoverageVerification {
    violationRules {
        rule {
            limit { minimum = "0.40".toBigDecimal() }
        }
    }
}
```

If only server APIs are needed, prefer `io.modelcontextprotocol:kotlin-sdk-server`.
If only client APIs are needed, prefer `io.modelcontextprotocol:kotlin-sdk-client`.

## API Usage Rules

1. Import protocol types from `io.modelcontextprotocol.kotlin.sdk.types.*`.
2. Use `Server(...)` + `ServerOptions(...)` + `ServerCapabilities(...)`.
3. Define tool schemas with `ToolSchema` + `buildJsonObject`.
4. Keep handlers suspendable and validate arguments defensively.
5. Propagate cancellation correctly in coroutine flows.

## Server Template (Current Style)

```kotlin
import io.modelcontextprotocol.kotlin.sdk.server.Server
import io.modelcontextprotocol.kotlin.sdk.server.ServerOptions
import io.modelcontextprotocol.kotlin.sdk.types.CallToolResult
import io.modelcontextprotocol.kotlin.sdk.types.Implementation
import io.modelcontextprotocol.kotlin.sdk.types.ServerCapabilities
import io.modelcontextprotocol.kotlin.sdk.types.TextContent
import io.modelcontextprotocol.kotlin.sdk.types.ToolSchema
import kotlinx.serialization.json.buildJsonObject
import kotlinx.serialization.json.put

fun createServer(name: String, version: String): Server {
    val server = Server(
        serverInfo = Implementation(name = name, version = version),
        options = ServerOptions(
            capabilities = ServerCapabilities(
                tools = ServerCapabilities.Tools(listChanged = true),
                resources = ServerCapabilities.Resources(subscribe = true, listChanged = true),
                prompts = ServerCapabilities.Prompts(listChanged = true),
            )
        )
    )

    server.addTool(
        name = "echo",
        description = "Echo input text",
        inputSchema = ToolSchema(
            properties = buildJsonObject {
                put("text", buildJsonObject { put("type", "string") })
            }
        )
    ) { request ->
        val text = request.arguments?.get("text")?.toString() ?: ""
        CallToolResult(content = listOf(TextContent(text = "Echo: $text")))
    }

    return server
}
```

## Transport Strategy

- **Default for new remote deployments**: Streamable HTTP via `mcpStreamableHttp()`.
- **CLI/editor local process**: `StdioServerTransport`.
- **Legacy compatibility**: SSE (`mcp`) only when needed.

Important notes:
- Streamable HTTP helpers can auto-install MCP JSON negotiation.
- For browser-based inspector usage, configure CORS and allow/expose `Mcp-Session-Id` and `Mcp-Protocol-Version`.

## Generation Steps

1. Ask for `PROJECT_NAME`, package namespace, and preferred transport.
2. Generate Gradle files with MCP + Ktor + Exposed + Flyway + Koin + Testing dependencies.
3. Generate **Clean Architecture** structure de capas (`domain/application/infrastructure/entrypoint/`).
4. Generate `DatabaseFactory` con `dbQuery` coroutine-safe y `FlywayMigration`.
5. Generate `Application.kt` con Koin modules, DB init y MCP server bootstrap.
6. Generate al menos dos tools reales con UseCase + Repository + Exposed table.
7. Add argument validation and clear error messages en cada tool handler.
8. Generate tests: UseCase con MockK + Repository con H2 in-memory.
9. Configure JaCoCo con threshold ≥40%.
10. Generate README con run/test/debug instructions y MCP Inspector check.

## Clean Architecture en el generador

Al generar el proyecto, aplicar siempre la regla de dependencia:
```
entrypoint → infrastructure → application → domain
```

Consultar skill `clean-architecture` para los patrones completos de UseCase, Repository y DI.

## PostgreSQL en el generador

Incluir siempre:
- `infrastructure/db/table/` con las tablas Exposed
- `infrastructure/db/DatabaseFactory.kt` con `dbQuery` coroutine-safe
- `infrastructure/db/FlywayMigration.kt`
- `src/main/resources/db/migration/V1__init.sql`
- Configuración en `application.conf` via variables de entorno

Consultar skill `postgresql-crud` para los patrones detallados.

## Unit Testing en el generador

Incluir siempre:
- Tests de use cases con **MockK** en `application/usecase/`
- Tests de repositorios con **H2 in-memory** en `infrastructure/db/`
- Naming `given_X_when_Y_then_Z`
- JaCoCo configurado con threshold 40%

Consultar skill `unit-testing-kotlin` para los patrones detallados.

## Quality Checklist

- Uses `io.modelcontextprotocol.kotlin.sdk.types` imports
- No hardcoded secrets in examples
- Capabilities match actual registered features
- Tool schemas and argument validation are present
- Transport choice documented and justified
- README includes local verification path

## Security and Reliability Guardrails

- Keep a human in the loop for sensitive operations.
- Avoid exposing internals in error messages returned to clients.
- Do not swallow `CancellationException`.
- Prefer immutable configs and constructor-based dependency injection.

## Optional Multiplatform Mode (KMP)

Si el usuario solicita soporte KMP (compartir lógica con Android/iOS):

```kotlin
// settings.gradle.kts
enableFeaturePreview("TYPESAFE_PROJECT_ACCESSORS")

// build.gradle.kts (módulo shared)
kotlin {
    jvm()           // servidor JVM
    androidTarget() // cliente Android
    iosArm64()      // cliente iOS
    iosSimulatorArm64()

    sourceSets {
        commonMain.dependencies {
            implementation("io.modelcontextprotocol:kotlin-sdk:$mcpVersion")
            implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:<version>")
        }
        jvmMain.dependencies {
            // Ktor server, Exposed, Flyway — solo JVM
        }
    }
}
```

**Regla KMP:** La lógica de dominio y los DTOs van en `commonMain`. El servidor Ktor,
Exposed y Flyway van en `jvmMain`. Los clientes Android/iOS consumen `commonMain`.
