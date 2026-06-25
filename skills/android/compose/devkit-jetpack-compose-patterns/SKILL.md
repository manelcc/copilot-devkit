---
name: devkit-jetpack-compose-patterns
description: >
  Practical guidance for implementing modern Jetpack Compose features using
  production-ready patterns: state hoisting, remember/rememberSaveable,
  LazyColumn, side effects, custom layout, and performance tuning.
triggers:
  - "compose state hoisting"
  - "remember saveable in compose"
  - "compose side effects"
  - "optimize compose performance"
  - "custom layout in compose"
non_triggers:
  - "android ci pipeline"
  - "backend api design"
  - "ios swiftui patterns"
---

# Jetpack Compose Patterns

## Purpose
Provide a practical, repeatable workflow to implement core Compose patterns with predictable state management, scalable UI composition, and safer runtime behavior.

## When to use
- You are building a new Compose feature and need robust state management.
- You are refactoring legacy Compose code with unstable recompositions.
- You need concrete examples for side effects, list rendering, and custom layout.

## When NOT to use
- XML to Compose migrations end-to-end (use `devkit-migrate-xml-to-compose`).
- Navigation architecture design across destinations (use `android-navigation-compose`).
- Non-Android or non-Compose projects.

## Inputs
- Feature context: screen purpose, UI states, and events.
- Existing ViewModel or state holder strategy.
- Compose and Kotlin versions used in the module.
- Optional performance concerns (jank, unnecessary recomposition, scroll issues).

## Steps
1. Model UI state and events first.
2. Apply state hoisting and split stateful vs stateless composables.
3. Use `remember` and `rememberSaveable` intentionally.
4. Render large collections with `LazyColumn` and stable keys.
5. Isolate side effects with `LaunchedEffect` and `DisposableEffect`.
6. Use custom `Layout` only when standard composables cannot express the design.
7. Tune recomposition with `derivedStateOf`, and stable immutable models.
8. Validate with previews and runtime checks before finishing.

### Pattern notes
- State hoisting: keep business and screen state in ViewModel, pass immutable state + callbacks to UI.
- `remember` vs `rememberSaveable`: use `remember` for ephemeral state, `rememberSaveable` for process/config survival.
- Lazy lists: use `items(items, key = { it.id })` to preserve item identity.
- Side effects: avoid launching coroutines directly in composable bodies.
- Custom layout: prefer `Modifier.layout` for simple adjustments, full `Layout` for custom measurement/placement.
- Performance: favor immutable UI models and compute expensive derived values with `derivedStateOf`.

## Expected outputs
- Screen architecture with state hoisting and deterministic event flow.
- Compose implementations using side effects safely.
- List implementation that preserves item identity and scroll state.
- Performance-oriented state model with reduced unnecessary recomposition.

## Validation
- [ ] `SKILL.md` contains required frontmatter and sections.
- [ ] Examples include real Kotlin Compose code.
- [ ] `references/overview.md` exists and includes Mermaid diagram.
- [ ] Guidance references official Android skills and docs when relevant.

## Examples

### Example 1 - State hoisting + rememberSaveable + LazyColumn

```kotlin
@Immutable
data class FeedUiState(
    val posts: List<PostUi> = emptyList(),
    val query: String = "",
    val isLoading: Boolean = false,
)

@Composable
fun FeedRoute(
    state: FeedUiState,
    onQueryChange: (String) -> Unit,
    onPostClick: (String) -> Unit,
) {
    var showOnlyUnread by rememberSaveable { mutableStateOf(false) }

    val filteredPosts by remember(state.posts, state.query, showOnlyUnread) {
        derivedStateOf {
            state.posts
                .asSequence()
                .filter { it.title.contains(state.query, ignoreCase = true) }
                .filter { !showOnlyUnread || !it.isRead }
                .toList()
        }
    }

    FeedScreen(
        query = state.query,
        onQueryChange = onQueryChange,
        showOnlyUnread = showOnlyUnread,
        onToggleUnread = { showOnlyUnread = !showOnlyUnread },
        posts = filteredPosts,
        onPostClick = onPostClick,
    )
}

@Composable
fun FeedScreen(
    query: String,
    onQueryChange: (String) -> Unit,
    showOnlyUnread: Boolean,
    onToggleUnread: () -> Unit,
    posts: List<PostUi>,
    onPostClick: (String) -> Unit,
) {
    Column {
        SearchBar(query = query, onQueryChange = onQueryChange)
        FilterChip(
            selected = showOnlyUnread,
            onClick = onToggleUnread,
            label = { Text("Unread only") },
        )
        LazyColumn {
            items(posts, key = { it.id }) { post ->
                PostRow(post = post, onClick = { onPostClick(post.id) })
            }
        }
    }
}
```

### Example 2 - Side effects + DisposableEffect + custom Layout

```kotlin
@Composable
fun SensorAwareHeader(
    sensorManager: SensorManager,
    onTiltChanged: (Float) -> Unit,
    modifier: Modifier = Modifier,
    content: @Composable () -> Unit,
) {
    DisposableEffect(sensorManager) {
        val listener = object : SensorEventListener {
            override fun onSensorChanged(event: SensorEvent) {
                onTiltChanged(event.values.firstOrNull() ?: 0f)
            }
            override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) = Unit
        }

        val sensor = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
        sensorManager.registerListener(listener, sensor, SensorManager.SENSOR_DELAY_UI)

        onDispose {
            sensorManager.unregisterListener(listener)
        }
    }

    Layout(
        content = content,
        modifier = modifier,
    ) { measurables, constraints ->
        val placeables = measurables.map { it.measure(constraints) }
        val width = placeables.maxOfOrNull { it.width } ?: constraints.minWidth
        val height = placeables.sumOf { it.height }
        layout(width, height) {
            var y = 0
            placeables.forEach { p ->
                p.placeRelative(0, y)
                y += p.height
            }
        }
    }
}

@Composable
fun LoginRoute(onReady: () -> Unit) {
    LaunchedEffect(Unit) {
        onReady()
    }
}
```

## Sources
- Android Skills: `jetpack-compose/migration/migrate-xml-views-to-jetpack-compose`
- Android Skills: `jetpack-compose/adaptive`
- Android developer guidance for Compose state, side effects, and performance.