import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  static String get apiBaseUrl {
    // dotenv works for both mobile and web if loaded in main.dart
    return dotenv.env['API_URL'] ?? 'http://localhost:8000';
  }
}
