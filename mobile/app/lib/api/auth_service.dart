import 'package:dio/dio.dart';
import 'api_client.dart';
import 'models/login_request.dart';
import 'models/register_request.dart';
import 'models/login_response.dart';
import 'models/user.dart';
import '../api/api_exception.dart';
import '../utils/token_storage.dart';

class AuthService {
  final ApiClient api = ApiClient();

  // --------------------
  // LOGIN
  // --------------------
  Future<bool> login(LoginRequest request) async {
    try {
      final res = await api.dio.post(
        "/auth/login",
        data: request.toJson(),
      );

      final loginRes = LoginResponse.fromJson(res.data);

      // Save tokens using TokenStorage class
      await TokenStorage.saveTokens(
        accessToken: loginRes.accessToken,
        refreshToken: loginRes.refreshToken,
      );

      return true;
    } on DioException catch (e) {
      String message = "Login failed";
      if (e.response != null && e.response?.data != null) {
        message = e.response?.data['detail'] ?? message;
      }

      throw ApiException(message);
    } catch (e) {
      throw ApiException("Unexpected login error");
    }
  }

  Future<bool> loginWithGoogle(String idToken) async {
    try {
      final response = await api.dio.post(
        '/auth/google/mobile',
        data: {'id_token': idToken},
      );

      if (response.data == null) return false;

      await TokenStorage.saveTokens(
          accessToken: response.data['access_token'],
          refreshToken: response.data['refresh_token']);
      return true;
    } on DioException catch (e) {
      String message = "Login failed";
      if (e.response != null && e.response?.data != null) {
        message = e.response?.data['detail'] ?? message;
      }

      throw ApiException(message);
    } catch (e) {
      throw ApiException("Unexpected login error");
    }
  }

  Future<bool> loginWithGoogleWeb(
      String email, String id, String accessToken) async {
    try {
      final response = await api.dio.post(
        '/auth/google/web',
        data: {'email': email, "google_id": id, "access_token": accessToken},
      );

      if (response.data == null) return false;

      await TokenStorage.saveTokens(
          accessToken: response.data['access_token'],
          refreshToken: response.data['refresh_token']);
      return true;
    } on DioException catch (e) {
      String message = "Login failed";
      if (e.response != null && e.response?.data != null) {
        message = e.response?.data['detail'] ?? message;
      }

      throw ApiException(message);
    } catch (e) {
      throw ApiException("Unexpected login error");
    }
  }

  // --------------------
  // REGISTER
  // --------------------
  Future<bool> register(RegisterRequest request) async {
    try {
      final res = await api.dio.post(
        "/auth/register",
        data: request.toJson(),
      );

      final regRes = LoginResponse.fromJson(res.data);

      // Save tokens
      await TokenStorage.saveTokens(
        accessToken: regRes.accessToken,
        refreshToken: regRes.refreshToken,
      );

      return true;
    } on DioException catch (e) {
      String message = "Registration failed";
      if (e.response != null && e.response?.data != null) {
        message = e.response?.data['detail'] ?? message;
      }
      throw ApiException(message);
    } catch (e) {
      throw ApiException("Unexpected registration error");
    }
  }

  // --------------------
  // REFRESH ACCESS TOKENS
  // --------------------
  Future<bool> refreshAccessToken() async {
    final refreshToken = await TokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      final response = await api.dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      final loginRes = LoginResponse.fromJson(response.data);

      await TokenStorage.saveTokens(
        accessToken: loginRes.accessToken,
        refreshToken: loginRes.refreshToken,
      );

      return true;
    } catch (e) {
      // Could not refresh, maybe refresh token expired
      await TokenStorage.clearTokens();
      return false;
    }
  }

  // --------------------
  // GET ME
  // --------------------
  Future<User> getMe() async {
    final res = await api.dio.get("/auth/me");
    return User.fromJson(res.data);
  }

  // --------------------
  // LOGOUT
  // --------------------
  Future<void> logout() async {
    await TokenStorage.clearTokens();
  }
}
