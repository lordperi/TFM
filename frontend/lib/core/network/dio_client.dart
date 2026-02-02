import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/app_constants.dart';

// ==========================================
// DIO CLIENT WITH JWT INTERCEPTOR
// ==========================================

class DioClient {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  DioClient(this._secureStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add JWT Interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Exclude login and register from JWT header
          final publicEndpoints = [
            ApiConstants.login,
            ApiConstants.register,
            ApiConstants.health,
          ];

          final isPublicEndpoint = publicEndpoints.any(
            (endpoint) => options.path.contains(endpoint),
          );

          if (!isPublicEndpoint) {
            final token = await _secureStorage.read(key: StorageKeys.accessToken);
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          return handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 Unauthorized
          if (error.response?.statusCode == 401) {
            // TODO: Implement token refresh or logout
            await _secureStorage.delete(key: StorageKeys.accessToken);
          }
          return handler.next(error);
        },
      ),
    );

    // Add Logging Interceptor (Development only)
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        requestHeader: true,
        responseHeader: false,
      ),
    );
  }

  Dio get dio => _dio;
}
