# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MoneyFeedback is an iOS application for tracking tax returns with widget support. Built with SwiftUI and SwiftData for data persistence.

### Target Structure

- **MoneyFeedback**: Main iOS app target
- **MoneyFeedbackInternal**: Shared framework containing business logic, data models, views, and widget implementations
- **MoneyFeedbackWidget**: Widget extension target
- **MoneyFeedbackTests**: Unit tests using Swift Testing framework

## Development Commands

### Build & Test

```bash
# Build the app
xcodebuild -project MoneyFeedback.xcodeproj -scheme MoneyFeedback -destination "generic/platform=iOS Simulator" build

# Run tests
xcodebuild -project MoneyFeedback.xcodeproj -scheme MoneyFeedback -destination "name=iPhone 17" test

# Run specific test
xcodebuild -project MoneyFeedback.xcodeproj -scheme MoneyFeedback -destination "name=iPhone 17" -only-testing:MoneyFeedbackTests/TaxReturnTests test
```

### Code Formatting

```bash
xcrun swift-format format --in-place **/*.swift
```

Code formatting is configured in `.swift-format` with 4-space indentation and 100-character line length.

## Architecture

### Data Layer

SwiftData is used for persistence with the `TaxReturn` model as the primary entity:
- Located in `MoneyFeedbackInternal/Data/TaxReturn.swift`
- SwiftData model container configured in `MoneyFeedbackScene.swift:18-20`
- Models stored with `@Model` macro

### App Structure

- **Entry Point**: `MoneyFeedbackApp.swift` uses `MoneyFeedbackScene` for the main window
- **Scene Setup**: `MoneyFeedbackScene.swift` configures SwiftData model container for the app
- **Main View**: `ContentView.swift` handles tax return input with year-based filtering using SwiftData predicates

### Widget Architecture

Widget functionality is shared through `MoneyFeedbackInternal`:
- Widget entry point: `MoneyFeedbackWidget/MoneyFeedbackWidgetBundle.swift`
- Widget configuration: `MoneyFeedbackInternal/Widget/MoneyFeedbackWidget.swift`
- Timeline provider: `MoneyFeedbackInternal/Widget/MoneyFeedbackTimelineProvider.swift`
- Widget view: `MoneyFeedbackInternal/View/WidgetEntryView.swift`

### Configuration

Build configurations use xcconfig files in `Configurations/`:
- `Base.xcconfig`: Shared settings for all configurations
- `Debug.xcconfig`: Debug-specific settings
- `Release.xcconfig`: Release-specific settings

### Logging

Custom logging using OSLog framework defined in `MoneyFeedbackInternal/Extensions/OSLog.swift`.

## Testing

Tests use Swift Testing framework (not XCTest). Test files are in `MoneyFeedbackTests/` and use the `@testable import MoneyFeedbackInternal` pattern.

Example test structure:
```swift
@Test @MainActor func testName() throws {
    // Use in-memory SwiftData container for testing
    let container = try ModelContainer(
        for: TaxReturn.self,
        configurations: .init(isStoredInMemoryOnly: true)
    )
}
```

## CI/CD

GitHub Actions workflow (`.github/workflows/*.yml`) runs on macOS-26 with:
1. Swift format linting
2. Build validation
3. Test execution on iPhone 17 simulator
