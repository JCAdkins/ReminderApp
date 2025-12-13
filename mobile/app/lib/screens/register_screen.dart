import 'package:flutter/material.dart';
import '../widgets/form_fields/name_field.dart';
import '../widgets/form_fields/email_field.dart';
import '../widgets/form_fields/password_field.dart';
import '../widgets/form_fields/dob_field.dart';
import '../widgets/error_snackbar.dart';
import '../api/auth_service.dart';
import '../api/models/register_request.dart';
import '../api/api_exception.dart';
import './home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final dobText = _dobController.text.trim();
    final parts = dobText.split('-');

    final dob = DateTime(
      int.parse(parts[2]), // year
      int.parse(parts[0]), // month
      int.parse(parts[1]), // day
    );

    final request = RegisterRequest(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      dob: dob,
    );

    bool? success;
    String? errorMessage;

    try {
      success = await _authService.register(request);
    } on ApiException catch (e) {
      errorMessage = "Registration failed: ${e.message}";
    } catch (e) {
      errorMessage = "Registration failed: ${e.toString()}";
    }

    // 🔐 IMPORTANT: Guard all UI work
    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success == true) {
      _onRegisterSuccess();
    } else {
      _onRegisterError(
        errorMessage ?? "Registration failed. Email may already be in use.",
      );
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
    final screenHeight = MediaQuery.of(context).size.height - kToolbarHeight;

    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: screenHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                    // Updated DOB field with custom picker
                    DOBField(controller: _dobController),
                    const SizedBox(height: 32),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _submit,
                            child: const Text("Register"),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onRegisterSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Registration successful!"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen()),
    );
  }

  void _onRegisterError(String message) {
    showErrorSnackBar(context, message);
  }
}
