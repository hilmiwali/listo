import 'package:cloud_firestore/cloud_firestore.dart';

enum EventType { meeting, appointment, reminder, personal, work }

class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final EventType type;
  final String userId;
  final bool isAllDay;
  final List<DateTime> reminderTimes;
  final String? calendarEventId; // For device calendar integration
  final String timezone;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    this.location = '',
    required this.type,
    required this.userId,
    this.isAllDay = false,
    this.reminderTimes = const [],
    this.calendarEventId,
    required this.timezone,
  });

  // Create a copy with updated fields
  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    EventType? type,
    String? userId,
    bool? isAllDay,
    List<DateTime>? reminderTimes,
    String? calendarEventId,
    String? timezone,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      type: type ?? this.type,
      userId: userId ?? this.userId,
      isAllDay: isAllDay ?? this.isAllDay,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      calendarEventId: calendarEventId ?? this.calendarEventId,
      timezone: timezone ?? this.timezone,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'location': location,
      'type': type.name,
      'userId': userId,
      'isAllDay': isAllDay,
      'reminderTimes': reminderTimes.map((t) => Timestamp.fromDate(t)).toList(),
      'calendarEventId': calendarEventId,
      'timezone': timezone,
    };
  }

  // Create from Firestore document
  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      location: data['location'] ?? '',
      type: EventType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => EventType.personal,
      ),
      userId: data['userId'] ?? '',
      isAllDay: data['isAllDay'] ?? false,
      reminderTimes: (data['reminderTimes'] as List<dynamic>?)
              ?.map((t) => (t as Timestamp).toDate())
              .toList() ??
          [],
      calendarEventId: data['calendarEventId'],
      timezone: data['timezone'] ?? 'UTC',
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'location': location,
      'type': type.name,
      'userId': userId,
      'isAllDay': isAllDay,
      'reminderTimes': reminderTimes.map((t) => t.toIso8601String()).toList(),
      'calendarEventId': calendarEventId,
      'timezone': timezone,
    };
  }

  // Create from JSON
  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      location: json['location'] ?? '',
      type: EventType.values.firstWhere((e) => e.name == json['type']),
      userId: json['userId'],
      isAllDay: json['isAllDay'] ?? false,
      reminderTimes: (json['reminderTimes'] as List<dynamic>?)
              ?.map((t) => DateTime.parse(t))
              .toList() ??
          [],
      calendarEventId: json['calendarEventId'],
      timezone: json['timezone'] ?? 'UTC',
    );
  }
}
