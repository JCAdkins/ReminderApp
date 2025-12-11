import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;

  const PasswordField({super.key, required this.controller});

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: "Password",
        suffixIcon: IconButton(
          icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
      ),
      obscureText: _obscureText,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Password cannot be empty";
        }
        if (value.length < 10) {
          return "Password must be at least 10 characters";
        }
        final specialCharRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
        if (!specialCharRegex.hasMatch(value)) {
          return "Password must contain at least one special character";
        }
        return null;
      },
    );
  }
}
