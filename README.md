# TimeTrack

One-tap time tracking with instant project switching. TimeTrack is a Flutter app for iOS, Android, and web that stores all data locally on device. Time is displayed in decimal hours (for example, 2.75h).

Developed while learning [Claude Code](https://code.claude.com/docs/en/overview)/[Opencode](https://opencode.ai/) and [GSD](https://github.com/glittercowboy/get-shit-done)

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
