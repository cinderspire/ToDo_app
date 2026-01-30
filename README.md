# TaskFlow - Smart To-Do App

## Overview
TaskFlow is a modern, intuitive task management app that helps users organize their daily tasks with categories, due dates, and smart reminders.

## Features

### Core Features
- **Task Management**: Create, edit, delete tasks
- **Categories**: Organize tasks by category
- **Due Dates**: Set deadlines with reminders
- **Priority Levels**: High, medium, low priority
- **Swipe Actions**: Quick complete/delete

### Technical Features
- Offline-first with Hive
- Smooth animations
- Material Design 3
- Dark/Light theme

## Tech Stack

```yaml
Framework: Flutter 3.x
Language: Dart
State Management: Riverpod
Local Database: Hive
UI: flutter_slidable
Date: intl
Unique IDs: uuid
Fonts: Google Fonts
```

## Project Structure

```
ToDo_app/
├── lib/
│   ├── core/
│   │   └── theme/
│   ├── models/
│   │   └── task.dart
│   ├── providers/
│   │   └── task_provider.dart
│   ├── features/
│   │   ├── home/
│   │   ├── add_task/
│   │   └── settings/
│   ├── shared/
│   │   └── widgets/
│   └── main.dart
├── assets/
├── android/
├── ios/
└── pubspec.yaml
```

## Getting Started

```bash
cd ToDo_app
flutter pub get
flutter pub run build_runner build
flutter run
```

## App Store Information

### App Name
TaskFlow - To-Do List

### Short Description
Simple, beautiful task management for your daily productivity.

### Category
- Primary: Productivity

### Keywords
to-do list, task manager, productivity, reminders, checklist, daily planner, task organizer

## Platform Support

| Platform | Min Version | Status |
|----------|-------------|--------|
| Android | 5.0 (API 21) | ✅ Ready |
| iOS | 12.0 | ✅ Ready |

## Version
1.0.0
