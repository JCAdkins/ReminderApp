import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../api/auth/auth_service.dart';
import '../../api/models/reminder.dart';
import '../../api/models/reminder_create.dart';
import '../../api/reminder/reminder_service.dart';
import '../../store/reminder_store.dart';
import '../sheet_handle.dart';
import '../selector_dropdown.dart';
import '../../api/models/reminder_type.dart';

class EditReminderSheet extends StatefulWidget {
  final Reminder reminder;

  const EditReminderSheet({super.key, required this.reminder});

  @override
  State<EditReminderSheet> createState() => _EditReminderSheetState();
}

class _EditReminderSheetState extends State<EditReminderSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late ReminderType _selectedType;

  @override
  void initState() {
    super.initState();
    final r = widget.reminder;
    _titleController = TextEditingController(text: r.title);
    _descriptionController = TextEditingController(text: r.description ?? '');
    _selectedDate = r.startAt;
    _selectedTime = TimeOfDay(hour: r.startAt.hour, minute: r.startAt.minute);
    _selectedType = r.type;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final auth = Provider.of<AuthService>(context, listen: false);

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SheetHandle(),
                  const SizedBox(height: 20),
                  _buildTitleField(),
                  const SizedBox(height: 16),
                  _buildDescriptionField(),
                  const SizedBox(height: 16),
                  _buildDateTimeRow(context),
                  const SizedBox(height: 20),
                  TypeSelectorDropdown(
                    types: ReminderType.values.map((e) => e.name).toList(),
                    selectedType: _selectedType.name,
                    onChanged: (value) {
                      setState(() {
                        _selectedType = ReminderTypeExtension.fromString(value);
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildSaveButton(context, auth),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextField(
      controller: _titleController,
      autofocus: true,
      decoration: const InputDecoration(
        labelText: "Title",
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return TextField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: "Description",
        border: OutlineInputBorder(),
      ),
      maxLines: null,
    );
  }

  Widget _buildDateTimeRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _pickDate,
            child: Text(DateFormat.yMMMd().format(_selectedDate)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: _pickTime,
            child: Text(_selectedTime.format(context)),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context, AuthService auth) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _submit(auth),
        child: const Text("Save Changes"),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _submit(AuthService auth) async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final description = _descriptionController.text.trim();
    final startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final updateRequest = ReminderCreateRequest(
      title: title,
      description: description.isEmpty ? null : description,
      type: _selectedType,
      startAt: startDateTime,
      isAllDay: widget.reminder.isAllDay,
      notifyOffsets: widget.reminder.notifyOffsets,
      priority: widget.reminder.priority,
      timezone: widget.reminder.timezone,
    );

    try {
      final updated = await ReminderService(authState: auth.authState)
          .updateReminder(widget.reminder.id!, updateRequest);

      if (!mounted) return;

      final store = context.read<ReminderStore>();
      store.removeReminder(widget.reminder.id!);
      store.addReminder(updated);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminder updated successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update reminder: $e')),
        );
      }
    }
  }
}
