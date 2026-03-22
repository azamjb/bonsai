# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

This is an **Xcode-based iOS project** — there is no package manager CLI. All builds happen via Xcode or `xcodebuild`:

```bash
# Build from command line
xcodebuild -project bonsai.xcodeproj -scheme bonsai -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run tests
xcodebuild -project bonsai.xcodeproj -scheme bonsai -destination 'platform=iOS Simulator,name=iPhone 16' test
```

- **Deployment target**: iOS 18.0
- **Swift**: 5.0
- **Bundle ID**: `com.bonsai.inc`
- **App Group**: `group.com.bonsai.inc` (shared between app and extensions)

## Architecture

Bonsai is an iOS **screen time management** app using Apple's Screen Time API. It uses SwiftUI + MVVM with feature modules.

### App Targets

| Target | Purpose |
|--------|---------|
| `bonsai` | Main app |
| `DeviceActivityMonitor` | Extension — monitors device activity intervals |
| `DeviceActivityReport` | Extension — generates activity reports |
| `ShieldActionExtension` | Extension — handles actions when app limits are hit |
| `ShieldConfiguration` | Extension — configures shield appearance |

### Key Frameworks
- **FamilyControls** + **ManagedSettings** + **DeviceActivity** — Apple Screen Time API stack
- **SwiftUI** — all UI
- **ConfidentialKit** — encrypted API key storage (`confidential.yml`)
- **BackgroundTasks** — background processing

### Directory Structure

```
bonsai/
├── Api/               # REST API layer (BaseApi, AccountApi, SMSApi)
├── Services/          # ScreenTimeService, ProfileService
├── LocalDatabase/     # Local persistence + migrations + service layer
├── Modules/           # Feature modules (BoundaryEditor, PaymentModule, etc.)
├── ReusableComponents/# Shared SwiftUI components
├── Static/            # Constants, extensions, utils
└── Policies/          # Screen time policy logic

SharedDatabase/        # Shared framework accessed by app + extensions via app group
```

### Data Flow

- **`ScreenTimeService`** is the central service for all Screen Time API interactions — restricting apps, setting shields, managing monitoring schedules.
- **`LocalDatabase`** (in `SharedDatabase/`) is shared across the main app and all extensions via the `group.com.bonsai.inc` app group. Use `SharedDatabase` types from extensions, `bonsai/LocalDatabase/` types from main app.
- The main app uses `BoundaryService`, `TokenService`, `SentExtensionCodeService`, and `DailyBoundaryExtensionService` as local database service layers.

### Navigation

`ContentView.swift` drives a 4-tab layout: **Bounds** → **Extend** → **Insights** → **Profile**.

### API

Backend is at `https://bonsai-tp5h.onrender.com/api`. API calls use an `x-api-key` header. The key is stored encrypted in `confidential.yml` and accessed via `ObfuscatedLiterals.apiKey`.

### In-App Purchases

Configured via `StoreKitConfig.storekit`. Products are consumable "Override Tokens" (IDs: `com.bonsai.inc.OverrideToken.*`) that let users temporarily bypass a boundary.
