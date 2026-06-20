---
name: devkit-migrate-xml-to-compose
description: >
  Structured Android migration workflow from XML Views to Jetpack Compose.
  Use this skill to plan, implement, validate and finalize an incremental UI
  migration while preserving behavior and visual parity.
triggers:
  - "migrate xml to compose"
  - "convert xml views to jetpack compose"
  - "move legacy android view to compose"
  - "compose migration from xml"
non_triggers:
  - "build ci pipeline"
  - "backend api refactor"
  - "ios swiftui migration"
---

# Devkit Migrate XML To Compose

## Purpose
Provide a safe, repeatable process to migrate a legacy Android XML screen to Jetpack Compose with minimal regression risk.

## When to use
- A feature still uses XML layouts and needs to move to Compose.
- Team needs incremental migration with interoperability during transition.
- You need a structured checklist from discovery to XML cleanup.

## When NOT to use
- Greenfield Compose screens with no XML legacy.
- Non-Android projects.
- Pure style-only updates that do not involve migration.

## Inputs
- Target XML layout file and related Fragment/Activity/View usage.
- Project build config (`build.gradle(.kts)` and/or `libs.versions.toml`).
- Optional baseline screenshot or visual reference.

## Steps
1. Identify the best XML candidate for migration scope.
2. Audit layout hierarchy, custom views, state holders and runtime dependencies.
3. Define an incremental migration plan and validate assumptions with the user.
4. Ensure Compose dependencies/compiler and minimum theming are available.
5. Translate XML structure into stateless composables and hoist state.
6. Add interoperability (`ComposeView` or `AndroidView`) where full replacement is not immediate.
7. Add Preview and UI tests to verify parity and reduce regression risk.
8. Replace call sites and remove obsolete XML resources only when safe.
9. For uncovered advanced cases, consult `https://github.com/android/skills` and adapt the guidance to this repository conventions.

Reference source material from awesome-copilot is documented in `references/overview.md`.

## Expected outputs
- New Compose implementation for the migrated screen.
- Updated call sites using Compose/interoperability APIs.
- Validation artifacts (Preview and/or UI tests).
- Legacy XML assets removed when no longer referenced.

## Validation
- Confirm visual and behavioral parity against baseline.
- Confirm no unresolved XML references remain.
- Confirm migration follows project conventions (Navigation, Hilt, Material3, Flow).

## Examples
- "Migrate `fragment_profile.xml` to Compose with interoperability first."
- "Convert `activity_checkout.xml` to Compose and keep behavior parity."
