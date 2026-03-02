import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/task.dart';

/// TaskProvider handles the business logic, state management, 
/// persistence, and notification scheduling for the application.
class TaskProvider with ChangeNotifier {
  List<LifeItem> _items = []; // Internal list of tasks and events
  ThemeMode _themeMode = ThemeMode.system; // Current UI theme mode
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  // Getters to filter items based on completion status
  List<LifeItem> get activeItems => _items.where((item) => !item.isCompleted).toList();
  List<LifeItem> get completedItems => _items.where((item) => item.isCompleted).toList();
  ThemeMode get themeMode => _themeMode;

  TaskProvider() {
    _initNotifications();
    _loadItems();
    _loadTheme();
  }

  /// Initializes the local notification plugin and timezones.
  Future<void> _initNotifications() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    
    await _notificationsPlugin.initialize(settings: initializationSettings);
  }

  /// Schedules an alert for an event exactly 15 minutes before its start time.
  Future<void> _scheduleNotification(LifeItem item) async {
    if (item.type == ItemType.event && item.dateTime != null) {
      final scheduleTime = item.dateTime!.subtract(const Duration(minutes: 15));
      
      // Only schedule if the notification time is in the future
      if (scheduleTime.isAfter(DateTime.now())) {
        await _notificationsPlugin.zonedSchedule(
          id: item.id.hashCode,
          title: 'Upcoming Event: ${item.title}',
          body: 'Starting in 15 minutes',
          scheduledDate: tz.TZDateTime.from(scheduleTime, tz.local),
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'life_manager_channel',
              'Life Manager Notifications',
              channelDescription: 'Life Manager Notifications Channel',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          // uiLocalNotificationDateInterpretation was removed in version 17+
        );
      }
    }
  }

  /// Updates and persists the application theme.
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveTheme();
    notifyListeners();
  }

  /// Adds a new LifeItem (Task or Event) to the list.
  void addItem({
    required String title,
    required String description,
    required ItemType type,
    DateTime? dateTime,
  }) {
    final newItem = LifeItem(
      id: DateTime.now().toString(),
      title: title,
      description: description,
      type: type,
      dateTime: dateTime,
    );
    _items.add(newItem);
    if (type == ItemType.event) _scheduleNotification(newItem);
    _saveItems();
    notifyListeners();
  }

  /// Updates an existing item and reschedules notifications if it's an event.
  void updateItem(String id, String newTitle, String newDescription, DateTime? newDateTime) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      _items[index].title = newTitle;
      _items[index].description = newDescription;
      _items[index].dateTime = newDateTime;
      if (_items[index].type == ItemType.event) _scheduleNotification(_items[index]);
      _saveItems();
      notifyListeners();
    }
  }

  /// Toggles the completion status of a task or event.
  void toggleItemStatus(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      _items[index].isCompleted = !_items[index].isCompleted;
      _saveItems();
      notifyListeners();
    }
  }

  /// Deletes an item and cancels any pending notifications associated with it.
  void deleteItem(String id) {
    _items.removeWhere((item) => item.id == id);
    _notificationsPlugin.cancel(id: id.hashCode);
    _saveItems();
    notifyListeners();
  }

  /// Clears all data and cancels all notifications.
  void resetAll() {
    _items.clear();
    _notificationsPlugin.cancelAll();
    _saveItems();
    notifyListeners();
  }

  // --- Persistence Logic ---

  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(_items.map((item) => item.toMap()).toList());
    await prefs.setString('life_items', encodedData);
  }

  Future<void> _loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? itemsData = prefs.getString('life_items');
    if (itemsData != null) {
      final List<dynamic> decodedData = json.decode(itemsData);
      _items = decodedData.map((item) => LifeItem.fromMap(item)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', _themeMode.name);
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final String? themeName = prefs.getString('themeMode');
    if (themeName != null) {
      _themeMode = ThemeMode.values.byName(themeName);
      notifyListeners();
    }
  }
}
