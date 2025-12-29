import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../api/models/reminder.dart';
import 'icons/type_icons.dart';
import 'sheets/reminder_details_sheet.dart';

class ReminderListTile extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback? onTap;

  const ReminderListTile({
    super.key,
    required this.reminder,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFmt = DateFormat.jm(); // 5:30 PM

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap ??
              () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => ReminderDetailsSheet(reminder: reminder),
                );
              },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                TypeIcon(type: reminder.type),
                const SizedBox(width: 12),

                // Main content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _buildSubtitle(dateFmt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Status / priority (future)
                if (reminder.priority > 0)
                  Icon(
                    Icons.priority_high,
                    size: 18,
                    color: Colors.redAccent,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _buildSubtitle(DateFormat fmt) {
    if (reminder.isAllDay) {
      return 'All day';
    }
    return fmt.format(reminder.startAt.toLocal());
  }
}
