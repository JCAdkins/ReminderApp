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

  void replaceReminder(Reminder updated) {
    final index = _reminders.indexWhere((r) => r.id == updated.id);
    if (index != -1) {
      _reminders[index] = updated;
      notifyListeners();
    }
  }

  List<Reminder> getUpcomingReminders() {
    List<Reminder> upcomingReminders =
        _reminders.where((r) => _isUpcoming(r)).toList();
    upcomingReminders.sort((r1, r2) => r1.startAt.compareTo(r2.startAt));
    return upcomingReminders;
  }

  List<Reminder> remindersForDay(DateTime day) {
    return _reminders.where((r) {
      final d = r.startAt.toLocal();
      return d.year == day.year && d.month == day.month && d.day == day.day;
    }).toList();
  }

  bool _isUpcoming(Reminder r) {
    final now = DateTime.now();
    return r.status == 'active' && r.startAt.isAfter(now);
  }
}
