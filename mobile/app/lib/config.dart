import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:html' as html;




class Config {
static String get apiBaseUrl {
  if (kIsWeb) {
    return const String.fromEnvironment('API_URL', defaultValue: 'http://localhost:8000');
  }
  return dotenv.env['API_URL'] ?? 'http://localhost:8000';
}
}
