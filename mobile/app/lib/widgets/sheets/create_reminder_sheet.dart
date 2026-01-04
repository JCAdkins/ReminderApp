import 'package:flutter/material.dart';
import 'package:mobile_app/api/models/reminder_create.dart';
import 'package:mobile_app/widgets/sheet_handle.dart';
import 'package:mobile_app/widgets/sheets/reminder_form.dart';
import 'package:provider/provider.dart';

import '../../api/auth/auth_service.dart';
import '../../api/models/reminder_type.dart';
import '../../api/reminder/reminder_service.dart';
import '../../store/reminder_store.dart';

class CreateReminderSheet extends StatefulWidget {
  const CreateReminderSheet({super.key});

  @override
  State<CreateReminderSheet> createState() => _CreateReminderSheetState();
}

class _CreateReminderSheetState extends State<CreateReminderSheet> {
  final _titleController = TextEditingController();

  final DateTime _selectedDate = DateTime.now();
  final TimeOfDay _selectedTime = TimeOfDay.now();
  final ReminderType _selectedType = ReminderType.task;

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
                  const SheetHandle(),
                  const SizedBox(height: 20),
                  ReminderForm(
                    initialTitle: '',
                    initialDescription: null,
                    initialDate: _selectedDate,
                    initialTime: _selectedTime,
                    initialType: _selectedType,
                    submitLabel: 'Save Reminder',
                    onSubmit: (data) async {
                      final request = ReminderCreateRequest(
                        title: data.title,
                        description: data.description,
                        type: data.type,
                        startAt: data.startDateTime,
                        isAllDay: false,
                        notifyOffsets: [0],
                        priority: 0,
                        timezone: DateTime.now().timeZoneName,
                      );

                      final created = await ReminderService(
                        authState: auth.authState,
                      ).createReminder(request);

                      if (!context.mounted) return;

                      context.read<ReminderStore>().addReminder(created);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
