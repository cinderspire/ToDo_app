# TaskFlow — RevenueCat Shipyard 2026 Submission

## Project Title

**TaskFlow — Boxy, Bold Task Management That Gets Things Done**

## Tagline

A sharp, modern task manager with smart categories, built-in habits, and a design language that means business.

---

## Inspiration

Task management apps fall into two camps: over-engineered project management tools (Notion, Asana) or glorified checklists (Apple Reminders). There's a gap for people who want something **powerful but not overwhelming** — something designed by "Sam," our internal brief for a user who wants clean lines, bold colors, and zero fluff.

We also noticed something missing: **most to-do apps ignore habits entirely.** But your daily habits *are* tasks — recurring ones that deserve first-class treatment. TaskFlow bridges the gap between task management and habit tracking in one unified experience.

The design philosophy is unapologetically modern: electric blue (#0066FF), vibrant cyan (#00D4FF), boxy layouts with sharp corners, and bold typography. It looks like a tool built for getting things done, not decorating your home screen.

---

## What It Does

TaskFlow is a premium task management app that combines **smart task organization, built-in habit tracking, and a bold modern UI.**

### ✅ Smart Task Management

- **Rich task model** with titles, descriptions, due dates, priorities, categories, and subtasks
- **Category system** with visual chips for quick filtering (Work, Personal, Health, etc.)
- **Slidable task cards** — swipe to complete, edit, or delete with fluid gesture handling
- **Task detail screen** with full editing, notes, and completion history

### 🔄 Built-in Habit Tracking

- **Dedicated habits screen** — recurring tasks get their own view with streak tracking
- **Habit model** with frequency settings, reminders, and completion history
- **Unified provider system** — habits and tasks coexist in the same state management layer

### 🎨 Boxy Modern Design

- Electric blue (#0066FF) + cyan (#00D4FF) gradient palette
- Sharp, geometric card layouts — no rounded-everything softness
- Bold Google Fonts typography with custom text styles
- Animated widgets for satisfying task completion feedback
- Dark mode support via theme provider

### 📱 Smart Features

- **Onboarding flow** guiding new users through app capabilities
- **Hive database** for fast, lightweight local storage
- **UUID-based task IDs** for reliable data management
- **Slidable interactions** for gesture-driven task management

### 💰 Monetization (RevenueCat-Powered)

| Tier | Price | What You Get |
|------|-------|-------------|
| **Free** | $0 | Core task management, basic categories, 10 tasks |
| **Pro** | $4.99/mo | Unlimited tasks, habit tracking, advanced categories, themes |

---

## How We Built It

### Architecture

- **Flutter + Dart** — Single codebase for iOS and Android
- **Riverpod** — State management with dedicated providers for tasks, habits, and theming
- **Hive + SharedPreferences** — Dual storage: Hive for structured task/habit data, SharedPreferences for settings
- **RevenueCat (purchases_flutter ^8.6.0)** — Subscription management and premium gating
- **flutter_slidable** — Gesture-based task interactions

### RevenueCat Integration

RevenueCat is central to TaskFlow's monetization:

1. **RevenueCat Service** — Centralized service managing SDK initialization, purchases, restores, and entitlement queries.

2. **Premium Gate Widget** — Reusable widget that checks RevenueCat entitlements and gates premium features like habit tracking and unlimited tasks.

3. **Paywall Screen** — Dedicated upgrade flow presenting Pro benefits with purchase handling through RevenueCat.

4. **Entitlement Checks** — Task limits, habit access, and theme customization all validate premium status via RevenueCat in real-time.

### Key Technical Decisions

- **Hive over SQLite** — Chose Hive for its speed and simplicity with Dart-native objects. No SQL boilerplate.
- **Dual provider architecture** — Separate task and habit providers keep concerns clean while sharing the same premium gate logic.
- **Local-first** — All data on-device. No accounts required.

---

## Challenges We Ran Into

1. **Merging tasks and habits.** Habits are conceptually different from tasks (recurring vs. one-off), but users want them in one app. Designing a unified UX without confusion took careful information architecture.

2. **Boxy design that doesn't feel harsh.** Sharp corners and bold colors can feel aggressive. We balanced it with generous spacing, subtle gradients, and smooth animations.

3. **Hive code generation.** Hive's adapter system with build_runner adds build complexity. Getting type adapters right for nested task models required iteration.

4. **Gesture conflicts.** flutter_slidable gestures occasionally conflicted with scroll gestures. Careful threshold tuning resolved this.

---

## Accomplishments We're Proud Of

- ✅ **Unified task + habit experience** — one app for everything you need to do and keep doing
- 🎨 **Bold design language** that stands out in a sea of soft, pastel productivity apps
- ⚡ **Hive-powered performance** — instant task operations with zero perceptible lag
- 🔄 **Slidable interactions** that make task management feel physical and satisfying
- 💰 **Clean RevenueCat integration** with reusable premium gating pattern
- 🏗️ **Well-structured codebase** — feature-based architecture with clear separation of concerns

---

## What's Next

- 🤖 **Smart Reminders** — AI-powered reminder timing based on task patterns and user behavior
- 📅 **Calendar Integration** — Sync with system calendars for unified scheduling
- 🏷️ **Tags & Filters** — Advanced organization with custom tags and saved filters
- 👥 **Shared Lists** — Collaborative task lists for teams and families
- 📊 **Productivity Analytics** — Weekly reports on task completion trends
- 📊 **RevenueCat Experiments** — A/B test pricing and trial configurations

---

## Built With

- **Flutter** — Cross-platform UI framework
- **Dart** — Application language
- **RevenueCat (purchases_flutter ^8.6.0)** — Subscription management & monetization
- **Riverpod** — Reactive state management
- **Hive** — Fast local database
- **flutter_slidable** — Gesture-based interactions
- **Google Fonts** — Typography
- **UUID** — Unique task identification
- **SharedPreferences** — Settings persistence
- **Material Design 3** — Adaptive UI system

---

## Try It

- **Bundle ID:** `com.cinderspire.todo`
- **Privacy Policy:** https://playtools.top/privacy-policy.html
- **Developer:** MUSTAFA BILGIC

---

*TaskFlow: Less planning, more doing.* ⚡
