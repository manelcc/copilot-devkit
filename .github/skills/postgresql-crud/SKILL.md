---
name: "postgresql-crud"
description: >
  Define los patrones de acceso a PostgreSQL con Exposed DSL y Flyway: tablas, repositorios,
  dbQuery coroutine-safe, migraciones versionadas y configuración por entorno.
applyTo:
  - "**/*.kt"
  - "**/resources/db/migration/*.sql"
  - "**/application.conf"
  - "**/application.yaml"
triggers:
  - "crea la tabla"
  - "crea el repositorio"
  - "migración de base de datos"
  - "flyway"
  - "exposed"
  - "consulta a la base de datos"
  - "crud de"
  - "persiste en la base de datos"
  - "configura la conexión a postgres"
nonTriggers:
  - Lógica de negocio o use cases (usar clean-architecture)
  - Configuración de tests de base de datos (usar unit-testing-kotlin)
  - Configuración de pipelines CI/CD (usar las skills *-cicd)
---

# PostgreSQL CRUD

## Propósito

Define los patrones de acceso a PostgreSQL en el proyecto usando Exposed DSL (estilo funcional,
no ActiveRecord). Incluye definición de tablas, wrapper `dbQuery` coroutine-safe, implementación
de repositorios como adapters de Clean Architecture y migraciones con Flyway.

## Cuándo usar esta skill

- Al crear una nueva tabla y su repositorio.
- Al implementar un adapter de repositorio en `infrastructure/db/`.
- Al crear o modificar migraciones Flyway.
- Al configurar la conexión a PostgreSQL por entorno.

## Cuándo NO usar esta skill

- Para lógica de negocio → `clean-architecture`.
- Para configurar tests → `unit-testing-kotlin`.

---

## Stack

| Dependencia | Versión recomendada |
|---|---|
| `org.jetbrains.exposed:exposed-core` | `0.5x` |
| `org.jetbrains.exposed:exposed-jdbc` | `0.5x` |
| `org.jetbrains.exposed:exposed-kotlin-datetime` | `0.5x` |
| `org.flywaydb:flyway-core` | `10.x` |
| `org.postgresql:postgresql` | `42.x` |
| `com.zaxxer:HikariCP` | `5.x` |

---

## Pasos de ejecución

### 1. Definir la tabla Exposed (en `infrastructure/db/table/`)

```kotlin
// infrastructure/db/table/ResourceTable.kt
import org.jetbrains.exposed.sql.Table
import org.jetbrains.exposed.sql.kotlin.datetime.timestamp

object ResourceTable : Table("resources") {
    val id          = varchar("id", 36)
    val name        = varchar("name", 255)
    val content     = text("content")
    val projectId   = varchar("project_id", 36).references(ProjectTable.id)
    val createdAt   = timestamp("created_at")
    val updatedAt   = timestamp("updated_at")

    override val primaryKey = PrimaryKey(id)
}
```

**Reglas de naming SQL:**
- Nombres de tablas en `snake_case` plural (`resources`, `projects`, `templates`).
- Nombres de columnas en `snake_case`.
- PKs siempre `varchar(36)` con UUID como valor.
- FKs referencian con `.references(OtherTable.column)`.

### 2. Crear la migración Flyway

**Ubicación:** `src/main/resources/db/migration/`

**Naming:** `V<N>__<descripcion_en_snake_case>.sql`

```sql
-- V1__create_resources_table.sql
CREATE TABLE resources (
    id          VARCHAR(36)   NOT NULL PRIMARY KEY,
    name        VARCHAR(255)  NOT NULL,
    content     TEXT          NOT NULL,
    project_id  VARCHAR(36)   NOT NULL REFERENCES projects(id),
    created_at  TIMESTAMP     NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP     NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_resources_project_id ON resources(project_id);
```

**Convención de numeración:**
- `V1__` Migración inicial (tablas base)
- `V2__` Siguientes tablas o cambios de esquema
- Nunca modificar una migración ya ejecutada; crear una nueva

### 3. Wrapper dbQuery (en `infrastructure/db/`)

```kotlin
// infrastructure/db/DatabaseFactory.kt
import kotlinx.coroutines.Dispatchers
import org.jetbrains.exposed.sql.Database
import org.jetbrains.exposed.sql.transactions.experimental.newSuspendedTransaction
import org.jetbrains.exposed.sql.transactions.transaction

object DatabaseFactory {

    fun init(url: String, user: String, password: String) {
        val config = HikariConfig().apply {
            jdbcUrl         = url
            username        = user
            this.password   = password
            maximumPoolSize = 10
            isAutoCommit    = false
            transactionIsolation = "TRANSACTION_REPEATABLE_READ"
            validate()
        }
        Database.connect(HikariDataSource(config))
    }
}

// Wrapper coroutine-safe para todas las queries
suspend fun <T> dbQuery(block: () -> T): T =
    newSuspendedTransaction(Dispatchers.IO) { block() }
```

### 4. Implementar el repositorio (en `infrastructure/db/`)

```kotlin
// infrastructure/db/ExposedResourceRepository.kt
class ExposedResourceRepository : ResourceRepository {

    override suspend fun save(resource: Resource): Unit = dbQuery {
        ResourceTable.insert { row ->
            row[id]        = resource.id.value
            row[name]      = resource.name
            row[content]   = resource.content
            row[projectId] = resource.projectId.value
            row[createdAt] = resource.createdAt
            row[updatedAt] = resource.updatedAt
        }
    }

    override suspend fun findById(id: ResourceId): Resource? = dbQuery {
        ResourceTable
            .select { ResourceTable.id eq id.value }
            .mapNotNull { it.toResource() }
            .singleOrNull()
    }

    override suspend fun findAll(): List<Resource> = dbQuery {
        ResourceTable
            .selectAll()
            .map { it.toResource() }
    }

    override suspend fun update(resource: Resource): Unit = dbQuery {
        ResourceTable.update({ ResourceTable.id eq resource.id.value }) { row ->
            row[name]      = resource.name
            row[content]   = resource.content
            row[updatedAt] = resource.updatedAt
        }
    }

    override suspend fun delete(id: ResourceId): Unit = dbQuery {
        ResourceTable.deleteWhere { ResourceTable.id eq id.value }
    }

    // Mapper: ResultRow → entidad de dominio
    private fun ResultRow.toResource() = Resource(
        id        = ResourceId(this[ResourceTable.id]),
        name      = this[ResourceTable.name],
        content   = this[ResourceTable.content],
        projectId = ProjectId(this[ResourceTable.projectId]),
        createdAt = this[ResourceTable.createdAt],
        updatedAt = this[ResourceTable.updatedAt]
    )
}
```

### 5. Configuración por entorno

**application.conf (Ktor HOCON):**
```hocon
database {
    url      = ${?DB_URL}
    user     = ${?DB_USER}
    password = ${?DB_PASSWORD}
}
```

**Carga en Application.kt:**
```kotlin
val dbUrl      = environment.config.property("database.url").getString()
val dbUser     = environment.config.property("database.user").getString()
val dbPassword = environment.config.property("database.password").getString()

DatabaseFactory.init(dbUrl, dbUser, dbPassword)
FlywayMigration.migrate(dbUrl, dbUser, dbPassword)
```

**Flyway bootstrap:**
```kotlin
// infrastructure/db/FlywayMigration.kt
object FlywayMigration {
    fun migrate(url: String, user: String, password: String) {
        Flyway.configure()
            .dataSource(url, user, password)
            .locations("classpath:db/migration")
            .load()
            .migrate()
    }
}
```

---

## Checklist de revisión

- [ ] **PG-01** La tabla está en `infrastructure/db/table/` como `object` que extiende `Table`
- [ ] **PG-02** La migración SQL usa naming `V<N>__<description>.sql` con `snake_case`
- [ ] **PG-03** Todas las queries usan `dbQuery { }` (coroutine-safe, nunca `transaction {}` directo en coroutines)
- [ ] **PG-04** El repositorio implementa la interface del `domain/repository/`
- [ ] **PG-05** La credenciales vienen de variables de entorno, nunca hardcodeadas
- [ ] **PG-06** HikariCP configurado con pool size razonable (10 por defecto)
- [ ] **PG-07** Existe un mapper `ResultRow → Entidad de dominio` como función de extensión privada
- [ ] **PG-08** Las migraciones existentes nunca se modifican; solo se añaden nuevas

---

## Outputs esperados

- Tabla Exposed en `infrastructure/db/table/` con naming SQL correcto.
- Migración `V<N>__*.sql` en `src/main/resources/db/migration/`.
- Repositorio implementado con `dbQuery` coroutine-safe.
- Configuración de conexión via variables de entorno.
- Flyway configurado para ejecutar migraciones en el arranque.

---

## Referencias

- [references/exposed-patterns.md](references/exposed-patterns.md) — Patrones Exposed DSL avanzados
