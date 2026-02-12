# ToDo_app

> A professional modern task management app built with Flutter.

## Project Info
- **Type:** Flutter App
- **Version:** 1.0.0+1
- **Organization:** com.cinderspire
- **Platforms:** iOS, Android

## Commands
```bash
flutter pub get          # Install deps
flutter run              # Debug run
flutter test             # Run tests
flutter build ios --no-codesign  # iOS build
flutter build appbundle  # Android AAB
```

## Key Dependencies
flutter,sdk,flutter_riverpod,google_fonts,flutter_slidable,uuid,hive,hive_flutter,intl,shared_preferences,

## Architecture
- State management: Check lib/ for Provider/Riverpod/Bloc patterns
- Entry point: lib/main.dart

## Guidelines
- Follow existing code patterns
- Run tests before committing
- Keep pubspec.yaml clean
- Target iOS 15+ and Android API 24+
