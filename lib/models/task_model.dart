import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskPriority { low, medium, high, urgent }

enum TaskStatus { pending, inProgress, completed, cancelled }

class TaskModel {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? dueDate;
  final DateTime? reminderTime;
  final TaskPriority priority;
  final TaskStatus status;
  final String userId;
  final List<String> tags;
  final bool hasReminder;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.dueDate,
    this.reminderTime,
    required this.priority,
    required this.status,
    required this.userId,
    this.tags = const [],
    this.hasReminder = false,
  });

  // Create a copy with updated fields
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? dueDate,
    DateTime? reminderTime,
    TaskPriority? priority,
    TaskStatus? status,
    String? userId,
    List<String>? tags,
    bool? hasReminder,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      reminderTime: reminderTime ?? this.reminderTime,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      tags: tags ?? this.tags,
      hasReminder: hasReminder ?? this.hasReminder,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'reminderTime': reminderTime != null ? Timestamp.fromDate(reminderTime!) : null,
      'priority': priority.name,
      'status': status.name,
      'userId': userId,
      'tags': tags,
      'hasReminder': hasReminder,
    };
  }

  // Create from Firestore document
  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      dueDate: data['dueDate'] != null ? (data['dueDate'] as Timestamp).toDate() : null,
      reminderTime: data['reminderTime'] != null ? (data['reminderTime'] as Timestamp).toDate() : null,
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == data['priority'],
        orElse: () => TaskPriority.medium,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => TaskStatus.pending,
      ),
      userId: data['userId'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      hasReminder: data['hasReminder'] ?? false,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'reminderTime': reminderTime?.toIso8601String(),
      'priority': priority.name,
      'status': status.name,
      'userId': userId,
      'tags': tags,
      'hasReminder': hasReminder,
    };
  }

  // Create from JSON
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      reminderTime: json['reminderTime'] != null ? DateTime.parse(json['reminderTime']) : null,
      priority: TaskPriority.values.firstWhere((e) => e.name == json['priority']),
      status: TaskStatus.values.firstWhere((e) => e.name == json['status']),
      userId: json['userId'],
      tags: List<String>.from(json['tags'] ?? []),
      hasReminder: json['hasReminder'] ?? false,
    );
  }
}
