import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import './api_exception.dart';
import './auth_service.dart';

class FbAuthService {
  final AuthService auth;

  FbAuthService({required this.auth});

  /// Logs in via Facebook (handles Web and Mobile)
  Future<void> login() async {
    try {
      final result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      // final result = await FacebookAuth.instance.login(
      //   loginBehavior: LoginBehavior.nativeWithFallback,
      //   permissions: ['email', 'public_profile'],
      //   loginTracking: LoginTracking.limited, // 🔑 REQUIRED
      // );

      final idToken = result.accessToken?.token;

      if (result.status != LoginStatus.success) {
        throw ApiException("Facebook login failed: ${result.status}");
      }
      print("accessToken: ${result.accessToken}");
      final fbToken = result.accessToken!.token;
      print("token: $fbToken");

      if (kIsWeb) {
        throw ApiException("Facebook login is not supported on web yet.");
      } else {
        await auth.loginWithFacebookMobile(fbToken);
        // Put self made access_token here --------------------------------------------------------------------------------
      }
    } catch (e) {
      if (e is ApiException) {
        // Already a nicely formatted message
        rethrow;
      } else {
        throw ApiException("Error during Facebook login: $e");
      }
    }
  }

  /// Logs out from Facebook (optional)
  Future<void> logout() async {
    try {
      await FacebookAuth.instance.logOut();
      await auth.logout();
    } catch (e) {
      print("Error during Facebook logout: $e");
    }
  }

  /// Get the current Facebook access token if exists
  Future<AccessToken?> getCurrentAccessToken() async {
    return await FacebookAuth.instance.accessToken;
  }
}
