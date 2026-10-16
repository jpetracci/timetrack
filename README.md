# TimeTrack

One-tap time tracking with instant project switching. TimeTrack is a Flutter app for iOS, Android, and web that stores all data locally on device. Time is displayed in decimal hours (for example, 2.75h).

Developed while learning [Claude Code](https://code.claude.com/docs/en/overview)/[Opencode](https://opencode.ai/) and [GSD](https://github.com/glittercowboy/get-shit-done)

## Current Functionality

- Start/stop tracking and switch projects immediately; switching closes the previous entry.
- Restore an active timer from local storage and recalculate elapsed time after app pause/resume. Pausing the app stops UI ticks, not the tracked interval.
- Manage projects and edit completed-entry durations or delete entries.
- Export all projects and time entries from **Settings → Data export** as JSON or CSV through the platform share/download flow. JSON includes schema/export metadata; CSV produces separate projects and entries files with project IDs for joining.

This is a local-first tool, not a cloud timesheet service. Platform folders are present, but they do not establish tested support on every desktop/mobile/browser target.

## Running the App

Use a Flutter SDK that includes Dart compatible with `^3.10.8` (`pubspec.yaml`). Install Chrome for web development, Xcode/iOS tooling on macOS for iOS, or Android SDK/emulator tooling for Android. Choose an actual connected device ID using `flutter devices`.

Install dependencies from the repository root:

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
flutter devices
flutter run -d <ios-device-id>
```

Run on Android:

```bash
flutter devices
flutter run -d <android-device-id>
```

## Development Notes

- Data is stored locally on device in SharedPreferences.
- No accounts or cloud sync; primary records live in local SharedPreferences.
- Clearing app/browser storage or uninstalling can lose records. Export important data yourself; sharing an export does not create automatic backups or prove that a restore/import workflow exists.
- Share/download behavior depends on the OS/browser. Web branches exist in the exporter, but it also imports `dart:io`; web compilation and export need verification rather than assuming parity with mobile.

## Tests / Analysis

```bash
flutter analyze
flutter test
```

Existing tests include report aggregation and widget tests. These commands and the run/export flows were **not executed** during this documentation review; no device acceptance or build result is claimed.

## License

See [LICENSE](LICENSE).
