import 'package:dio/dio.dart';
import 'api_client.dart';
import 'models/oauth_token_request.dart';
import 'models/login_response.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OAuthGoogleService {
  final ApiClient api = ApiClient();
  static const _storage = FlutterSecureStorage();

  Future<LoginResponse> loginWithGoogle(String idToken) async {
    final body = OAuthTokenRequest(idToken: idToken);

    final res = await api.dio.post(
      "/auth/oauth/google",
      data: body.toJson(),
    );

    final loginRes = LoginResponse.fromJson(res.data);

    // Store tokens
    await _storage.write(key: "access_token", value: loginRes.accessToken);
    if (loginRes.refreshToken != null) {
      await _storage.write(key: "refresh_token", value: loginRes.refreshToken);
    }

    return loginRes;
  }
}
