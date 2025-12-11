import 'package:flutter/material.dart';
import '../widgets/form_fields/name_field.dart';
import '../widgets/form_fields/email_field.dart';
import '../widgets/form_fields/password_field.dart';
import '../widgets/form_fields/dob_field.dart';
import '../widgets/error_snackbar.dart';
import '../api/auth_service.dart';
import '../api/models/register_request.dart';
import '../api/api_exception.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _isLoading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return; // Stop if form is invalid
    }

    setState(() {
      _isLoading = true;
    });

    final request = RegisterRequest(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      dob: DateTime.parse(_dobController.text),
    );

    try {
      final response = await _authService.register(request);

      if (response.accessToken.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registration successful!"),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to login or home
        Navigator.pop(context);
      } else {
        showErrorSnackBar(
          context, 
          "Registration failed. Email may already be in use."
        );
      }
    } on ApiException catch (e) {
      showErrorSnackBar(context, "Registration failed: ${e.message}");
    } catch (e) {
      showErrorSnackBar(context, "Registration failed: ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              NameField(
                firstNameController: _firstNameController,
                lastNameController: _lastNameController,
                ),
              const SizedBox(height: 16),
              EmailField(controller: _emailController),
              const SizedBox(height: 16),
              PasswordField(controller: _passwordController),
              const SizedBox(height: 16),
              DOBField(controller: _dobController),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      child: const Text("Register"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
