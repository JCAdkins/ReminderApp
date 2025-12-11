import 'package:flutter/material.dart';

class DOBField extends StatefulWidget {
  final TextEditingController controller;

  const DOBField({super.key, required this.controller});

  @override
  _DOBFieldState createState() => _DOBFieldState();
}

class _DOBFieldState extends State<DOBField> {
  DateTime? _selectedDate;

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = _selectedDate ?? DateTime(now.year - 18); // Default 18 years ago
    final firstDate = DateTime(1900);
    final lastDate = now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        widget.controller.text = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2,'0')}-${pickedDate.day.toString().padLeft(2,'0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: "Date of Birth",
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () => _pickDate(context),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Date of Birth cannot be empty";
        }
        return null;
      },
      onTap: () => _pickDate(context),
    );
  }
}
