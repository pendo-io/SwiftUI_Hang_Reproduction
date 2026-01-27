# Rumble Hang - SwiftUI Accessibility Reproduction Project

## Purpose

This project is designed to test for **potential hang/crash issues** in SwiftUI applications when using:
- **Accessibility Inspector** (iOS Simulator)
- **VoiceOver** (Physical iOS Device)

The project replicates a specific SwiftUI view hierarchy pattern involving nested `LazyVStack` components with dynamic content that may exhibit issues under certain conditions.

---

## The Pattern

### View Structure
This project uses a nested `LazyVStack` pattern that has been reported to potentially cause issues:

```swift
ScrollView {
    LazyVStack {                    // Level 1: Outer lazy container
        ArticleHeader(...)
        ArticleContent(...)
        
        ReadMoreArticles {
            LazyVStack {            // Level 2: Inner lazy container (NESTED!)
                ForEach(articles) { article in
                    JuniorTeaser(...)  // Dynamically created/destroyed views
                }
            }
        }
    }
}
```

This pattern is found in `ArticleViews.swift` → `ArticleDetailView` → `ReadMoreArticles`.

### Why This Pattern Matters

1. **Dynamic View Lifecycle**: `LazyVStack` creates views on-demand and destroys them when off-screen
2. **Accessibility Scanning**: VoiceOver and Accessibility Inspector perform deep view hierarchy traversals
3. **Timing Sensitivity**: The combination of dynamic view lifecycle + accessibility scanning may expose edge cases

---

## Project Structure

### Key Files

- **Models.swift** - Article data models and stores
- **ArticleViews.swift** - Main article view with **nested LazyVStack** (the reproduction case)
- **MainTabView.swift** - Tab bar navigation structure
- **ContentView.swift** - Root view

### Dependencies

- **iOS**: 14.0+
- **SDWebImageSwiftUI**: 2.2.7 (for image loading)

---

## How to Test

### Testing with Accessibility Inspector (Simulator)

1. **Build and run** the project in the iOS Simulator
2. **Enable Accessibility Inspector**:
   - Xcode → Open Developer Tool → Accessibility Inspector
   - Select your running simulator
   - Turn on Inspection mode
3. **Navigate to an article**:
   - Tap the first tab ("Startseite")
   - Tap any article from the list
4. **Interact with dynamic content**:
   - Scroll down to the "Recommended Articles" section
   - Tap the "Mehr" (More) button to load additional articles
   - Continue scrolling through the list
5. **Observe**: Monitor for any responsiveness issues or hangs

### Testing with VoiceOver (Physical Device)

1. **Build and run** the project on a physical iOS device
2. **Enable VoiceOver**:
   - Settings → Accessibility → VoiceOver → On
   - Or use the Accessibility Shortcut (triple-click side button)
3. **Navigate to an article**:
   - Swipe to navigate to the first tab
   - Select an article
4. **Interact with dynamic content**:
   - Swipe down to the "Recommended Articles" section
   - Activate the "Mehr" button to load more articles
   - Swipe through the article cards
5. **Observe**: Monitor for any crashes or hangs

---

## Expected Behavior

The app should:
- Remain responsive when Accessibility Inspector or VoiceOver is enabled
- Handle scrolling and dynamic content loading smoothly
- Allow accessibility features to traverse the view hierarchy without conflicts

---

## Alternative Implementation

If issues are encountered, the nested `LazyVStack` can be replaced with `VStack`:

```swift
// Current Implementation
LazyVStack {
    ReadMoreArticles {
        LazyVStack {  // ← Nested lazy container
            ForEach(articles) { ... }
        }
    }
}

// Alternative Implementation
LazyVStack {
    ReadMoreArticles {
        VStack {      // ← Changed to eager container
            ForEach(articles) { ... }
        }
    }
}
```

This eliminates the dynamic view lifecycle but sacrifices some performance benefits of lazy loading.

---

## Build & Run

1. Open `Rumble_Hang.xcodeproj` in Xcode
2. Select a simulator or physical device
3. Build and run the project
4. Follow the testing steps above

---

## Customer Context

This reproduction project is based on real customer code from the **Rumble iOS App** (News reading application), where a similar view hierarchy pattern was used.

---

## Notes

- The project uses SDWebImageSwiftUI for image loading to match the original customer implementation
- The tab bar structure mimics the original app's navigation pattern
- Article data is mocked for testing purposes
