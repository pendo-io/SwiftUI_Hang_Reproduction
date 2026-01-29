# Rumble Hang - SwiftUI Accessibility Reproduction Project

## Purpose

This project reproduces a **hang issue** in SwiftUI applications when using:
- **Accessibility Inspector** (iOS Simulator)
- **VoiceOver** (Physical iOS Device)

The hang occurs with a specific SwiftUI view hierarchy pattern involving nested `LazyVStack` components with dynamic content loading.

---

## Quick Reproduction Steps


### Steps to Reproduce the Hang

1. **Build and run** the project in the iOS Simulator
2. **Enable Accessibility Inspector**:
   - Xcode → Open Developer Tool → Accessibility Inspector
   - Select your running simulator
   - Click the **Inspection** (eye) icon to enable it
3. **Navigate to the test view**:
   - In the app, tap **"Show Nested LazyVStack Page"**
4. **Trigger the hang**:
   - Start scrolling down through the list
   - The app will become **unresponsive** and hang
   - The hang typically occurs when scrolling triggers new sections to load

### Where the Hang Occurs

The hang happens in **`NestedLazyVStackView.swift`** during scrolling:

```swift
ScrollView {
    LazyVStack {                              // Outer LazyVStack
        ForEach(outerSections) { section in
            VStack {
                Text("Section #\(section)")
                LazyVStack {                  // Inner LazyVStack (NESTED!)
                    ForEach(innerRows) { row in
                        Text("Row #\(row)")
                            .onAppear {       // ← HANG OCCURS HERE
                                loadMoreInner() // When this triggers with Accessibility active
                            }
                    }
                }
            }
            .onAppear {                       // ← OR HERE
                loadMoreOuter()               // When this triggers
            }
        }
    }
}
```

---

## The Pattern

### View Structure
The critical pattern that causes the hang:

```swift
ScrollView {
    LazyVStack {                    // Level 1: Outer lazy container
        ForEach(...) { section in
            VStack {
                LazyVStack {        // Level 2: Inner lazy container (NESTED!)
                    ForEach(...) { row in
                        Text(...)
                            .onAppear { ... }  // Dynamic loading
                    }
                }
            }
            .onAppear { ... }  // Dynamic loading
        }
    }
}
```

This pattern is found in **`NestedLazyVStackView.swift`**.

---

## Project Structure

### Key Files

- **ContentView.swift** - Root view with simple navigation (tap "Show Nested LazyVStack Page")
- **NestedLazyVStackView.swift** - **THE REPRODUCTION CASE** - Contains nested LazyVStack with infinite scroll
- **AppDelegate.swift** - Application lifecycle methods
- **Models.swift** - Article data models (not used in reproduction)
- **ArticleViews.swift** - Alternative reproduction case (not used in primary test)
- **MainTabView.swift** - Tab bar structure (not used in primary test)

### Dependencies

- **SDWebImageSwiftUI**: 2.2.7

**Note:** This project does not include any third-party SDKs. The hang is a pure SwiftUI + Accessibility issue.

---

## Build & Run

1. Open `Rumble_Hang.xcodeproj` in Xcode
2. Select a simulator (iPhone 15 or later recommended, I have  reproduce on ios 26.2)
3. Build and run (⌘R)
4. Follow the "Quick Reproduction Steps" above

---

## Workarounds

If the hang occurs in your application, there are two known workarounds:

### Option 1: Replace Nested LazyVStack with VStack

```swift
// BEFORE (causes hang)
LazyVStack {
    ForEach(...) { section in
        LazyVStack {  // ← Inner nested lazy
            ForEach(...) { row in
                ...
            }
        }
    }
}

// AFTER (resolves hang)
LazyVStack {
    ForEach(...) { section in
        VStack {      // ← Changed to eager container
            ForEach(...) { row in
                ...
            }
        }
    }
}
```

This eliminates the nested lazy behavior and prevents the hang.

### Option 2: Wrap in TabView

**Interesting finding:** The hang does **not** occur when the view is embedded within a `TabView`:

```swift
TabView {
    NavigationStack {
        // Your view with nested LazyVStack
        NestedLazyVStackView()
    }
    .tabItem { ... }
}
```

The TabView appears to isolate or buffer the nested LazyVStack from the accessibility system in a way that prevents the hang. This workaround maintains the lazy loading behavior while avoiding the conflict.

---

## Customer Context

This reproduction project is based on real customer code from the **Rumble iOS App** (News reading application), where a similar view hierarchy pattern was used. The hang was reported when users enabled VoiceOver or when testing with Accessibility Inspector.

---

## Notes

- This is a pure **SwiftUI + Accessibility** issue, not related to any third-party SDK
- Only reported by a small number of customers in specific scenarios
- The exact root cause is still under investigation
- The workarounds (replacing nested `LazyVStack` with `VStack`, or using `TabView`) have been validated
