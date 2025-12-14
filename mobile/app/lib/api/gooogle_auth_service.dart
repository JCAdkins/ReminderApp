import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GoogleAuthService {
  late final GoogleSignIn _googleSignIn;

  GoogleAuthService() {
    _googleSignIn = GoogleSignIn(
      clientId: _getClientId(),
      scopes: ['email', 'profile'],
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

  Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Silent sign-in first
        var account = await _googleSignIn.signInSilently();
        if (account != null) return account;
      }

      return await _googleSignIn.signIn();
    } catch (e) {
      print('Google Sign-In error: $e');
      return null;
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
