import 'package:flutter/material.dart';
import 'package:mobile_app/widgets/form_fields/reminder/date_time_row.dart';

import '../../api/models/reminder_type.dart';
import '../selector_dropdown.dart';

class ReminderFormData {
  final String title;
  final String? description;
  final DateTime date;
  final TimeOfDay time;
  final ReminderType type;

  ReminderFormData({
    required this.title,
    this.description,
    required this.date,
    required this.time,
    required this.type,
  });

  DateTime get startDateTime => DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
}

class ReminderForm extends StatefulWidget {
  final String initialTitle;
  final String? initialDescription;
  final DateTime initialDate;
  final TimeOfDay initialTime;
  final ReminderType initialType;

  final String submitLabel;
  final Future<void> Function(ReminderFormData data) onSubmit;

  const ReminderForm({
    super.key,
    required this.initialTitle,
    required this.initialDate,
    required this.initialTime,
    required this.initialType,
    required this.submitLabel,
    required this.onSubmit,
    this.initialDescription,
  });

  @override
  State<ReminderForm> createState() => _ReminderFormState();
}

class _ReminderFormState extends State<ReminderForm> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  late DateTime _date;
  late TimeOfDay _time;
  late ReminderType _type;

  bool _submitting = false;

  bool get _isValid => _titleController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _descriptionController =
        TextEditingController(text: widget.initialDescription ?? '');

    _date = widget.initialDate;
    _time = widget.initialTime;
    _type = widget.initialType;

    _titleController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _handleSubmit() async {
    if (!_isValid || _submitting) return;

    setState(() => _submitting = true);

    await widget.onSubmit(
      ReminderFormData(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        date: _date,
        time: _time,
        type: _type,
      ),
    );

    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Title
        TextField(
          controller: _titleController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Title',
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 16),

        /// Description
        TextField(
          controller: _descriptionController,
          maxLines: null,
          decoration: const InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 16),

        /// Date + Time
        ReminderDateTimeRow(
          selectedDate: _date,
          selectedTime: _time,
          onPickDate: _pickDate,
          onPickTime: _pickTime,
        ),

        const SizedBox(height: 20),

        /// Type
        TypeSelectorDropdown(
          types: ReminderType.values.map((e) => e.name).toList(),
          selectedType: _type.name,
          onChanged: (value) {
            setState(() {
              _type = ReminderTypeExtension.fromString(value);
            });
          },
        ),

        const SizedBox(height: 24),

        /// Submit
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isValid && !_submitting ? _handleSubmit : null,
            child: _submitting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(widget.submitLabel),
          ),
        ),
      ],
    );
  }
}
