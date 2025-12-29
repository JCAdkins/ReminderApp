import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../api/models/reminder.dart';

class ReminderCalendar extends StatelessWidget {
  final List<Reminder> reminders;
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final void Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;

  const ReminderCalendar({
    super.key,
    required this.reminders,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
  });

  // reactive event lookup
  List<Reminder> _eventsForDay(DateTime day) {
    return reminders.where((r) {
      return isSameDay(r.startAt, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar<Reminder>(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: focusedDay,
      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
      onDaySelected: onDaySelected,
      eventLoader: _eventsForDay,
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.blueAccent,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.purpleAccent,
          shape: BoxShape.circle,
        ),
        defaultTextStyle: const TextStyle(color: Colors.black87),
        weekendTextStyle: const TextStyle(color: Colors.black54),

        // dot indicator styling
        markerDecoration: const BoxDecoration(
          color: Colors.redAccent,
          shape: BoxShape.circle,
        ),
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
        rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: Colors.black54),
        weekendStyle: TextStyle(color: Colors.black54),
      ),
    );
  }
}
