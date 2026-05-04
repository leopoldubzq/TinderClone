# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

SwiftUI iOS app — a Tinder-style swipe deck themed around Marvel Avengers. Single Xcode target (`TinderClone`), no backend, no Swift Package dependencies. All data comes from `User.mockData` in `Models/User.swift`.

- **Deployment target:** iOS 26.0. The codebase uses APIs introduced through iOS 18; all views assume iOS 26 as the baseline.
- **Swift version:** 5.0
- **Bundle ID:** `com.leopoldromanowski.TinderClone`
- **Devices:** iPhone + iPad (`TARGETED_DEVICE_FAMILY = "1,2"`).

## Build / run

There is no `Package.swift`, no workspace, no fastlane — just the `.xcodeproj`. Use Xcode or `xcodebuild` directly:

```bash
# Build for the iOS Simulator
xcodebuild -project TinderClone.xcodeproj -scheme TinderClone \
  -destination 'platform=iOS Simulator,name=iPhone 16' build

# Clean
xcodebuild -project TinderClone.xcodeproj -scheme TinderClone clean

# List available simulator destinations
xcodebuild -project TinderClone.xcodeproj -scheme TinderClone -showdestinations
```

There are **no tests** in this project — no test target exists in the `.pbxproj`. Don't fabricate `xcodebuild test` instructions.

## Architecture

The app is small (≈10 Swift files) but uses several non-obvious SwiftUI patterns. Reading just one file rarely tells the whole story.

### Folder layout

```
TinderClone/
├── TinderCloneApp.swift          # @main, injects NavigationManager via .environment
├── Models/User.swift             # Plain struct + static mockData (single source of users)
├── Navigation/
│   ├── NavigationManager.swift   # @Observable holding [Route]
│   ├── Route.swift               # enum Route: Hashable
│   └── Protocols/NavigationManageable.swift   # push/pop/popToRoot default impls
├── Presentation/
│   ├── Home/HomeView.swift       # NavigationStack root + card deck
│   ├── Home/Subviews/UserCardView.swift, InterestRowView.swift
│   ├── UserDetail/UserDetailView.swift
│   └── UserDetail/Subviews/ImageDetailView.swift
├── Utilis/                       # NOTE: misspelled folder name — keep using "Utilis" until renamed
│   ├── Constants.swift           # Constants.matches(_:) — highlights specific interests
│   └── TagLayout.swift           # Custom Layout for wrapping interest pills
└── Assets.xcassets/
    └── Colors/                   # CustomBackground, SecondaryCustomBackground, Tinder
```

### Navigation

`NavigationManager` is `@Observable` (Observation framework, iOS 17+), conforming to `NavigationManageable` whose extension provides `push` / `pop` / `popToRoot`. It is injected once in `TinderCloneApp` via `.environment(NavigationManager())`, then consumed in views via `@Environment(NavigationManager.self)`.

To get a `Binding` (e.g. `$navigationManager.route`), shadow with `@Bindable var navigationManager = navigationManager` as the first line of `body` — this is the official Apple pattern for `@Observable` injected via `@Environment`.

To add a new screen:
1. Add a case to `Route` (must stay `Hashable` — associated values must be hashable too; `User.id` is a `UUID` so `User` itself is fine).
2. Add a matching `case` to the `switch` inside `HomeView`'s `.navigationDestination(for: Route.self)`.
3. Push from any view via `navigationManager.push(.yourCase(...))` — never mutate `route` directly.

### Home card deck (`HomeView` + `UserCardView`)

- `HomeView` renders `users.reversed()` inside a `ZStack`. Only the **last** user (top of the visible stack) gets `cardIsVisible == true`; this is what gates the auto-advance image carousel timer in `UserCardView.handleVisibleImageTimeProgress()`. If you add new logic that depends on "is this the active card?", reuse `cardIsVisible(user:)` rather than recomputing it.
- A swipe past 200 px of horizontal translation triggers `onSwipe` → `HomeView.remove(_:)`. There is no rewind/like state stored anywhere — the user is just dropped from the local `@State` array.
- Tapping a card calls `onTap(visiblePictureIndex)`, which pushes `.userDetail(user:imageIndex:)` so the detail view opens on the same photo the user was looking at.

### Hero / zoom transitions

The Home → Detail transition uses iOS 18's `.navigationTransition(.zoom(sourceID:in:))` paired with `matchedTransitionSource(id:in:)` on the source card. Both sides share the `userDetailNamespace` declared in `HomeView`. Do not move this `@Namespace` — it must live on the source view that owns the `NavigationStack`.

The Detail → Image fullscreen transition inside `UserDetailView` uses a separate `imageDetailAnimation` `Namespace.ID` and `matchedGeometryEffect`. Don't conflate the two namespaces.

### Baseline APIs (iOS 26+)

These APIs are used unconditionally across `UserDetailView` and `UserCardView` — no `#available` guards needed:

- `.onScrollGeometryChange(for:of:action:)`
- `.onScrollVisibilityChange { ... }`
- `ScrollPosition` + `.scrollPosition(_:)` + `.scrollTargetBehavior(.paging)`
- `.navigationTransition(.zoom(...))`
- `matchedTransitionSource(id:in:)`
- `.toolbarVisibility(.hidden, for:)`
- `glassEffect(_:in:)` — used directly at call sites, no wrapper helper

Do not lower the deployment target below iOS 26.0 without auditing every one of these.

### Theming

Use `Color.tinder` / `Color.customBackground` / `Color.secondaryCustomBackground` instead of string literals. These are auto-generated by Xcode from `Assets.xcassets` (via `ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES`). Renaming a color asset means updating all call sites (grep the codebase).

`Constants.matches(_:)` returns `true` for `["Art", "Hiking", "Photography"]` and is used by `InterestRowView` to apply the brand `Color.tinder` gradient to "matched" interests. Peter Parker (`spidey`) has `"Photography"` in his interests, so the highlight is active for that tag. All other mock users have no matching interests — extend `Constants.matches` or the mock data to highlight more.

### `TagLayout`

`Utilis/TagLayout.swift` is a custom `Layout` that wraps subviews into rows (used for the interest pills). It supports `.leading` / `.center` / `.trailing` alignment via the `alignment` property. Prefer reusing it over hand-rolling a flow layout.
