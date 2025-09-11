import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import 'env_config.dart';
import 'network_exceptions.dart';

typedef Json = Map<String, dynamic>;

/// ApiClient: wrapper sobre Dio con configuración centralizada.
class ApiClient {
  ApiClient._();
  static Dio? _dio;

  static Dio get _client {
    final cfg = EnvConfig.instance;
    if (_dio != null) return _dio!;

    final options = BaseOptions(
      baseUrl: cfg.baseUrl,
      connectTimeout: cfg.connectTimeout,
      receiveTimeout: cfg.receiveTimeout,
      headers: {...cfg.defaultHeaders, 'Content-Type': 'application/json'},
    );
    final dio = Dio(options);

    // TLS flexible en desarrollo.
    dio.httpClientAdapter = IOHttpClientAdapter()
      ..createHttpClient = () {
        final client = HttpClient();
        if (cfg.isDevelopment || cfg.insecureSsl) {
          client.badCertificateCallback = (cert, host, port) => true;
        }
        return client;
      };

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) => handler.next(options),
  onResponse: (response, handler) => handler.next(response),
        onError: (e, handler) => handler.next(e),
      ),
    );

    _dio = dio;
    return dio;
  }

  /// Limpia la instancia (por ejemplo cambio de baseUrl dinámico).
  static void reset() {
    _dio = null;
  }

  // Métodos HTTP genéricos --------------------------------------------------
  static Future<Response<T>> get<T>(String path, {Map<String, dynamic>? query}) async {
    try {
      return await _client.get<T>(path, queryParameters: query);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  static Future<Response<T>> post<T>(String path, {Object? body, Map<String, dynamic>? query}) async {
    try {
      return await _client.post<T>(path, data: body, queryParameters: query);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  static Future<Response<T>> put<T>(String path, {Object? body}) async {
    try {
      return await _client.put<T>(path, data: body);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  static Future<Response<T>> delete<T>(String path, {Object? body}) async {
    try {
      return await _client.delete<T>(path, data: body);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }
}

// Helpers --------------------------------------------------------------------
NetworkException _mapDioError(DioException e) {
  final status = e.response?.statusCode;
  switch (status) {
    case 400:
      return NetworkException.badRequest(e.message ?? 'Bad Request');
    case 401:
      return NetworkException.unauthorized();
    case 403:
      return NetworkException.forbidden();
    case 404:
      return NetworkException.notFound();
    case 408:
      return NetworkException.timeout();
    case 500:
      return NetworkException.server();
  }
  if (e.type == DioExceptionType.connectionTimeout) {
    return NetworkException.timeout('Connection timeout');
  }
  if (e.type == DioExceptionType.receiveTimeout) {
    return NetworkException.timeout('Receive timeout');
  }
  return NetworkException(e.message ?? 'Error de red');
}


