# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

SwiftUI iOS app — a Tinder-style swipe deck themed around Marvel Avengers. Single Xcode target (`TinderClone`), no backend, no Swift Package dependencies. All data comes from `User.mockData` in `Models/User.swift`.

- **Deployment target:** iOS 18.0 (the code relies heavily on iOS 18-only APIs — see Architecture). Do not lower this without rewriting affected views.
- **Swift version:** 5.0
- **Bundle ID:** `com.leopoldromanowski.TinderClone`
- **Devices:** iPhone + iPad (`TARGETED_DEVICE_FAMILY = "1,2"`).
- iOS 26 features (Liquid Glass) gated behind `#available(iOS 26.0, *)` via `Utilis/View+GlassEffect.swift`.

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
│   ├── TagLayout.swift           # Custom Layout for wrapping interest pills
│   └── View+GlassEffect.swift    # Liquid Glass gate: glassBackground(in:) / glassBackgroundTinted(_:in:)
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

### iOS 18 baseline APIs (do not regress)

These are scattered across `UserDetailView` and `UserCardView` and break on iOS 17 or earlier:

- `.onScrollGeometryChange(for:of:action:)`
- `.onScrollVisibilityChange { ... }`
- `ScrollPosition` + `.scrollPosition(_:)` + `.scrollTargetBehavior(.paging)`
- `.navigationTransition(.zoom(...))`
- `matchedTransitionSource(id:in:)`
- `.toolbarVisibility(.hidden, for:)`

If you touch these views, keep the deployment target at 18.0 or guard with `#available`.

### iOS 26 conditional APIs

Used exclusively inside `#available(iOS 26.0, *)` guards — never called on iOS 18:

- `glassEffect(_:in:)` — via `glassBackground(in:)` helper or inline in top bar
- `GlassEffectContainer` — wraps action buttons in `UserCardView`
- `.buttonStyle(.glass)` / `.buttonStyle(.glassProminent)` — on action buttons inside `GlassEffectContainer`

The single gate point is `Utilis/View+GlassEffect.swift`. Add all new Liquid Glass usage there or behind a local `#available` block.

### Theming

Use `Color.tinder` / `Color.customBackground` / `Color.secondaryCustomBackground` instead of string literals. These are auto-generated by Xcode from `Assets.xcassets` (via `ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES`). Renaming a color asset means updating all call sites (grep the codebase).

`Constants.matches(_:)` returns `true` for `["Art", "Hiking", "Photography"]` and is used by `InterestRowView` to apply the brand `Color.tinder` gradient to "matched" interests. Note: none of those three strings appear in the current `User.mockData` interests, so the highlight is effectively dormant until either the matcher list or the mock data changes.

### `TagLayout`

`Utilis/TagLayout.swift` is a custom `Layout` that wraps subviews into rows (used for the interest pills). It supports `.leading` / `.center` / `.trailing` alignment via the `alignment` property. Prefer reusing it over hand-rolling a flow layout.
