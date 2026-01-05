import 'package:flutter/material.dart';
import 'package:mobile_app/api/reminder/reminder_service.dart';
import 'package:mobile_app/store/reminder_store.dart';
import 'package:mobile_app/widgets/sheets/edit_reminder_sheet.dart';
import 'package:provider/provider.dart';

import '../../api/models/reminder.dart';
import '../sheet_handle.dart';

class ReminderDetailsSheet extends StatelessWidget {
  final Reminder reminder;

  const ReminderDetailsSheet({super.key, required this.reminder});

  @override
  Widget build(BuildContext context) {
    void openEditReminderSheet(Reminder reminder) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => EditReminderSheet(reminder: reminder),
      );
    }

    Future<void> openDeleteReminderConfirmation(
      Reminder reminder,
    ) async {
      final reminderService =
          Provider.of<ReminderService>(context, listen: false);
      final store = context.read<ReminderStore>();

      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text('Delete Reminder'),
            content: const Text(
              'Are you sure you want to delete this reminder?\n\nThis action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                onPressed: () => {
                  Navigator.pop(context, true),
                  // Navigator.pop(context, false)
                },
                child: const Text('Delete'),
              ),
            ],
          );
        },
      );

      if (confirmed != true || !context.mounted) return;
      try {
        await reminderService.deleteReminder(reminder.id!);

        store.removeReminder(reminder.id!);

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Reminder deleted'), backgroundColor: Colors.green),
        );

        Navigator.pop(context); // close sheet
      } catch (e) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete reminder',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }

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
                  onPressed: () => openEditReminderSheet(reminder),
                  child: const Text("Edit Reminder"),
                ),
                const SizedBox(height: 16),

                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                  onPressed: () => openDeleteReminderConfirmation(reminder),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete),
                      SizedBox(width: 8),
                      Text("Delete Reminder"),
                    ],
                  ),
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
