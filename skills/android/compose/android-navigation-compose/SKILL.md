---
name: android-navigation-compose
description: >
  Guidance to implement Jetpack Navigation 3 in Compose apps with practical
  patterns for NavController/NavHost setup, composable destinations, argument
  passing, deep links, and multiple back stacks.
triggers:
  - "navigation 3 in compose"
  - "navcontroller navhost compose"
  - "compose deep links"
  - "multiple back stacks compose"
  - "pass arguments in navigation compose"
non_triggers:
  - "xml view migration"
  - "backend routing"
  - "ios navigation"
---

# Android Navigation Compose

## Purpose
Provide a practical workflow to design and implement Navigation 3 in Compose with stable destination modeling and scalable back stack management.

## When to use
- You are creating or refactoring app navigation in a Compose app.
- You need Navigation 3 patterns for deep links and multi-stack top-level navigation.
- You want type-safe-ish destination modeling with argument parsing boundaries.

## When NOT to use
- XML Fragment-based navigation migrations without Compose adoption.
- Single-screen features with no navigation concerns.
- Cross-platform routing that does not use Android Navigation 3.

## Inputs
- Navigation requirements: top-level sections, flows, and entry points.
- Destination argument model and constraints.
- Deep link URLs and expected in-app landing behavior.
- State persistence requirements across tabs and process death.

## Steps
1. Define destination model and route contracts.
2. Configure `NavController` and `NavHost` at app shell level.
3. Implement destinations with `composable {}` and explicit args parsing.
4. Add deep link handling and validation.
5. Implement multiple top-level back stacks for bottom bar or rail.
6. Preserve/restores state using `saveState` and `restoreState` navigation options.
7. Validate navigation behaviors (back, up, deep link, tab reselection).

### Pattern notes
- Keep route constants centralized and avoid scattering route strings.
- Parse navigation args at destination boundary, then pass typed values to screen functions.
- For tabbed apps, keep one back stack per top-level destination.
- For deep links, define a single URI contract per destination and test malformed cases.

## Expected outputs
- Navigation graph with explicit destination contracts.
- Deep link integration consistent with route parser and app entry points.
- Multi-back-stack behavior for top-level navigation with state preservation.

## Validation
- [ ] `SKILL.md` contains required frontmatter and mandatory sections.
- [ ] Examples include NavHost, composable destinations, args, deep links, and multi-stack navigation.
- [ ] `references/overview.md` exists with Mermaid flow.
- [ ] Guidance is aligned with Android Skills Navigation 3 recipes.

## Examples

### Example 1 - NavHost + arguments + deep links

```kotlin
sealed interface AppRoute {
    data object Home : AppRoute
    data class Detail(val itemId: String) : AppRoute
}

object Routes {
    const val HOME = "home"
    const val DETAIL = "detail/{itemId}"
    const val ARG_ITEM_ID = "itemId"
    const val DETAIL_URI = "myapp://detail/{itemId}"
}

@Composable
fun AppNavGraph(navController: NavHostController) {
    NavHost(
        navController = navController,
        startDestination = Routes.HOME,
    ) {
        composable(route = Routes.HOME) {
            HomeScreen(
                onItemClick = { itemId ->
                    navController.navigate("detail/$itemId")
                }
            )
        }

        composable(
            route = Routes.DETAIL,
            arguments = listOf(navArgument(Routes.ARG_ITEM_ID) { type = NavType.StringType }),
            deepLinks = listOf(navDeepLink { uriPattern = Routes.DETAIL_URI }),
        ) { backStackEntry ->
            val itemId = requireNotNull(backStackEntry.arguments?.getString(Routes.ARG_ITEM_ID))
            DetailScreen(itemId = itemId)
        }
    }
}
```

### Example 2 - Multiple back stacks in top-level tabs

```kotlin
enum class TopLevelDestination(val route: String) {
    Feed("feed"),
    Search("search"),
    Profile("profile"),
}

@Composable
fun AppShell() {
    val navController = rememberNavController()

    Scaffold(
        bottomBar = {
            NavigationBar {
                TopLevelDestination.entries.forEach { destination ->
                    NavigationBarItem(
                        selected = false,
                        onClick = {
                            navController.navigate(destination.route) {
                                popUpTo(navController.graph.findStartDestination().id) {
                                    saveState = true
                                }
                                launchSingleTop = true
                                restoreState = true
                            }
                        },
                        icon = { Icon(Icons.Default.Home, contentDescription = destination.route) },
                        label = { Text(destination.route) },
                    )
                }
            }
        }
    ) { padding ->
        NavHost(
            navController = navController,
            startDestination = TopLevelDestination.Feed.route,
            modifier = Modifier.padding(padding),
        ) {
            composable(TopLevelDestination.Feed.route) { FeedScreen() }
            composable(TopLevelDestination.Search.route) { SearchScreen() }
            composable(TopLevelDestination.Profile.route) { ProfileScreen() }
        }
    }
}
```

## Sources
- Android Skills: `navigation/navigation-3`
- Android Skills Navigation 3 recipes: basic, deep links, multiple back stacks.