# DateSpark 🔥 — Swift 6 Edition

A beautifully crafted iOS app to spark real conversations on dates and social gatherings.

## Swift 6 Features Used

| Feature | Where |
|---|---|
| `@Observable` macro | `AppState` — replaces `ObservableObject` / `@Published` |
| `@Environment(AppState.self)` | All views — new typed environment injection |
| `@MainActor` on types | All views + `AppState` — compile-time actor isolation |
| `actor DataProvider` | Concurrency-safe data access with `nonisolated` read methods |
| `async/await` + `Task` | `SplashView.animateIn()`, `HomeView.loadQuestions()`, `SpinWheelView.spin()` |
| `Task.sleep(for:)` | Typed `Duration` API instead of `DispatchQueue.asyncAfter` |
| `Task.isCancelled` | Checked in animation sequences to avoid stale updates |
| `if let x` short-hand | `if let category { ... }` throughout |
| `switch` expression | All `var` computed properties on enums (no `return`) |
| `Sendable` conformance | `Question`, `QuestionCategory`, `QuestionDepth`, `OnboardingPage` |
| `nonisolated` | `DataProvider` query methods callable from any context |
| Closure `@MainActor` | `SpinWheelView.onSelect: @MainActor (QuestionCategory) -> Void` |

## File Structure

```
DateSpark/
├── DateSparkApp.swift       — @main entry point, @State AppState
├── AppState.swift           — @MainActor @Observable state + UserDefaults
├── Models.swift             — Question, QuestionCategory (Sendable), Color helpers
├── DataProvider.swift       — actor with nonisolated queries + async shuffle
├── RootView.swift           — Splash / Onboarding / Main routing
├── SplashView.swift         — Animated splash, async animateIn()
├── OnboardingView.swift     — 4-slide onboarding
├── MainTabView.swift        — Custom dark tab bar
├── HomeView.swift           — Home, async loadQuestions(for:)
├── QuestionCardView.swift   — Swipe deck, Task-based card throw animation
├── SpinWheelView.swift      — Spin wheel, async spin()
├── CategoriesView.swift     — Grid + detail list
└── FavoritesView.swift      — Saved questions, swipe-to-delete
```

## How to Run

1. Xcode 16+ (required for Swift 6)
2. **File → New → Project → iOS App**
   - Product Name: `DateSpark`
   - Interface: `SwiftUI`
   - Language: `Swift`
3. In **Build Settings**, set **Swift Language Version** to `Swift 6`
4. Delete `ContentView.swift`
5. Add all 13 `.swift` files to the project
6. Select **iPhone 16 Simulator** and press ▶

## Requirements

- Xcode 16+
- Swift 6
- iOS 17.0+

## Enable Swift 6 Strict Concurrency

In your target's Build Settings:
- `SWIFT_VERSION` = `6.0`
- `SWIFT_STRICT_CONCURRENCY` = `complete`

All code is written to pass under **complete** strict concurrency checking with zero warnings.

## Customising Questions

Open `DataProvider.swift` and append `Question` entries to `allQuestions`:

```swift
Question(
    text:     "Your question here?",
    category: .iceBreakers,
    depth:    .light
)
```

For stable Favorites persistence across app updates, use fixed UUIDs:

```swift
Question(
    id:       UUID(uuidString: "your-fixed-uuid-string")!,
    text:     "...",
    category: .dreams,
    depth:    .medium
)
```
