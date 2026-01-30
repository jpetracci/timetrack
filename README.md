# TimeTrack

One-tap time tracking with instant project switching. TimeTrack is a Flutter app for iOS, Android, and web that stores all data locally on device. Time is displayed in decimal hours (for example, 2.75h).

## Features (Phase 1)

- Create projects with name and tags
- One-tap start/stop timer per project
- Switching projects auto-stops the current timer
- Active project shown at the top of the screen
- Decimal hour display
- Local-only storage (SharedPreferences)

## Tech Stack

- Flutter / Dart
- Riverpod state management
- SharedPreferences for local persistence

## Requirements

- Flutter SDK installed (`flutter doctor` should pass)
- iOS Simulator or Android Emulator for mobile, or Chrome for web

## Running the App

Install dependencies:

```bash
flutter pub get
```

Run on web:

```bash
flutter run -d chrome
```

Run on iOS (Mac):

```bash
open -a Simulator
flutter run -d ios
```

Run on Android:

```bash
flutter run -d android
```

## Development Notes

- Data is stored locally on device in SharedPreferences.
- No network calls, accounts, or cloud sync.

## Tests / Analysis

```bash
flutter analyze
```
