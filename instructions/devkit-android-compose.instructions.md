---
applyTo: "**/*.kt"
---

# Devkit Android Compose Instructions

## Scope
Apply these rules to Android Kotlin code targeting Jetpack Compose. Keep solutions incremental, testable, and aligned with existing project conventions.

## Composables
- Prefer stateless composables and hoist state to callers or ViewModel.
- Keep composables focused on one responsibility; split when a function grows too much.
- Use immutable UI models for screen state and one-shot events.

## Navigation
- Use Navigation 3 as the default for new flows.
- Model navigation through typed routes and avoid stringly-typed ad-hoc routes.
- Keep navigation side effects outside composable rendering blocks.

## Dependency Injection
- Use Hilt for dependency wiring.
- Inject ViewModels through Hilt integrations and avoid manual service locator patterns.
- Keep DI boundaries at module and feature edges; do not inject infrastructure directly into UI composables.

## Coroutines And Flow
- Expose screen state as `StateFlow` from ViewModel.
- Collect state in UI with lifecycle-aware APIs.
- Use structured concurrency and avoid launching unmanaged coroutines from composables.

## Material3
- Use Material3 components and theme tokens as default.
- Avoid hardcoded colors, typography, or spacing when theme tokens exist.
- Keep accessibility in mind (content descriptions, contrast, touch targets).

## Testing
- Add UI coverage with `composeTestRule` for critical user flows.
- Prefer semantic matchers and stable test tags over brittle hierarchy selectors.
- Validate loading, success, and error states when applicable.

## Devkit Skills Reference
- Use `skills/android/compose/devkit-migrate-xml-to-compose/` for XML to Compose migration workflows.
- Use `skills/android/compose/devkit-jetpack-compose-patterns/` for idiomatic architecture and UI patterns.

## External Android Skills Integration
- When local devkit skills do not cover an edge case, consult `https://github.com/android/skills` as a complementary source.
- Prefer local devkit conventions first, then adapt external guidance to project naming, architecture, and testing rules.
- If external guidance conflicts with repository standards, keep repository standards and document the trade-off in the change notes.

