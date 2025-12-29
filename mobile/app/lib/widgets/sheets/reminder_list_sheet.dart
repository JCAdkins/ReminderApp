import 'package:flutter/material.dart';

import '../../api/models/reminder.dart';
import '../reminder_list_tile.dart';
import '../sheet_handle.dart';

class ReminderListSheet extends StatelessWidget {
  final List<Reminder> reminders;
  final void Function(Reminder reminder) onReminderTap;

  const ReminderListSheet({
    super.key,
    required this.reminders,
    required this.onReminderTap,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SheetHandle(), // drag indicator
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  itemCount: reminders.length,
                  itemBuilder: (_, i) {
                    final reminder = reminders[i];
                    return ReminderListTile(
                      reminder: reminder,
                      onTap: () => onReminderTap(reminder),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
