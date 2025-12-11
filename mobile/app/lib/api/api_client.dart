import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config.dart';
import '../utils/token_storage.dart';
import './auth_service.dart';

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
          if (accessToken != null) {
            options.headers["Authorization"] = "Bearer $accessToken";
          }
          handler.next(options);
        },
        onError: (e, handler) async {
          if (e.response?.statusCode == 401) {
            final auth = AuthService();
            final success = await auth.refreshAccessToken();

            if (success) {
                // Retry original request with new access token
                final requestOptions = e.requestOptions;
                final newAccessToken = await _storage.read(key: "access_token");
                requestOptions.headers["Authorization"] = "Bearer $newAccessToken";

                final cloneReq = await dio.request(
                    requestOptions.path,
                    options: Options(
                    method: requestOptions.method,
                    headers: requestOptions.headers,
                    contentType: requestOptions.contentType,
                    ),
                    data: requestOptions.data,
                    queryParameters: requestOptions.queryParameters,
                );
                return handler.resolve(cloneReq);
            } else {
                // Refresh failed → user needs to log in again
                await TokenStorage.clearTokens();
            }
          }
          handler.next(e);
        },
      ),
    );
  }
}
