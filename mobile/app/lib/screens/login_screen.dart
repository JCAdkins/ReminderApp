import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_app/widgets/horizontal_divider.dart';
import 'package:provider/provider.dart' show Provider;

import '../api/auth/google_auth_service.dart';
import '../api/auth/auth_service.dart';
import '../api/models/login_request.dart';
import '../api/api_exception.dart';
import './register_screen.dart';
import '../widgets/form_fields/email_field.dart';
import '../widgets/form_fields/password_field.dart';
import '../widgets/buttons/fb_login_button.dart';
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

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);

    return GestureDetector(
      behavior:
          HitTestBehavior.opaque, // ensures taps on empty space are detected
      onTap: () => FocusScope.of(context).unfocus(), // dismiss keyboard
      child: Scaffold(
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
                          FocusScope.of(context).unfocus();
                          if (_formKey.currentState!.validate()) {
                            final request = LoginRequest(
                              email: emailCtrl.text.trim(),
                              password: passCtrl.text,
                            );

                            try {
                              await auth.login(request);

                              if (!context.mounted) return;

                              if (auth.authState.user != null) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => HomeScreen()),
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

                      const SizedBox(height: 18),

                      /// FORGOT PASSWORD
                      Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: () {
                            FocusScope.of(context).unfocus();
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
                          FocusScope.of(context).unfocus();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterScreen()),
                          );
                        },
                        child: const Text("Don't have an account? Register"),
                      ),

                      const SizedBox(height: 16),

                      const HorizontalDivider(text: "Or: "),

                      const SizedBox(height: 24),

                      ElevatedButton.icon(
                        icon: SvgPicture.asset('assets/google_logo.svg',
                            height: 20),
                        label: const Text("Continue with Google"),
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          try {
                            await GoogleAuthService(authState: auth.authState)
                                .signInWithGoogle();

                            if (!context.mounted) return;

                            if (auth.authState.user != null) {
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
                      const SizedBox(height: 12),

                      const FacebookLoginButton(),
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
}
