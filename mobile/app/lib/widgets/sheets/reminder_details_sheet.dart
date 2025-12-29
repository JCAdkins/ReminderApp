import 'package:flutter/material.dart';

import '../../api/models/reminder.dart';
import '../sheet_handle.dart';

class ReminderDetailsSheet extends StatelessWidget {
  final Reminder reminder;

  const ReminderDetailsSheet({super.key, required this.reminder});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (_, controller) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(children: [
            const SheetHandle(), // drag indicator
            Expanded(
                child: ListView(
              controller: controller,
              children: [
                Text(
                  reminder.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                if (reminder.description != null)
                  Text(
                    reminder.description!,
                    style: const TextStyle(fontSize: 16),
                  ),

                const SizedBox(height: 20),

                _InfoRow(
                  icon: Icons.schedule,
                  label: "Time",
                  value: reminder.startAt.toLocal().toString(),
                ),

                _InfoRow(
                  icon: Icons.category,
                  label: "Type",
                  value: reminder.type.name,
                ),

                _InfoRow(
                  icon: Icons.priority_high,
                  label: "Priority",
                  value: reminder.priority.toString(),
                ),

                const SizedBox(height: 24),

                // Future: Edit / Delete
                ElevatedButton(
                  onPressed: () {
                    // TODO: edit flow
                  },
                  child: const Text("Edit Reminder"),
                ),
              ],
            ))
          ]),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text("$label: "),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
