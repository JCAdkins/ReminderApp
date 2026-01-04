import 'package:flutter/material.dart';

class ReminderDescriptionField extends StatelessWidget {
  final TextEditingController controller;

  const ReminderDescriptionField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: null,
      decoration: const InputDecoration(
        labelText: "Description",
        border: OutlineInputBorder(),
      ),
    );
  }
}
