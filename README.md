# Life Manager

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://www.android.com/)

> **Manage your life Skillfully!!!**

Life Manager is a professional, cross-platform Flutter application designed to help you stay on top of your daily tasks and scheduled events. It combines powerful features like persistent storage, theme customization, and an automated alert system into a clean, modern interface.

---

## Key Features

- **Double Impact**: Manage both simple **Tasks** and time-bound **Events**.
- **Smart Alerts**: Get notified **15 minutes before** your events start.
- **Persistent Memory**: Your data stays safe with local storage.
- **Your Style**: Support for **Light**, **Dark**, and **System Default** themes.
- **Fluid UI**: Smooth animations and organized sections for Active and Completed items.

---

## Core Components

### 1. Data Model (`lib/models/task.dart`)
The `LifeItem` class is the heart of the app, using an `ItemType` enum to categorize your entries:
- **Task**: A simple to-do item.
- **Event**: A scheduled item with a specific date and time.

### 2. State Management (`lib/providers/task_provider.dart`)
Powered by the **Provider** pattern, this layer handles:
- **CRUD Operations**: Effortless adding, updating, and deleting.
- **Persistence**: Powered by `shared_preferences` for reliable local storage.
- **Notification Engine**: Schedules precise alerts using `flutter_local_notifications`.

### 3. User Interface (`lib/screens/`)
- **Loading Screen**: A professional entry with the app's tagline.
- **Dashboard**: Uses `CustomScrollView` and `Slivers` for a responsive, organized list.
- **Settings**: A central hub for theme switching and data management.

---

## How It Works

### 1. Initialization
The app kicks off by initializing `WidgetsFlutterBinding` and booting up the `TaskProvider`, which instantly restores your saved data and prepares the notification engine.

### 2. Adding Items
When you add an event, the app automatically calculates the alert time and schedules a local notification.

### 3. Smart Alerts
Using `timezone` data and `exactAllowWhileIdle` scheduling, Life Manager ensures you never miss a beat, even if your phone is in power-saving mode.

---

## System Requirements (Android)

- **Java 8 Support**: Java Desugaring is enabled for modern date/time functionality.
- **Permissions**:
  - `POST_NOTIFICATIONS`: For alerts on Android 13+.
  - `USE_EXACT_ALARM`: For precise event timing.

---

## Getting Started

1. **Clone the repo**
2. **Install dependencies**:
   ```bash
   flutter pub get
   ```
3. **Run the app**:
   ```bash
   flutter run
   ```

---

*Crafted for a more organized life.*
