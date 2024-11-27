import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/core/config.dart';
import 'package:event_bus/event_bus.dart';

// Eventos de autenticación
abstract class AuthEvent {}
class AuthExpiredEvent extends AuthEvent {}
class AuthErrorEvent extends AuthEvent {
  final String message;
  AuthErrorEvent(this.message);
}

class ApiClient {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  final EventBus eventBus;
  bool _isRefreshing = false;
  bool _shouldRefresh = true;

  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal()
      : _dio = Dio(BaseOptions(
          baseUrl: Config.apiUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          validateStatus: (status) {
            return status != null && status < 500;
          },
        )),
        _secureStorage = const FlutterSecureStorage(),
        eventBus = EventBus() {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.clear();
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _handleRequest,
        onResponse: _handleResponse,
        onError: _handleError,
      ),
    );
  }

  Future<void> _handleRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await _secureStorage.read(key: 'authToken');
      if (token != null) {
        if (await _shouldRefreshToken(token)) {
          await _refreshToken();
          final newToken = await _secureStorage.read(key: 'authToken');
          if (newToken != null) {
            options.headers['Authorization'] = 'Bearer $newToken';
          }
        } else {
          options.headers['Authorization'] = 'Bearer $token';
        }
      }

      _logRequest(options);
      return handler.next(options);
    } catch (e) {
      _logError(DioException(
        requestOptions: options,
        error: e.toString(),
      ));
      return handler.next(options);
    }
  }

  void _handleResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    _logResponse(response);
    return handler.next(response);
  }

  Future<void> _handleError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_shouldRefresh) {
      return handler.next(error);
    }

    if (error.response?.statusCode == 401) {
      if (_isRefreshing) {
        await _waitForRefresh();
        return _retryRequest(error, handler);
      }

      final refreshed = await _refreshToken();
      if (refreshed) {
        return _retryRequest(error, handler);
      } else {
        await _handleRefreshFailure();
      }
    }

    _logError(error);
    return handler.next(error);
  }

  Future<bool> _shouldRefreshToken(String token) async {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;

      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      
      final expiry = DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);
      final now = DateTime.now();
      
      // Refrescar si faltan menos de 5 minutos
      return expiry.difference(now).inMinutes < 5;
    } catch (e) {
      print('Error al decodificar token: $e');
      return false;
    }
  }

  Future<void> _waitForRefresh() async {
    var attempts = 0;
    while (_isRefreshing && attempts < 5) {
      await Future.delayed(const Duration(milliseconds: 200));
      attempts++;
    }
  }

  Future<void> _retryRequest(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      final newToken = await _secureStorage.read(key: 'authToken');
      if (newToken == null) {
        return handler.next(error);
      }

      final response = await _retry(error.requestOptions);
      handler.resolve(response);
    } catch (e) {
      handler.next(error);
    }
  }

  Future<bool> _refreshToken() async {
    if (_isRefreshing) {
      print('Ya se está refrescando el token, esperando...');
      return false;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await _secureStorage.read(key: 'refreshToken');
      if (refreshToken == null) {
        print('No se encontró el refresh token');
        return false;
      }

      final refreshDio = Dio(BaseOptions(
        baseUrl: Config.apiUrl,
        validateStatus: (status) => status != null && status < 500,
      ));

      final response = await refreshDio.post(
        '/api/auth/refresh-token',
        options: Options(
          headers: {
            'Authorization': 'Bearer $refreshToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final newAccessToken = response.data['access_token'];
        
        if (newAccessToken != null) {
          await _secureStorage.write(
            key: 'authToken',
            value: newAccessToken,
          );
          print('Token refrescado exitosamente');
          return true;
        }
      }

      print('Fallo al refrescar el token: ${response.statusCode}');
      return false;

    } catch (e) {
      print('Error al refrescar el token: $e');
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _handleRefreshFailure() async {
    _shouldRefresh = false;
    await _secureStorage.delete(key: 'authToken');
    await _secureStorage.delete(key: 'refreshToken');
    eventBus.fire(AuthExpiredEvent());
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final token = await _secureStorage.read(key: 'authToken');
    
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $token',
      },
    );

    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  Future<void> storeTokens(Map<String, dynamic> tokens) async {
    if (tokens['access_token'] != null) {
      await _secureStorage.write(
        key: 'authToken',
        value: tokens['access_token'],
      );
    }
    if (tokens['refresh_token'] != null) {
      await _secureStorage.write(
        key: 'refreshToken',
        value: tokens['refresh_token'],
      );
    }
  }

  void _logRequest(RequestOptions options) {
    print('''
    🌐 Request:
    Method: ${options.method}
    URL: ${options.baseUrl}${options.path}
    Headers: ${options.headers}
    Data: ${options.data}
    Query Parameters: ${options.queryParameters}
    ''');
  }

  void _logResponse(Response response) {
    print('''
    ✅ Response:
    Status: ${response.statusCode}
    URL: ${response.requestOptions.baseUrl}${response.requestOptions.path}
    Data: ${response.data}
    ''');
  }

  void _logError(DioException error) {
    print('''
    ❌ Error:
    Status: ${error.response?.statusCode}
    URL: ${error.requestOptions.baseUrl}${error.requestOptions.path}
    Message: ${error.message}
    Data: ${error.response?.data}
    ''');
  }

  // Métodos públicos HTTP
  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<dynamic>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<dynamic>> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // Limpieza de recursos
  void dispose() {
    _dio.close(force: true);
    eventBus.destroy();
  }
}
