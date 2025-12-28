import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/token_storage.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import '../api/auth/auth_service.dart';
import 'home_screen.dart';

class OpenScreen extends StatefulWidget {
  const OpenScreen({super.key});

  @override
  State<OpenScreen> createState() => _OpenScreenState();
}

class _OpenScreenState extends State<OpenScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthService>(context, listen: false);

    Future<void> checkLogin() async {
      // 1️⃣ Check your app's stored tokens first
      final accessToken = await TokenStorage.getAccessToken();
      final refreshToken = await TokenStorage.getRefreshToken();

      if (!mounted) return;

      if (accessToken != null || refreshToken != null) {
        // Try auto-login with your backend tokens
        await auth.tryAutoLogin();
        if (auth.authState.user != null) {
          setState(() {
            _loading = false; // done checking
          });
          _goToHome();
          return;
        }
      }
      setState(() {
        _loading = false; // done checking
      });
      // If neither method succeeded, user stays on OpenScreen
    }

    checkLogin();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/open_image.png',
            fit: BoxFit.cover,
          ),
          // Overlay for better readability
          Container(
            color: Colors.black.withValues(alpha: 0.4),
          ),
          // Content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // App Title
              Text(
                'Reminder',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      offset: Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              // Login Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.blueAccent,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                  );
                },
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(height: 20),
              // Register Prompt
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account?",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => RegisterScreen()),
                      );
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        color: Colors.yellowAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen()),
    );
  }
}
