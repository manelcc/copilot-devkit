---
name: devkit-swiftui-testing-xctest
description: >
  Practical testing patterns for SwiftUI features using XCTest, asynchronous
  expectations, and UI test coverage for key interaction flows.
triggers:
  - "swiftui testing xctest"
  - "xctest async tests"
  - "ios ui tests"
  - "xctest assertions"
non_triggers:
  - "android espresso"
  - "backend integration tests"
  - "snapshot tooling setup only"
---

# SwiftUI Testing XCTest

## Purpose
Standardize test design for SwiftUI features with XCTest to ensure deterministic behavior for async logic and user interactions.

## When to use
- You need unit tests for view models and domain logic used by SwiftUI views.
- You need async test coverage for loading/error/retry flows.
- You need UI tests for critical user journeys.

## When NOT to use
- Pure prototyping without test targets.
- Non-Apple platforms.
- Performance profiling only (without correctness assertions).

## Inputs
- Feature acceptance criteria and critical scenarios.
- Public interfaces to test (view model APIs, services, use cases).
- Existing test target and dependency injection strategy.

## Steps
1. Define test scenarios using arrange-act-assert.
2. Add deterministic unit tests for view models and services.
3. Add async tests using XCTest expectations or async test methods.
4. Use test doubles for network/persistence boundaries.
5. Cover error and retry paths explicitly.
6. Add UI tests for critical navigation and interaction flows.
7. Measure key hot paths with XCTest performance tests when needed.
8. Keep tests isolated, repeatable, and independent.

## Expected outputs
- Unit tests covering success/error/empty/retry states.
- Async tests validating task completion and state updates.
- UI tests for main user flows.
- Test suite runnable in CI with deterministic outcomes.

## Validation
- [ ] Uses XCTest APIs (`XCTestCase`, `XCTAssert*`) correctly.
- [ ] Includes asynchronous test coverage.
- [ ] Covers at least one failure path.
- [ ] Uses test doubles instead of real network calls.
- [ ] `references/overview.md` contains Mermaid workflow.

## Examples

### Example 1 - Async ViewModel unit test

```swift
import XCTest
@testable import MyApp

final class LoginViewModelTests: XCTestCase {
    func test_login_success_updatesState() async throws {
        let auth = AuthServiceMock(result: .success(User(id: "1", name: "Ana")))
        let sut = LoginViewModel(authService: auth)

        await sut.login(username: "ana", password: "secret")

        XCTAssertEqual(sut.state, .authenticated)
        XCTAssertEqual(sut.user?.name, "Ana")
    }

    func test_login_failure_setsError() async throws {
        let auth = AuthServiceMock(result: .failure(AuthError.invalidCredentials))
        let sut = LoginViewModel(authService: auth)

        await sut.login(username: "ana", password: "wrong")

        XCTAssertEqual(sut.state, .error)
        XCTAssertNotNil(sut.errorMessage)
    }
}
```

### Example 2 - Basic UI flow test

```swift
import XCTest

final class CheckoutFlowUITests: XCTestCase {
    func test_checkout_showsConfirmation() {
        let app = XCUIApplication()
        app.launch()

        app.buttons["Start checkout"].tap()
        app.buttons["Confirm"].tap()

        XCTAssertTrue(app.staticTexts["Order confirmed"].exists)
    }
}
```

## Sources
- Apple XCTest documentation: https://developer.apple.com/documentation/xctest
