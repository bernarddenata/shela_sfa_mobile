# SHELA Sales Mobile

Flutter mobile application starter for SHELA sales workflows.

## Requirements

- Flutter SDK matching the `pubspec.yaml` SDK constraint
- Android Studio or Xcode for mobile builds
- A configured Android emulator, iOS simulator, or physical device

## Getting Started

Install dependencies:

```sh
flutter pub get
```

Run the app:

```sh
flutter run
```

Analyze the project:

```sh
flutter analyze
```

Run tests:

```sh
flutter test
```

## Project Structure

- `lib/main.dart` boots the Flutter app.
- `lib/app.dart` configures the root `MaterialApp.router`.
- `lib/config/` stores app-level constants and environment placeholders.
- `lib/core/` stores shared app infrastructure such as routing and theme.
- `lib/features/` stores feature-specific screens and logic.
- `lib/shared/` stores reusable widgets and utilities.

## Notes

This starter intentionally does not include backend integration, authentication logic, Firebase, local database setup, or additional state management wiring yet.
