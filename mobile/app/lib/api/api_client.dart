import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_app/config.dart';
import 'package:mobile_app/utils/token_storage.dart';
import 'auth_service.dart';
import '../auth/auth_state.dart';

class ApiClient {
  // Singleton
  static ApiClient? _instance;
  factory ApiClient({required AuthState authState}) {
    _instance ??= ApiClient._internal(authState);
    return _instance!;
  }

  final AuthState authState;

  late final Dio dio;
  late final Dio refreshDio;

  static const _storage = FlutterSecureStorage();

  ApiClient._internal(this.authState) {
    // Main Dio (WITH interceptors)
    dio = Dio(
      BaseOptions(
        baseUrl: Config.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {"Content-Type": "application/json"},
      ),
    );

    // Refresh Dio (NO interceptors)
    refreshDio = Dio(
      BaseOptions(
        baseUrl: Config.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {"Content-Type": "application/json"},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onError: _onError,
      ),
    );
  }

  // --------------------
  // REQUEST INTERCEPTOR
  // --------------------
  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await _storage.read(key: "access_token");

    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers["Authorization"] = "Bearer $accessToken";
    }

    handler.next(options);
  }

  // --------------------
  // ERROR INTERCEPTOR
  // --------------------
  Future<void> _onError(
    DioException e,
    ErrorInterceptorHandler handler,
  ) async {
    // Only retry ONCE
    if (e.response?.statusCode == 401 &&
        e.requestOptions.extra["retried"] != true) {
      e.requestOptions.extra["retried"] = true;

      final authService = AuthService(authState: authState, api: this);
      final success = await authService.refreshAccessToken();

      if (success) {
        final newAccessToken = await _storage.read(key: "access_token");
        e.requestOptions.headers["Authorization"] = "Bearer $newAccessToken";

        final response = await dio.fetch(e.requestOptions);
        return handler.resolve(response);
      }

      // Refresh failed → logout
      await TokenStorage.clearTokens();
      authState.clear();
    }

    handler.next(e);
  }
}
