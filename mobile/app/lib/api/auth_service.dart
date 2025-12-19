import 'package:dio/dio.dart';
import 'package:mobile_app/api/api_exception.dart';
import 'package:mobile_app/utils/token_storage.dart';

import 'api_client.dart';
import 'models/login_request.dart';
import 'models/register_request.dart';
import 'models/auth_response.dart';
import 'models/user.dart';
import '../auth/auth_state.dart';

class AuthService {
  final ApiClient api;
  final AuthState authState;

  AuthService({
    ApiClient? api,
    required this.authState,
  }) : api = api ?? ApiClient(authState: authState);

  // ============================
  // LOGIN (EMAIL + PASSWORD)
  // ============================
  Future<void> login(LoginRequest request) async {
    try {
      final res = await api.dio.post(
        "/auth/login",
        data: request.toJson(),
      );

      final authRes = AuthResponse.fromJson(res.data);

      await TokenStorage.saveTokens(
        accessToken: authRes.tokens.accessToken,
        refreshToken: authRes.tokens.refreshToken,
      );

      authState.setSession(authRes);
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
  Future<void> loginWithGoogle(String idToken) async {
    try {
      final res = await api.dio.post(
        '/auth/google/mobile',
        data: {'id_token': idToken},
      );

      final authRes = AuthResponse.fromJson(res.data);

      await TokenStorage.saveTokens(
        accessToken: authRes.tokens.accessToken,
        refreshToken: authRes.tokens.refreshToken,
      );

      authState.setSession(authRes);
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
  Future<void> loginWithGoogleWeb(
    String email,
    String googleId,
    String accessToken,
  ) async {
    try {
      final res = await api.dio.post(
        '/auth/google/web',
        data: {
          'email': email,
          'google_id': googleId,
          'access_token': accessToken,
        },
      );

      final authRes = AuthResponse.fromJson(res.data);

      await TokenStorage.saveTokens(
        accessToken: authRes.tokens.accessToken,
        refreshToken: authRes.tokens.refreshToken,
      );

      authState.setSession(authRes);
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['detail'] ?? "Google login failed",
      );
    } catch (_) {
      throw ApiException("Unexpected Google login error");
    }
  }

// ============================
// FACEBOOK LOGIN (MOBILE)
// ============================
  Future<void> loginWithFacebookMobile(String fbToken) async {
    try {
      // Send only the access token to the backend
      final res = await api.dio.post(
        '/auth/facebook/mobile',
        data: {'access_token': fbToken},
      );

      final authRes = AuthResponse.fromJson(res.data);

      // Save access + refresh tokens
      await TokenStorage.saveTokens(
        accessToken: authRes.tokens.accessToken,
        refreshToken: authRes.tokens.refreshToken,
      );

      // Update global auth state
      authState.setSession(authRes);
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['detail'] ?? "Facebook login failed",
      );
    } catch (_) {
      throw ApiException("Unexpected Facebook login error");
    }
  }

  // ============================
  // AUTO LOGIN
  // ============================
  Future<void> tryAutoLogin() async {
    try {
      final res = await api.dio.get("/auth/me");
      final authRes = AuthResponse.fromJson(res.data);
      await TokenStorage.saveTokens(
        accessToken: authRes.tokens.accessToken,
        refreshToken: authRes.tokens.refreshToken,
      );
      authState.setSession(authRes);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await refreshAccessToken();
        final res = await api.dio.get("/auth/me");
        final authRes = AuthResponse.fromJson(res.data);
        authState.setSession(authRes);
      }
    } catch (e, st) {
      print("Error: $e"); // prints the error
      print("Stacktrace: $st"); // prints the stack trace
      throw ApiException(e.toString());
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

      final authRes = AuthResponse.fromJson(res.data);

      await TokenStorage.saveTokens(
        accessToken: authRes.tokens.accessToken,
        refreshToken: authRes.tokens.refreshToken,
      );

      authState.setSession(authRes); // update AuthState
      return true;
    } catch (_) {
      await TokenStorage.clearTokens();
      authState.logout(); // clear AuthState
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
  Future<void> register(RegisterRequest request) async {
    try {
      final res = await api.dio.post(
        "/auth/register",
        data: request.toJson(),
      );

      final authRes = AuthResponse.fromJson(res.data);

      await TokenStorage.saveTokens(
        accessToken: authRes.tokens.accessToken,
        refreshToken: authRes.tokens.refreshToken,
      );

      authState.setSession(authRes);
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
    authState.logout();
  }
}
