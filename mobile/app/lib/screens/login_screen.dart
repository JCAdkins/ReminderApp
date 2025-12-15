import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_app/api/gooogle_auth_service.dart';
import '../api/auth_service.dart';
import '../api/models/login_request.dart';
import '../api/api_exception.dart';
import './register_screen.dart';
import '../widgets/form_fields/email_field.dart';
import '../widgets/form_fields/password_field.dart';
import '../widgets/error_snackbar.dart';
import './home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height - kToolbarHeight,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// EMAIL FIELD
                    EmailField(controller: emailCtrl),
                    const SizedBox(height: 16),

                    /// PASSWORD FIELD
                    PasswordField(controller: passCtrl),

                    /// ADD MORE SPACE ABOVE LOGIN BUTTON
                    const SizedBox(height: 36),

                    /// LOGIN BUTTON
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final request = LoginRequest(
                            email: emailCtrl.text.trim(),
                            password: passCtrl.text,
                          );

                          try {
                            final success = await auth.login(request);

                            if (!context.mounted) return;

                            if (success) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => HomeScreen()),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Invalid credentials")),
                              );
                            }
                          } on ApiException catch (e) {
                            showErrorSnackBar(context, e.message);
                          }
                        }
                      },
                      child: const Text("Login"),
                    ),

                    /// LESS SPACE BEFORE REGISTER
                    const SizedBox(height: 16),

                    ElevatedButton.icon(
                      icon: SvgPicture.asset('assets/google_logo.svg',
                          height: 20),
                      label: const Text("Continue with Google"),
                      onPressed: () async {
                        try {
                          final success =
                              await GoogleAuthService().signInWithGoogle();

                          if (!context.mounted) return;

                          if (success) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => HomeScreen()),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Invalid credentials")),
                            );
                          }
                        } on ApiException catch (e) {
                          showErrorSnackBar(context, e.message);
                        }
                      },
                    ),

                    /// LESS SPACE BEFORE REGISTER
                    const SizedBox(height: 24),

                    /// FORGOT PASSWORD
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Forgot Password tapped"),
                            ),
                          );
                        },
                        child: const Text("Forgot Password?"),
                      ),
                    ),

                    /// GO TO REGISTER
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterScreen()),
                        );
                      },
                      child: const Text("Don't have an account? Register"),
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
}
