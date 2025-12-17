import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../widgets/form_fields/name_field.dart';
import '../widgets/form_fields/email_field.dart';
import '../widgets/form_fields/password_field.dart';
import '../widgets/form_fields/dob_field.dart';
import '../widgets/error_snackbar.dart';
import '../widgets/horizontal_divider.dart';
import '../api/auth_service.dart';
import '../api/models/register_request.dart';
import '../api/api_exception.dart';
import '../api/google_auth_service.dart';

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

  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final dobText = _dobController.text.trim();
    final parts = dobText.split('/');

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

    // Get the AuthService from Provider
    final authService = Provider.of<AuthService>(context, listen: false);

    String? errorMessage;

    try {
      // Now register() returns an AuthResponse and updates AuthState internally
      await authService.register(request);

      // Check if user is set in AuthState
      final user = authService.authState.user;
      if (user != null) {
        _onRegisterSuccess();
      } else {
        _onRegisterError("Registration failed. Please try again.");
      }
    } on ApiException catch (e) {
      errorMessage = "Registration failed: ${e.message}";
      _onRegisterError(errorMessage);
    } catch (e) {
      errorMessage = "Registration failed: ${e.toString()}";
      _onRegisterError(errorMessage);
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

    return GestureDetector(
      behavior:
          HitTestBehavior.opaque, // ensures taps on empty space are detected
      onTap: () => FocusScope.of(context).unfocus(), // dismiss keyboard
      child: Scaffold(
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
                      DOBField(controller: _dobController),
                      const SizedBox(height: 32),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: () async {
                                FocusScope.of(context).unfocus();
                                await _submit();
                              },
                              child: const Text("Register"),
                            ),

                      const SizedBox(height: 24),

                      const HorizontalDivider(text: "Or:"),

                      const SizedBox(height: 16),

                      /// GOOGLE REGISTER BUTTON
                      ElevatedButton.icon(
                        icon: SvgPicture.asset(
                          'assets/google_logo.svg',
                          height: 20,
                        ),
                        label: const Text("Continue with Google"),
                        onPressed: () async {
                          try {
                            final auth = Provider.of<AuthService>(context,
                                listen: false);

                            await GoogleAuthService(authState: auth.authState)
                                .signInWithGoogle();

                            if (!context.mounted) return;

                            if (auth.authState.user != null) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => HomeScreen()),
                              );
                            } else {
                              showErrorSnackBar(
                                  context, "Google registration failed");
                            }
                          } on ApiException catch (e) {
                            showErrorSnackBar(context, e.message);
                          }
                        },
                      ),
                    ],
                  ),
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
