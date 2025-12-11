import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';
import 'models/login_request.dart';
import 'models/register_request.dart';
import 'models/login_response.dart';
import 'models/user.dart';
import 'dart:convert';

class AuthService {
  final ApiClient api = ApiClient();
  final Dio _client = ApiClient().dio;
  static const _storage = FlutterSecureStorage();

// Login user
  Future<LoginResponse> login(LoginRequest request) async {
    try{
    final res = await api.dio.post(
      "/auth/login",
      data: request.toJson(),
    );

    final loginRes = LoginResponse.fromJson(res.data);

    // Save tokens
    await _storage.write(key: "access_token", value: loginRes.accessToken);
    if (loginRes.refreshToken != null) {
      await _storage.write(key: "refresh_token", value: loginRes.refreshToken);
    }

    return loginRes;
    } catch(e){
        print('Register error: $e');
        return LoginResponse(      
            accessToken: "",
            refreshToken: "",
            tokenType: "");
    }
  }

// Register user
    Future<LoginResponse> register(RegisterRequest request) async {
        print(jsonEncode(request.toJson()));
    try {
    final response = await _client.post(
      "/auth/register",
      data: request.toJson(),
    );

    return LoginResponse.fromJson(response.data);
    } catch(e){
        print('Register error: $e');
        return LoginResponse(      
            accessToken: "",
            refreshToken: "",
            tokenType: "");
    }
  }

  Future<User> getMe() async {
    final res = await api.dio.get("/auth/me");
    return User.fromJson(res.data);
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<String?> getAccessToken() => _storage.read(key: "access_token");
}
