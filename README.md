# Sam — Smart Reminders & Productivity

> **RevenueCat Hackathon Submission** · Built with Flutter & RevenueCat

Sam is a beautifully crafted productivity app that combines task management, habit tracking, and smart scheduling into one cohesive experience. Named after your friendly personal assistant, Sam helps you stay organized without the cognitive overhead.

## ✨ Features

### Free Tier
- **Up to 10 tasks** with full CRUD
- **Basic reminders** via due dates
- **Priority levels** (High / Medium / Low)
- **Categories** (Work, Personal, Shopping, Health, Other)
- **Smart Sort** — urgency-based sorting (deadline proximity + priority)
- **Daily Plan view** with progress tracking
- **Subtasks** for breaking down work
- **Search & filters** (by category, priority, completion)
- **Dark / Light theme**
- **Task completion celebrations** 🎉

### Premium (via RevenueCat)
- **Unlimited tasks** — no caps
- **Habit tracking** with streaks and daily routines
- **Smart scheduling** — AI-powered urgency scoring
- **Advanced statistics** — weekly reviews & insights
- **Themes & customization**
- **Unlimited subtasks & categories**
- **Home screen widgets** *(planned)*

## 🏗 Architecture

```
lib/
├── core/
│   ├── constants/     # App constants, RevenueCat keys
│   ├── services/      # RevenueCat service (Riverpod StateNotifier)
│   ├── theme/         # Colors, text styles
│   ├── utils/         # Helpers
│   └── widgets/       # PremiumGate, animated widgets
├── features/
│   ├── home/          # Task list, daily plan, smart sort
│   ├── add_task/      # Task creation
│   ├── task_detail/   # Task editing, subtasks
│   ├── habits/        # Habit tracking (premium)
│   ├── paywall/       # RevenueCat paywall screen
│   ├── onboarding/    # First-launch onboarding
│   └── settings/      # Theme toggle, subscription management
├── models/            # Task, Habit models
├── providers/         # Riverpod providers (task, habit, theme)
└── main.dart          # App entry, navigation
```

## 💰 RevenueCat Integration

- **Package:** `purchases_flutter: ^8.6.0`
- **Service:** `SubscriptionNotifier` (Riverpod `StateNotifier`)
  - `isPremiumProvider` — reactive premium check
  - `subscriptionProvider` — full state (loading, packages, errors)
  - Auto-initializes on app start
  - Listens for real-time customer info updates
- **Paywall:** Full-featured screen with feature comparison, package buttons, restore
- **Premium Gate:** `PremiumGate` widget wraps any content with a lock overlay + paywall CTA
- **Entitlement:** `premium` (configurable in `AppConstants`)
- **Free limits:** 10 tasks, 3 habits (enforced client-side)

## 🛠 Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x |
| Language | Dart |
| State Management | Riverpod |
| Local Storage | Hive |
| Subscriptions | RevenueCat (`purchases_flutter`) |
| UI | Material Design 3, Google Fonts |
| Animations | Custom confetti, slide/fade transitions |

## 🚀 Getting Started

```bash
cd ToDo_app
flutter pub get
flutter run
```

### RevenueCat Setup
1. Create a project at [app.revenuecat.com](https://app.revenuecat.com)
2. Replace API keys in `lib/core/constants/app_constants.dart`:
   ```dart
   static const String revenueCatApiKeyIOS = 'appl_YOUR_KEY';
   static const String revenueCatApiKeyAndroid = 'goog_YOUR_KEY';
   ```
3. Create a `premium` entitlement with your subscription products
4. Build & run on a real device to test purchases

## 📱 Platform Support

| Platform | Min Version | Status |
|----------|-------------|--------|
| iOS | 15.0+ | ✅ |
| Android | API 24+ | ✅ |

## 📄 License

Built for the RevenueCat Hackathon 2025.
