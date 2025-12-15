import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_app/api/auth_service.dart';
import 'package:mobile_app/config.dart';
import 'package:mobile_app/utils/token_storage.dart';

class ApiClient {
  late final Dio dio;
  static const _storage = FlutterSecureStorage();

  ApiClient() {
    dio = Dio(BaseOptions(
      baseUrl: Config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        "Content-Type": "application/json",
      },
    ));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final accessToken = await _storage.read(key: "access_token");
          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers["Authorization"] = "Bearer $accessToken";
          }
          handler.next(options);
        },
        onError: (e, handler) async {
          if (e.response?.statusCode == 401) {
            final auth = AuthService();
            final success = await auth.refreshAccessToken();

            if (success) {
              final requestOptions = e.requestOptions;
              final newAccessToken = await _storage.read(key: "access_token");
              requestOptions.headers["Authorization"] =
                  "Bearer $newAccessToken";

              final cloneReq = await dio.fetch(requestOptions);
              return handler.resolve(cloneReq);
            } else {
              await TokenStorage.clearTokens();
              // Let the calling code know login is required
              return handler.next(e);
            }
          }
          handler.next(e);
        },
      ),
    );
  }
}
