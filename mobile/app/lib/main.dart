import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'screens/open_screen.dart';
import 'auth/auth_state.dart';
import 'api/auth/auth_service.dart';
import 'store/reminder_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(); // loads .env for mobile & web
  tz.initializeTimeZones();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReminderStore()),
        // Global auth state
        ChangeNotifierProvider(
          create: (_) => AuthState(),
        ),

        // 🔁 AuthService depends on AuthState
        ProxyProvider<AuthState, AuthService>(
          update: (_, authState, __) => AuthService(
            authState: authState,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Auth Demo",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: OpenScreen(),
    );
  }
}
