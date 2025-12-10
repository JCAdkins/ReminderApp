import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import './api/auth_service.dart';
import './api/models/login_request.dart';

Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();

      if (!kIsWeb) {
    await dotenv.load(fileName: ".env");
  }

  final auth = AuthService();
  final loggedIn = await auth.login(LoginRequest(
    email: "test@example.com",
    password: "password123",
  ),);

  print("Logged in? $loggedIn");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text("Hello World"),
        ),
        
      ),
    );
  }
}

       