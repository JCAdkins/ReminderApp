import '../models/reminder_type.dart';

class Reminder {
  final String? id;
  final String title;
  final String? description;
  final ReminderType type;
  final DateTime startAt;
  final DateTime? endAt;
  final bool isAllDay;
  final String timezone;
  final String? recurrenceRule;
  final List<int> notifyOffsets;
  final int priority;
  final String status;
  final DateTime? completedAt;

  Reminder({
    this.id,
    required this.title,
    this.description,
    required this.type,
    required this.startAt,
    this.endAt,
    this.isAllDay = false,
    required this.timezone,
    this.recurrenceRule,
    this.notifyOffsets = const [],
    this.priority = 0,
    this.status = 'active',
    this.completedAt,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: ReminderTypeExtension.fromString(json['type'] as String),
      startAt: DateTime.parse(json['start_at'] as String),
      endAt: json['end_at'] != null
          ? DateTime.parse(json['end_at'] as String)
          : null,
      isAllDay: json['is_all_day'] as bool? ?? false,
      timezone: json['timezone'] as String,
      recurrenceRule: json['recurrence_rule'] as String?,
      notifyOffsets: (json['notify_offsets'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      priority: json['priority'] as int? ?? 0,
      status: json['status'] as String? ?? 'active',
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      if (description != null) 'description': description,
      'type': type.name,
      'start_at': startAt.toUtc().toIso8601String(),
      if (endAt != null) 'end_at': endAt!.toUtc().toIso8601String(),
      'is_all_day': isAllDay,
      'timezone': timezone,
      if (recurrenceRule != null) 'recurrence_rule': recurrenceRule,
      'notify_offsets': notifyOffsets,
      'priority': priority,
      'status': status,
      if (completedAt != null)
        'completed_at': completedAt!.toUtc().toIso8601String(),
    };
  }
}
