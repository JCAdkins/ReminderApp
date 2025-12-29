import 'package:flutter/material.dart';

import '../../api/models/reminder_type.dart';

class TypeIcon extends StatelessWidget {
  final ReminderType type;

  const TypeIcon({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final iconData = switch (type) {
      ReminderType.birthday => Icons.cake,
      ReminderType.anniversary => Icons.favorite,
      ReminderType.task => Icons.check_circle_outline,
      ReminderType.bill => Icons.receipt_long,
      ReminderType.health => Icons.local_hospital,
      ReminderType.trip => Icons.flight_takeoff,
      ReminderType.custom => Icons.notifications,
    };

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: Colors.blueAccent,
        size: 22,
      ),
    );
  }
}
