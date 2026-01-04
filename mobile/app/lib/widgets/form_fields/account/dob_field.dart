import 'package:flutter/material.dart';
import '../../dob_picker.dart';

class DOBField extends StatelessWidget {
  final TextEditingController controller;
  final DateTime? initialDate;
  final ValueChanged<DateTime>? onChanged;
  final int _minimumAgeYears = 13;

  DateTime _parseInitialDate() {
    final text = controller.text.trim();

    if (text.isEmpty) {
      return initialDate ?? DateTime(2000, 1, 1);
    }

    try {
      final parts = text.split('/');
      return DateTime(
        int.parse(parts[2]),
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
    } catch (_) {
      return initialDate ?? DateTime(2000, 1, 1);
    }
  }

  bool _isOldEnough(DateTime dob) {
    final today = DateTime.now();

    int age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }

    return age >= _minimumAgeYears;
  }

  const DOBField({
    super.key,
    required this.controller,
    this.onChanged,
    this.initialDate,
  });

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/'
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  void _openPicker(BuildContext context) async {
    final selectedDate = await showDialog<DateTime>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: DOBPicker(
            initialDate: _parseInitialDate(),
            onConfirm: (date) {
              Navigator.of(dialogContext).pop(date); // ✅ pop dialog only
            },
          ),
        );
      },
    );

    if (selectedDate != null) {
      controller.text = _formatDate(selectedDate);
      onChanged?.call(selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openPicker(context),
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Date of Birth',
            hintText: 'MM/DD/YYYY',
            suffixIcon: Icon(Icons.calendar_today),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Date of birth is required';
            }

            try {
              final parts = value.split('/');
              final dob = DateTime(
                int.parse(parts[2]),
                int.parse(parts[0]),
                int.parse(parts[1]),
              );

              if (!_isOldEnough(dob)) {
                return 'You must be at least $_minimumAgeYears years old';
              }
            } catch (_) {
              return 'Invalid date';
            }

            return null;
          },
        ),
      ),
    );
  }
}
