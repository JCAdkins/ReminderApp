import 'package:flutter/material.dart';

import '../api/models/reminder.dart';

class ReminderStore extends ChangeNotifier {
  final List<Reminder> _reminders = [];

  List<Reminder> get reminders => List.unmodifiable(_reminders);

  void addReminder(Reminder reminder) {
    _reminders.insert(0, reminder); // newest first
    notifyListeners();
  }

  void setReminders(List<Reminder> reminders) {
    _reminders
      ..clear()
      ..addAll(reminders);
    notifyListeners();
  }

  void removeReminder(String id) {
    _reminders.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  List<Reminder> remindersForDay(DateTime day) {
    return _reminders.where((r) {
      final d = r.startAt.toLocal();
      return d.year == day.year && d.month == day.month && d.day == day.day;
    }).toList();
  }
}
