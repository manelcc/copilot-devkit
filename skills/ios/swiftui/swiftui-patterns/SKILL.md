---
name: swiftui-patterns
description: >
  Practical SwiftUI patterns for feature delivery using state wrappers,
  NavigationStack, structured concurrency with task {}, and scalable list
  rendering.
triggers:
  - "swiftui state patterns"
  - "@state @binding swiftui"
  - "navigationstack swiftui"
  - "swiftui async await task"
  - "list lazyvstack swiftui"
non_triggers:
  - "android compose"
  - "backend api"
  - "ci pipeline"
---

# SwiftUI Patterns

## Purpose
Provide a repeatable workflow to build SwiftUI features with robust state management, modern navigation, and predictable async behavior.

## When to use
- You are implementing or refactoring a SwiftUI screen.
- You need clear rules for `@State`, `@Binding`, and `@ObservableObject` usage.
- You need to combine `NavigationStack` with async data loading and list rendering.

## When NOT to use
- UIKit-only screens with no SwiftUI integration.
- Non-iOS projects.
- Networking architecture design without UI scope.

## Inputs
- Feature requirements and screen states (loading, content, error, empty).
- Existing view model strategy (`@Observable` or `ObservableObject`).
- Navigation requirements (push, deep-link entry, back behavior).
- Data source behavior for async loading.

## Steps
1. Model immutable UI state and user intents.
2. Use `@State` for local transient view state.
3. Use `@Binding` for parent-child state synchronization.
4. Use `@ObservableObject` (or `@Observable`) for shared screen/business state.
5. Build navigation using `NavigationStack` and typed route values.
6. Trigger async loading with `.task {}` and keep UI updates on main actor.
7. Render collections with `List` or `ScrollView` + `LazyVStack` based on UX needs.
8. Validate loading/error/empty/content transitions and navigation behavior.

## Expected outputs
- A SwiftUI feature with explicit state ownership boundaries.
- Navigation implemented with `NavigationStack` (not `NavigationView`).
- Async loading lifecycle handled through `.task {}`.
- List rendering strategy documented and consistent with UI behavior.

## Validation
- [ ] Includes `@State`, `@Binding`, and `@ObservableObject` guidance.
- [ ] Uses `NavigationStack` for navigation examples.
- [ ] Includes async/await with `.task {}` example.
- [ ] Includes both `List` and `LazyVStack` usage guidance.
- [ ] `references/overview.md` exists with Mermaid diagram.

## Examples

### Example 1 - State wrappers + NavigationStack + task

```swift
import SwiftUI

final class ProductsViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    @MainActor
    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        do {
            products = try await ProductService.shared.fetchProducts()
            errorMessage = nil
        } catch {
            errorMessage = "Could not load products"
        }
    }
}

struct ProductsView: View {
    @StateObject private var viewModel = ProductsViewModel()
    @State private var path: [Product] = []

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if let error = viewModel.errorMessage {
                    Text(error)
                } else {
                    List(viewModel.products, id: \.id) { product in
                        NavigationLink(value: product) {
                            Text(product.name)
                        }
                    }
                }
            }
            .navigationTitle("Products")
            .navigationDestination(for: Product.self) { product in
                ProductDetailView(product: product)
            }
        }
        .task {
            await viewModel.loadProducts()
        }
    }
}
```

### Example 2 - Binding + LazyVStack

```swift
import SwiftUI

struct FilterBar: View {
    @Binding var showOnlyFavorites: Bool

    var body: some View {
        Toggle("Favorites only", isOn: $showOnlyFavorites)
            .toggleStyle(.switch)
    }
}

struct FeedView: View {
    @State private var showOnlyFavorites = false
    let items: [FeedItem]

    var filteredItems: [FeedItem] {
        showOnlyFavorites ? items.filter(\.isFavorite) : items
    }

    var body: some View {
        VStack {
            FilterBar(showOnlyFavorites: $showOnlyFavorites)
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(filteredItems, id: \.id) { item in
                        FeedRow(item: item)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
```

## Sources
- Apple SwiftUI documentation: https://developer.apple.com/documentation/swiftui
- Apple Swift Concurrency documentation: https://developer.apple.com/documentation/swift/concurrency
