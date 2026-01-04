import 'package:flutter/material.dart';
import '/api/models/reminder_type.dart';
import '../../selector_dropdown.dart';

class ReminderTypeSelector extends StatelessWidget {
  final ReminderType selectedType;
  final ValueChanged<ReminderType> onChanged;

  const ReminderTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TypeSelectorDropdown(
      types: ReminderType.values.map((e) => e.name).toList(),
      selectedType: selectedType.name,
      onChanged: (value) {
        onChanged(ReminderTypeExtension.fromString(value));
      },
    );
  }
}
