import 'package:dio/dio.dart';
import 'package:mobile_app/api/api_exception.dart';
import 'package:mobile_app/utils/token_storage.dart';

import 'api_client.dart';
import 'models/login_request.dart';
import 'models/register_request.dart';
import 'models/login_response.dart';
import 'models/user.dart';

class AuthService {
  // 🔐 Main API client (WITH interceptors)
  final ApiClient api;

  AuthService([ApiClient? api]) : api = api ?? ApiClient();

  // ============================
  // LOGIN (EMAIL + PASSWORD)
  // ============================
  Future<bool> login(LoginRequest request) async {
    try {
      final res = await api.dio.post(
        "/auth/login",
        data: request.toJson(),
      );

      final loginRes = LoginResponse.fromJson(res.data);

      await TokenStorage.saveTokens(
        accessToken: loginRes.accessToken,
        refreshToken: loginRes.refreshToken,
      );

      return true;
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['detail'] ?? "Login failed",
      );
    } catch (_) {
      throw ApiException("Unexpected login error");
    }
  }

  // ============================
  // GOOGLE LOGIN (MOBILE)
  // ============================
  Future<bool> loginWithGoogle(String idToken) async {
    try {
      final response = await api.dio.post(
        '/auth/google/mobile',
        data: {'id_token': idToken},
      );

      if (response.data == null) return false;

      await TokenStorage.saveTokens(
        accessToken: response.data['access_token'],
        refreshToken: response.data['refresh_token'],
      );

      return true;
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['detail'] ?? "Google login failed",
      );
    } catch (_) {
      throw ApiException("Unexpected Google login error");
    }
  }

  // ============================
  // GOOGLE LOGIN (WEB)
  // ============================
  Future<bool> loginWithGoogleWeb(
    String email,
    String googleId,
    String accessToken,
  ) async {
    try {
      final response = await api.dio.post(
        '/auth/google/web',
        data: {
          'email': email,
          'google_id': googleId,
          'access_token': accessToken,
        },
      );

      if (response.data == null) return false;

      await TokenStorage.saveTokens(
        accessToken: response.data['access_token'],
        refreshToken: response.data['refresh_token'],
      );

      return true;
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['detail'] ?? "Google login failed",
      );
    } catch (_) {
      throw ApiException("Unexpected Google login error");
    }
  }

  // ============================
  // AUTO LOGIN
  // ============================
  Future<bool> tryAutoLogin() async {
    try {
      await api.dio.get("/auth/me");
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return await refreshAccessToken();
      }
      return false;
    }
  }

  // ============================
  // REFRESH ACCESS TOKEN
  // ============================
  Future<bool> refreshAccessToken() async {
    final refreshToken = await TokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      final res = await api.refreshDio.post(
        "/auth/refresh",
        data: {"refresh_token": refreshToken},
      );

      final loginRes = LoginResponse.fromJson(res.data);

      await TokenStorage.saveTokens(
        accessToken: loginRes.accessToken,
        refreshToken: loginRes.refreshToken,
      );

      return true;
    } catch (_) {
      await TokenStorage.clearTokens();
      return false;
    }
  }

  // ============================
  // GET CURRENT USER
  // ============================
  Future<User> getMe() async {
    final res = await api.dio.get("/auth/me");
    return User.fromJson(res.data);
  }

  // ============================
  // REGISTER
  // ============================
  Future<bool> register(RegisterRequest request) async {
    try {
      final res = await api.dio.post(
        "/auth/register",
        data: request.toJson(),
      );

      final loginRes = LoginResponse.fromJson(res.data);

      await TokenStorage.saveTokens(
        accessToken: loginRes.accessToken,
        refreshToken: loginRes.refreshToken,
      );

      return true;
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['detail'] ?? "Registration failed",
      );
    } catch (_) {
      throw ApiException("Unexpected registration error");
    }
  }

  // ============================
  // LOGOUT
  // ============================
  Future<void> logout() async {
    await TokenStorage.clearTokens();
  }
}
