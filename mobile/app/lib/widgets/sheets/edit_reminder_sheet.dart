import 'package:flutter/material.dart';
import 'package:mobile_app/widgets/sheets/reminder_form.dart';
import 'package:provider/provider.dart';

import '../../api/auth/auth_service.dart';
import '../../api/models/reminder.dart';
import '../../api/models/reminder_create.dart';
import '../../api/reminder/reminder_service.dart';
import '../../store/reminder_store.dart';
import '../sheet_handle.dart';

class EditReminderSheet extends StatefulWidget {
  final Reminder reminder;

  const EditReminderSheet({super.key, required this.reminder});

  @override
  State<EditReminderSheet> createState() => _EditReminderSheetState();
}

class _EditReminderSheetState extends State<EditReminderSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    final r = widget.reminder;
    _titleController = TextEditingController(text: r.title);
    _descriptionController = TextEditingController(text: r.description ?? '');
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
                    ReminderForm(
                      initialTitle: widget.reminder.title,
                      initialDescription: widget.reminder.description,
                      initialDate: widget.reminder.startAt,
                      initialTime: TimeOfDay(
                        hour: widget.reminder.startAt.hour,
                        minute: widget.reminder.startAt.minute,
                      ),
                      initialType: widget.reminder.type,
                      submitLabel: 'Save Changes',
                      onSubmit: (data) async {
                        final request = ReminderCreateRequest(
                          title: data.title,
                          description: data.description,
                          type: data.type,
                          startAt: data.startDateTime,
                          isAllDay: widget.reminder.isAllDay,
                          notifyOffsets: widget.reminder.notifyOffsets,
                          priority: widget.reminder.priority,
                          timezone: widget.reminder.timezone,
                        );

                        final updated = await ReminderService(
                          authState: auth.authState,
                        ).updateReminder(widget.reminder.id!, request);

                        if (!context.mounted) return;

                        final store = context.read<ReminderStore>();
                        store.removeReminder(widget.reminder.id!);
                        store.addReminder(updated);

                        Navigator.pop(context);
                      },
                    ),
                  ],
                ));
          },
        ),
      ),
    );
  }
}
