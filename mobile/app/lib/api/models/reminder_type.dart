enum ReminderType {
  birthday,
  anniversary,
  task,
  bill,
  health,
  trip,
  custom,
}

extension ReminderTypeExtension on ReminderType {
  String get displayName => name[0].toUpperCase() + name.substring(1);

  static ReminderType fromString(String value) =>
      ReminderType.values.firstWhere(
        (e) => e.name == value,
        orElse: () => ReminderType.custom,
      );
}
