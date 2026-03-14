# Life Manager

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Material 3](https://img.shields.io/badge/Material%203-%23757575.svg?style=for-the-badge&logo=materialdesign&logoColor=white)](https://m3.material.io)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-lightgrey?style=for-the-badge)](#)

A professional personal productivity and task management suite. Built with a focus on reactive architecture, adaptive design, and the Material 3 design system.

---

## Core Features

### Material You and Adaptive Theming
*   **Dynamic Color Support**: Automatically derives color schemes from system wallpapers on Android 12+.
*   **Optimized Dark Mode**: High-contrast, semantic color mapping for superior readability in low-light environments.
*   **Custom Seed Seeding**: Allows manual override of brand colors via SharedPreferences.

### Advanced Task Engine
*   **Hierarchical Sub-Tasks**: Granular control over complex objectives with real-time status syncing.
*   **Dynamic Prioritization**: Automated sorting and filtering for high-priority requirements.
*   **Project Management**: Visual progress indicators and deadline tracking for long-term goals.

### Unified Scheduling
*   **Chronological Timeline**: Interactive calendar grid coupled with a daily event timeline.
*   **Categorization**: Distinct segments for Work, Personal, and Urgent engagements.
*   **Quick Entry System**: A modal-driven brainstorming interface for instant data capture.

### Cross-Platform Architecture
*   **Stateful Shell Routing**: Persistent navigation state across tabs using GoRouter.
*   **Responsive Layouts**: Intelligent UI scaling for mobile, tablet, and desktop viewports.

---

## Technical Stack

| Category | Technology |
| :--- | :--- |
| **Framework** | Flutter |
| **State Management** | Riverpod (Functional & Reactive) |
| **Database** | Drift (SQLite ORM) with asynchronous DAOs |
| **Navigation** | GoRouter (Stateful Shell Implementation) |
| **Theming** | Material 3 with Dynamic Color support |
| **Local Storage** | SharedPreferences |
| **Build Target** | Android SDK 35 / NDK 27 |

---

## Getting Started

### Prerequisites
- Flutter SDK `^3.8.1`
- Android SDK 35 & NDK 27.0.12077973

### Installation

1. **Dependency Resolution**
   ```sh
   flutter pub get
   ```

2. **Code Generation**
   ```sh
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. **Execution**
   ```sh
   flutter run
   ```

---

## Project Anatomy

```text
lib/
 ├── data/
 │    ├── repositories/     # Repository layer isolating DAOs from UI
 │    │    ├── note_repository.dart
 │    │    ├── project_repository.dart
 │    │    ├── schedule_repository.dart
 │    │    ├── subtask_repository.dart
 │    │    └── task_repository.dart
 │    ├── database.dart     # Drift table definitions and DB configuration
 │    ├── database.g.dart   # Generated code (Mappers, Companions, Classes)
 │    └── seed_data.dart    # Initial database population logic
 ├── navigation/
 │    └── app_router.dart   # GoRouter configuration & StatefulShell logic
 ├── providers/
 │    ├── database_providers.dart # Singleton instances for DB and Repos
 │    ├── settings_provider.dart # Application state (Theme, Color)
 │    └── state_providers.dart   # Reactive UI streams (Stats, Tasks, Events)
 ├── theme/
 │    └── app_theme.dart    # Material 3 Light/Dark theme specifications
 ├── ui/
 │    ├── screens/          # Feature-specific page implementations
 │    │    ├── home_screen.dart
 │    │    ├── tasks_screen.dart
 │    │    ├── schedule_screen.dart
 │    │    ├── task_detail_screen.dart
 │    │    └── settings_screen.dart
 │    └── widgets/          # Atomic reusable UI components
 │         ├── category_chip.dart
 │         ├── main_shell.dart
 │         ├── project_card.dart
 │         ├── quick_add_sheet.dart
 │         ├── schedule_event_card.dart
 │         ├── stat_card.dart
 │         ├── sub_task_item.dart
 │         └── task_item.dart
 └── main.dart              # Application entry point & initialization
```

---

## Implementation Checklist
- [x] Staggered Section Animations
- [x] Stateful Tab Persistence (IndexedStack)
- [x] Reactive DB Streams (Riverpod)
- [x] Two-Pane Adaptive UI
- [x] Semantic Dark Mode Mapping
- [x] Dynamic Color Integration

---
*Developed with Flutter and the Material 3 Design System.*
