import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../screens/home_screen.dart';
import '../../api/auth/auth_service.dart';
import '../../api/auth/fb_auth_service.dart';

class FacebookLoginButton extends StatelessWidget {
  const FacebookLoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    final fbAuth = FbAuthService(auth: auth);

    return ElevatedButton.icon(
      icon: const Icon(Icons.facebook),
      label: const Text("Continue with Facebook"),
      onPressed: () async {
        try {
          await fbAuth.login();

          if (!context.mounted) return;

          if (auth.authState.user != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen()),
            );
          }
        } catch (e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      },
    );
  }
}
