# TaskFlow - Development Plan

## Current Status: 35-40% Complete

## Completed ✅
- [x] Project setup
- [x] Hive database
- [x] Riverpod state management
- [x] Slidable list items
- [x] Basic navigation

## Phase 1: Core Task Features

### 1.1 Task CRUD
- [ ] Add task screen
- [ ] Edit task screen
- [ ] Delete confirmation
- [ ] Task details view
- [ ] Complete/uncomplete toggle

### 1.2 Task Properties
- [ ] Title & description
- [ ] Due date picker
- [ ] Priority selection
- [ ] Category assignment
- [ ] Notes/subtasks

### 1.3 Task List
- [ ] All tasks view
- [ ] Today's tasks
- [ ] Upcoming tasks
- [ ] Completed tasks
- [ ] Search & filter

## Phase 2: Organization

### 2.1 Categories
- [ ] Default categories
- [ ] Custom categories
- [ ] Category colors
- [ ] Category icons
- [ ] Category management

### 2.2 Sorting & Filtering
- [ ] Sort by date
- [ ] Sort by priority
- [ ] Filter by category
- [ ] Filter by status

## Phase 3: Reminders

### 3.1 Notifications
- [ ] Due date reminders
- [ ] Custom reminder times
- [ ] Recurring reminders
- [ ] Snooze functionality

## Phase 4: Polish

### 4.1 UI/UX
- [ ] Onboarding
- [ ] Empty states
- [ ] Animations
- [ ] Celebration on complete

### 4.2 Settings
- [ ] Theme toggle
- [ ] Default reminder time
- [ ] Week start day
- [ ] Data backup

## Data Model

```dart
class Task {
  String id;
  String title;
  String? description;
  DateTime? dueDate;
  String priority; // high, medium, low
  String? category;
  bool isCompleted;
  DateTime createdAt;
  List<String>? subtasks;
}
```

## Dependencies to Add
```yaml
flutter_local_notifications: ^latest
```

## Estimated Completion
**Total: 2-3 weeks**
