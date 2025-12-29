import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/api/models/reminder_create.dart';
import 'package:provider/provider.dart';

import '../../api/auth/auth_service.dart';
import '../../api/models/reminder.dart';
import '../../api/models/reminder_type.dart';
import '../../api/reminder/reminder_service.dart';
import '../../auth/auth_state.dart';
import '../../store/reminder_store.dart';
import '../selector_dropdown.dart';

class CreateReminderSheet extends StatefulWidget {
  const CreateReminderSheet({super.key});

  @override
  State<CreateReminderSheet> createState() => _CreateReminderSheetState();
}

class _CreateReminderSheetState extends State<CreateReminderSheet> {
  final _titleController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  ReminderType _selectedType = ReminderType.task;

  @override
  void dispose() {
    _titleController.dispose();
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
                  _DragHandle(),
                  const SizedBox(height: 20),
                  _buildTitleField(),
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
                  _buildSaveButton(context, auth.authState),
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

  Widget _buildSaveButton(BuildContext context, AuthState authState) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _submit(authState),
        child: const Text("Save Reminder"),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _submit(AuthState authState) async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // Create the Reminder object
    final reminder = ReminderCreateRequest(
      title: title,
      type: _selectedType,
      startAt: startDateTime,
      isAllDay: false,
      notifyOffsets: [0],
      priority: 0,
      timezone:
          DateTime.now().timeZoneName, // or allow user to pick a timezone later
    );

    try {
      // Call the backend via ReminderService
      final fReminder =
          await ReminderService(authState: authState).createReminder(reminder);

      // Optionally show a success snackbar
      if (context.mounted) {
        context.read<ReminderStore>().addReminder(fReminder);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminder created successfully!')),
        );
        Navigator.pop(context); // close the sheet
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create reminder: $e')),
        );
      }
    }
  }
}

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey.shade400,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
