# ⚡ TaskFlow

### Flow State as a Service.

> A sharp, modern task manager with smart categories, built-in habits, and a design language that means business.

<p align="center">
  <img src="screenshots/screenshot1.png" width="200" />
  <img src="screenshots/screenshot2.png" width="200" />
  <img src="screenshots/screenshot3.png" width="200" />
</p>

---

## ✨ Features

| | Feature | Description |
|---|---|---|
| ✅ | **Smart Tasks** | Titles, descriptions, due dates, priorities, categories & subtasks |
| 🏷 | **Categories** | Visual chips for quick filtering — Work, Personal, Health & more |
| 👆 | **Slidable Cards** | Swipe to complete, edit, or delete with fluid gestures |
| 🔄 | **Built-in Habits** | Dedicated habits view with streak tracking & frequency settings |
| 🌙 | **Dark Mode** | Full theme support via theme provider |
| 🎓 | **Onboarding** | Guided intro to app capabilities |

## 💎 Premium (RevenueCat)

| Free | Pro · $4.99/mo |
|------|-----------------|
| Core task management, basic categories, 10 tasks | Unlimited tasks, habit tracking, advanced categories, themes |

- **`RevenueCatService`** — centralized SDK init, purchases, restores & entitlement queries
- **`PremiumGate` widget** — reusable premium gating across features
- **Dedicated paywall** with Pro benefits presentation
- Real-time entitlement checks for task limits, habits & themes

## 🎨 Design

**Boxy Modern** — Electric blue `#0066FF` + vibrant cyan `#00D4FF`. Sharp geometric layouts, bold typography, generous spacing. Stands out in a sea of soft pastel productivity apps.

## 🛠 Tech Stack

- **Flutter + Dart** — Cross-platform
- **Riverpod** — Task + habit + theme providers
- **Hive + SharedPreferences** — Fast local storage
- **RevenueCat** `purchases_flutter ^8.6.0`
- **flutter_slidable** — Gesture interactions
- **Google Fonts** · **uuid**

## 🏗 Build & Run

```bash
flutter pub get
flutter run
```

Bundle ID: `com.cinderspire.todo`

## 🔒 Privacy

All data on-device. No accounts required.

**Privacy Policy:** https://playtools.top/privacy-policy.html

## 👤 Developer

**MUSTAFA BILGIC** · [cinderspire](https://github.com/cinderspire)

---

*Less planning, more doing.* ⚡
