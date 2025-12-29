import './reminder_type.dart';

class ReminderCreateRequest {
  final String title;
  final String? description;
  final ReminderType type;
  final DateTime startAt;
  final DateTime? endAt;
  final String timezone;
  final bool isAllDay;
  final String? recurrenceRule;
  final List<int> notifyOffsets;
  final int priority;

  ReminderCreateRequest({
    required this.title,
    this.description,
    required this.type,
    required this.startAt,
    this.endAt,
    required this.timezone,
    required this.isAllDay,
    this.recurrenceRule,
    required this.notifyOffsets,
    required this.priority,
  });

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "description": description,
      "type": type.name,
      "start_at": startAt.toUtc().toIso8601String(),
      "end_at": endAt?.toUtc().toIso8601String(),
      "timezone": timezone,
      "is_all_day": isAllDay,
      "recurrence_rule": recurrenceRule,
      "notify_offsets": notifyOffsets,
      "priority": priority,
    };
  }
}
