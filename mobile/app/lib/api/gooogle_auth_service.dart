import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_app/api/api_exception.dart';
import './auth_service.dart';

class GoogleAuthService {
  final auth = AuthService();
  late final GoogleSignIn _googleSignIn;

  GoogleAuthService() {
    _googleSignIn = GoogleSignIn(
      clientId: _getClientId(),
      serverClientId: kIsWeb ? null : _getClientId(),
      scopes: ['email', 'profile', 'openid'],
    );
  }

  String _getClientId() {
    if (kIsWeb) {
      return dotenv.env['GOOGLE_CID_WEB']!;
    } else if (Platform.isAndroid) {
      return dotenv.env['GOOGLE_CID_ANDROID']!;
    } else if (Platform.isIOS) {
      return dotenv.env['GOOGLE_CID_iOS']!;
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      GoogleSignInAccount? googleUser;
      if (kIsWeb) {
        // Silent sign-in first
        googleUser = await _googleSignIn.signInSilently();
      }
      googleUser ??= await _googleSignIn.signIn();
      final googleAuth = await googleUser!.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        print('Google Sign-In failed or canceled');
        return false;
      }
      final success = await auth.loginWithGoogle(idToken);

      return success;
    } on DioException catch (e) {
      String message = "Login failed";
      if (e.response != null && e.response?.data != null) {
        message = e.response?.data['detail'] ?? message;
      }

      throw ApiException(message);
    } catch (e, st) {
      print("Error: $e");
      print("Stacktrace: $st");
      throw ApiException("Unexpected login error");
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  /// Get the current signed-in user (if any)
  Future<GoogleSignInAccount?> getCurrentUser() async {
    if (kIsWeb) {
      return await _googleSignIn.signInSilently();
    } else {
      return _googleSignIn.currentUser;
    }
  }
}
