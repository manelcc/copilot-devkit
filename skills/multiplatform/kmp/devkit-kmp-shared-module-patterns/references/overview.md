# KMP Shared Module Architecture Overview

## Typical Multiplatform Project Structure

```mermaid
graph TD
    subgraph "Shared Module (commonMain)"
        Domain["Domain Layer<br/>- Entities<br/>- Repository interfaces<br/>- Use cases<br/>(Zero platform deps)"]
        App["Application Layer<br/>- SharedViewModel<br/>- Interactors<br/>- expect/actual for coroutines<br/>- State management"]
        Infra["Infrastructure Layer<br/>- expect/actual for DB<br/>- expect/actual for HTTP<br/>- Serializers<br/>- expect/actual for platform specifics"]
    end

    subgraph "Android-Specific (androidMain)"
        AndroidImpl["Android Implementation<br/>- actual HttpClient Android<br/>- actual Database AndroidDriver<br/>- actual ViewModel Android"]
        AndroidUI["Android UI (Compose)<br/>- Screens<br/>- Activities<br/>- Fragments"]
    end

    subgraph "iOS-Specific (iosMain)"
        iOSImpl["iOS Implementation<br/>- actual HttpClient Darwin<br/>- actual Database NativeSqlite<br/>- actual SharedViewModel"]
        iOSUI["iOS UI (SwiftUI)<br/>- Views<br/>- ViewControllers<br/>@ObjCName / @Throws"]
    end

    subgraph "Tests"
        CommonTest["commonTest<br/>- JUnit5 + MockK<br/>- Platform-agnostic logic"]
        AndroidTest["androidTest<br/>- Android-specific"]
        iOSTest["iosTest<br/>- iOS-specific"]
    end

    Domain --> App
    App --> Infra
    Infra --> AndroidImpl
    Infra --> iOSImpl
    AndroidImpl --> AndroidUI
    iOSImpl --> iOSUI
    App --> CommonTest
    AndroidImpl --> AndroidTest
    iOSImpl --> iOSTest

    classDef shared fill:#e1f5ff,stroke:#01579b,stroke-width:2px
    classDef android fill:#fff3e0,stroke:#e65100,stroke-width:2px
    classDef ios fill:#f3e5f5,stroke:#4a148c,stroke-width:2px
    classDef test fill:#e8f5e9,stroke:#1b5e20,stroke-width:2px

    class Domain,App,Infra shared
    class AndroidImpl,AndroidUI android
    class iOSImpl,iOSUI ios
    class CommonTest,AndroidTest,iOSTest test
```

## Dependency Flow (Clean Architecture Rule)

```mermaid
graph LR
    Domain["Domain<br/>(Pure Logic)"]
    App["Application<br/>(Orchestration)"]
    Infra["Infrastructure<br/>(Platform Impl)"]
    Android["Android<br/>(actual)"]
    iOS["iOS<br/>(actual)"]

    Domain -->|Implements| App
    App -->|Uses| Infra
    Infra -->|Platform specific| Android
    Infra -->|Platform specific| iOS

    classDef rule fill:#ffebee,stroke:#c62828
    class Domain,App,Infra rule

    style Domain fill:#c8e6c9
    style App fill:#bbdefb
    style Infra fill:#ffe0b2
    style Android fill:#f8bbd0
    style iOS fill:#e1bee7
```

**Golden Rule:** Imports flow `Domain ← App ← Infrastructure ← Platform`. Never reverse.

## expect/actual Placement Guide

```mermaid
graph TD
    Concern{What needs<br/>to be platform-specific?}
    
    Concern -->|HTTP Client| HttpClient["httpClient: HttpClient<br/>commonMain: expect<br/>androidMain: actual HttpClient Android<br/>iosMain: actual HttpClient Darwin"]
    
    Concern -->|Database| Database["DatabaseFactory<br/>commonMain: expect fun createDB<br/>androidMain: actual Android SQLite<br/>iosMain: actual Native SQLite"]
    
    Concern -->|Coroutines| Coroutines["Dispatcher for Main thread<br/>commonMain: expect Dispatcher<br/>androidMain: actual Main<br/>iosMain: actual Main"]
    
    Concern -->|Logging| Logging["Logger interface<br/>commonMain: expect<br/>androidMain: actual Android Log<br/>iosMain: actual NSLog"]
    
    Concern -->|File I/O| FileIO["FileRepository<br/>commonMain: expect<br/>androidMain: actual Context.filesDir<br/>iosMain: actual FileManager"]
    
    Concern -->|Serialization| Serialization["JSON parser<br/>commonMain: expect<br/>androidMain: actual Gson/Kotlinx<br/>iosMain: actual JSONDecoder"]

    style Concern fill:#fff9c4
    style HttpClient fill:#c8e6c9
    style Database fill:#c8e6c9
    style Coroutines fill:#c8e6c9
    style Logging fill:#c8e6c9
    style FileIO fill:#c8e6c9
    style Serialization fill:#c8e6c9
```

## expect/actual Pattern Template

```kotlin
// ============ commonMain/kotlin/com/example/shared/DataLayer.kt ============

// ✅ Interface in commonMain (contract visible to domain)
expect interface UserRepository {
    suspend fun getUser(id: String): User
    suspend fun saveUser(user: User)
}

// ✅ expect function for platform-specific logic
expect fun createDatabaseConnection(): DatabaseConnection

// ❌ DON'T: Platform-specific class in commonMain
// expect class AndroidDatabase { }  // ← WRONG

// ============ androidMain/kotlin/com/example/shared/DataLayer.kt ============

// ✅ actual implementation for Android
actual class UserRepositoryImpl(
    private val db: SQLiteDatabase,
    private val httpClient: HttpClient
) : UserRepository {
    actual override suspend fun getUser(id: String): User = ...
    actual override suspend fun saveUser(user: User) { ... }
}

actual fun createDatabaseConnection(): DatabaseConnection =
    AndroidDatabase(context, "app.db")

// ============ iosMain/kotlin/com/example/shared/DataLayer.kt ============

// ✅ actual implementation for iOS
actual class UserRepositoryImpl(
    private val db: NativeDatabase,
    private val httpClient: HttpClient
) : UserRepository {
    actual override suspend fun getUser(id: String): User = ...
    actual override suspend fun saveUser(user: User) { ... }
}

actual fun createDatabaseConnection(): DatabaseConnection =
    iOSDatabase("/var/mobile/Containers/Data/app")
```

## Source Set Visibility Rules

```mermaid
graph TB
    CommonMain["commonMain<br/>(Visible to all)"]
    AndroidMain["androidMain<br/>(Android only)"]
    iOSMain["iosMain<br/>(iOS only)"]
    CommonTest["commonTest<br/>(Unit tests)"]

    CommonMain -->|Can see| CommonMain
    AndroidMain -->|Can see| CommonMain
    AndroidMain -->|CAN'T see| iOSMain
    iOSMain -->|Can see| CommonMain
    iOSMain -->|CAN'T see| AndroidMain

    CommonTest -->|Can test| CommonMain
    CommonTest -->|CAN'T test| AndroidMain
    CommonTest -->|CAN'T test| iOSMain

    classDef rule fill:#ffccbc
    classDef safe fill:#c8e6c9
    classDef danger fill:#ffcdd2

    class CommonMain safe
    class AndroidMain,iOSMain safe
    class CommonTest safe
```

## iOS Interop: @ObjCName and @Throws

```mermaid
graph LR
    Swift["Swift Code"]
    Kotlin["Kotlin shared<br/>module"]
    ObjC["Objective-C API<br/>@ObjCName"]
    Throws["Exception mapping<br/>@Throws"]

    Swift -->|Calls| Kotlin
    Kotlin -->|Maps with| ObjC
    Kotlin -->|Maps with| Throws
    ObjC -->|Visible as| IosAPI["iOS.UserRepository.getUser<br/>error: NSError"]
    Throws -->|Becomes| SwiftError["throws Error<br/>in Swift"]

    classDef interop fill:#f3e5f5
    class ObjC,Throws,IosAPI,SwiftError interop
```

## Testing Structure in KMP

```mermaid
graph TD
    Test["Test Layer Strategy"]
    
    Test --> Unit["Unit Tests (commonTest)<br/>- JUnit5<br/>- MockK<br/>- Kotest assertions<br/>- Platform-agnostic logic<br/>- No Android/iOS framework"]
    
    Test --> AndroidTest["Android Tests (androidTest)<br/>- Espresso / Robolectric<br/>- Android-specific mocks<br/>- Database driver tests"]
    
    Test --> iOSTest["iOS Tests (iosTest)<br/>- XCTest<br/>- iOS-specific mocks<br/>- Database driver tests"]

    Unit -->|Coverage ≥40%| JaCoCo["JaCoCo Report"]
    
    style Test fill:#fff9c4
    style Unit fill:#c8e6c9
    style AndroidTest fill:#fff3e0
    style iOSTest fill:#f3e5f5
```

## Ktor Client Configuration (Shared)

```kotlin
// commonMain
expect val httpClient: HttpClient

// Usage in domain:
val response = httpClient.get("https://api.example.com/users") {
    header("Authorization", "Bearer token")
}

// androidMain
actual val httpClient: HttpClient = HttpClient(Android) {
    install(ContentNegotiation) { json() }
    install(Logging) {
        logger = Logger.DEFAULT
        level = LogLevel.ALL
    }
}

// iosMain
actual val httpClient: HttpClient = HttpClient(Darwin) {
    install(ContentNegotiation) { json() }
    // Darwin-specific config
}
```

## SQLDelight in Shared Module

```
shared/build.gradle.kts
sqldelight {
    databases {
        create("AppDatabase") {
            packageName.set("com.example.app.db")
            schemaOutputDirectory.set(file("src/commonMain/sqldelight"))
        }
    }
}

src/
├── commonMain/sqldelight/
│   └── com/example/app/User.sq   (Shared SQL queries)
├── androidMain/kotlin/
│   └── DatabaseFactory.kt        (Android driver)
└── iosMain/kotlin/
    └── DatabaseFactory.kt        (iOS driver)
```

## Complete Example: User Repository Pattern

```mermaid
graph TB
    Domain["Domain (commonMain)"]
    App["Application (commonMain)"]
    Infra["Infrastructure (commonMain)"]
    Android["Android Impl (androidMain)"]
    iOS["iOS Impl (iosMain)"]

    Domain -->|Defines| UserRepo["interface UserRepository"]
    App -->|Uses| UserRepo
    Infra -->|Implements| UserRepoImpl["class UserRepositoryImpl<br/>expect/actual deps"]
    UserRepoImpl -->|Platform impl| Android
    UserRepoImpl -->|Platform impl| iOS

    Android -->|SQLite<br/>OkHttp| AndroidPlatform["Android Framework"]
    iOS -->|SQLite<br/>URLSession| iOSPlatform["iOS Framework"]

    classDef layer fill:#bbdefb
    class Domain,App,Infra layer
```

## Guardrail: Circular Dependency Prevention

```mermaid
graph LR
    User["User Entity<br/>(Domain)"]
    Repository["UserRepository<br/>(Domain Interface)"]
    UseCase["GetUserUseCase<br/>(Application)"]
    Impl["UserRepositoryImpl<br/>(Infrastructure)"]
    
    Repository -->|Uses| User
    UseCase -->|Uses| Repository
    Impl -->|Implements| Repository
    Impl -->|Returns| User
    
    ❌["❌ DON'T:<br/>Impl → UseCase<br/>Impl → Domain<br/>Domain → Impl"]
    
    classDef safe fill:#c8e6c9
    classDef danger fill:#ffcdd2
    
    class User,Repository,UseCase,Impl safe
    class ❌ danger
```
