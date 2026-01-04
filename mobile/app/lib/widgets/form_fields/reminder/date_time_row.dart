import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReminderDateTimeRow extends StatelessWidget {
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;

  const ReminderDateTimeRow({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.onPickDate,
    required this.onPickTime,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onPickDate,
            child: Text(
              DateFormat.yMMMd().format(selectedDate),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: onPickTime,
            child: Text(
              selectedTime.format(context),
            ),
          ),
        ),
      ],
    );
  }
}
