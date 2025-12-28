import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../api_exception.dart';
import 'auth_service.dart';

class FbAuthService {
  final AuthService auth;

  FbAuthService({required this.auth});

  /// Logs in via Facebook (handles Web and Mobile)
  Future<void> login() async {
    try {
      final result = await FacebookAuth.instance.login(
          permissions: ['email', 'public_profile'],
          loginTracking: LoginTracking.enabled,
          loginBehavior: LoginBehavior.nativeWithFallback);

      if (result.status != LoginStatus.success) {
        throw ApiException("Facebook login failed: ${result.status}");
      }

      final fbToken = result.accessToken?.tokenString;

      if (fbToken == null || fbToken.isEmpty) {
        throw ApiException('Facebook login failed: missing access token');
      }

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
