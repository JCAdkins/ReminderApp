import 'package:flutter/material.dart';

class ReminderTitleField extends StatelessWidget {
  final TextEditingController controller;
  final bool autofocus;

  const ReminderTitleField({
    super.key,
    required this.controller,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      decoration: const InputDecoration(
        labelText: "Title",
        border: OutlineInputBorder(),
      ),
    );
  }
}
