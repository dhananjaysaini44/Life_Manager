import 'dart:convert';

/// Defines the types of items available in the Life Manager app.
enum ItemType { task, event }

/// The core data model for the application. 
/// It represents both individual tasks and scheduled events.
class LifeItem {
  final String id; // Unique identifier (usually timestamp based)
  String title; // Title of the task/event
  String description; // Detailed description
  bool isCompleted; // Status flag for completion
  ItemType type; // Discriminator between 'task' and 'event'
  DateTime? dateTime; // Optional timestamp, required for notifications on 'events'

  LifeItem({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    this.type = ItemType.task,
    this.dateTime,
  });

  /// Converts the LifeItem object into a Map structure for JSON serialization.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'type': type.name,
      'dateTime': dateTime?.toIso8601String(),
    };
  }

  /// Creates a LifeItem object from a Map structure (used when loading from storage).
  factory LifeItem.fromMap(Map<String, dynamic> map) {
    return LifeItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      type: ItemType.values.byName(map['type'] ?? 'task'),
      dateTime: map['dateTime'] != null ? DateTime.parse(map['dateTime']) : null,
    );
  }

  /// Helper methods for quick JSON encoding/decoding.
  String toJson() => json.encode(toMap());
  factory LifeItem.fromJson(String source) => LifeItem.fromMap(json.decode(source));
}
