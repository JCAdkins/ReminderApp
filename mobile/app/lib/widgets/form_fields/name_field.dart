import 'package:flutter/material.dart';

class NameField extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;

  const NameField({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: firstNameController,
            decoration: const InputDecoration(labelText: "First Name"),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "First name cannot be empty";
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: lastNameController,
            decoration: const InputDecoration(labelText: "Last Name"),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Last name cannot be empty";
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
