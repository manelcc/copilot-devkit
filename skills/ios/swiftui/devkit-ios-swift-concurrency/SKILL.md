---
name: devkit-ios-swift-concurrency
description: >
  Structured guidance for Swift concurrency in iOS features: async/await,
  Task, task groups, MainActor isolation, and cancellation-safe UI updates.
triggers:
  - "swift concurrency ios"
  - "async await swift"
  - "task group swift"
  - "mainactor ui updates"
non_triggers:
  - "android coroutines"
  - "database migrations"
  - "ios ui layout only"
---

# iOS Swift Concurrency

## Purpose
Guide implementation of reliable asynchronous workflows in iOS apps using Swift concurrency primitives with clear actor-isolation rules.

## When to use
- You need async data loading in SwiftUI or UIKit.
- You are migrating callback-based APIs to async/await.
- You need cancellation-aware tasks tied to view lifecycle.

## When NOT to use
- Purely synchronous business logic.
- Concurrency-agnostic UI style tasks.
- Non-Swift codebases.

## Inputs
- Async use case definitions (single request, fan-out, chained operations).
- Existing API shape (callback, Combine publisher, async function).
- UI thread and state update constraints.

## Steps
1. Identify async boundaries and failure/cancellation points.
2. Prefer `async/await` over nested callbacks.
3. Use `Task {}` for scoped async work and cancellation propagation.
4. Use `withThrowingTaskGroup` when fan-out concurrency is needed.
5. Isolate UI mutations with `@MainActor`.
6. Handle cancellation explicitly with `Task.isCancelled` when needed.
7. Bridge legacy APIs using checked continuations.
8. Validate success, error, timeout, and cancellation behavior.

## Expected outputs
- Async implementation with structured concurrency.
- Correct main-thread UI updates under `@MainActor`.
- Cancellation-safe feature behavior.
- Minimal callback bridging code using checked continuations.

## Validation
- [ ] Uses `async/await` as primary async model.
- [ ] Uses `Task {}` or task groups where appropriate.
- [ ] UI updates are main-actor isolated.
- [ ] Includes cancellation handling strategy.
- [ ] `references/overview.md` includes Mermaid diagram.

## Examples

### Example 1 - MainActor-safe loading

```swift
import Foundation

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published private(set) var cards: [Card] = []
    @Published private(set) var isLoading = false

    func refresh() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            cards = try await DashboardService.shared.fetchCards()
        } catch {
            cards = []
        }
    }
}
```

### Example 2 - Task group fan-out

```swift
import Foundation

func loadHomePayload() async throws -> HomePayload {
    try await withThrowingTaskGroup(of: PartialPayload.self) { group in
        group.addTask { .profile(try await API.profile()) }
        group.addTask { .accounts(try await API.accounts()) }
        group.addTask { .offers(try await API.offers()) }

        var profile: Profile?
        var accounts: [Account] = []
        var offers: [Offer] = []

        for try await part in group {
            switch part {
            case .profile(let value): profile = value
            case .accounts(let value): accounts = value
            case .offers(let value): offers = value
            }
        }

        guard let profile else { throw HomeError.missingProfile }
        return HomePayload(profile: profile, accounts: accounts, offers: offers)
    }
}
```

## Sources
- Apple Swift Concurrency documentation: https://developer.apple.com/documentation/swift/concurrency
