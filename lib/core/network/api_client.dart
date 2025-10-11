import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import 'env_config.dart';
import 'network_exceptions.dart';

typedef Json = Map<String, dynamic>;

class ApiClient {
  ApiClient._();
  static Dio? _dio;

  static Future<bool> Function(Object error)? unauthorizedHandler;

  static void registerUnauthorizedHandler(
    Future<bool> Function(Object error)? handler,
  ) {
    unauthorizedHandler = handler;
  }

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
        onError: (e, handler) async {
          try {
            final status = e.response?.statusCode;
            if (status == 401 && unauthorizedHandler != null) {
              await unauthorizedHandler!(e);
            }
          } catch (_) {}
          handler.next(e);
        },
      ),
    );

    _dio = dio;
    return dio;
  }

  static void reset() {
    _dio = null;
  }

  // Métodos HTTP genéricos --------------------------------------------------
  static Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
  }) async {
    try {
      return await _client.get<T>(
        path,
        data: data,
        queryParameters: query,
        options: headers == null
            ? null
            : Options(headers: {..._client.options.headers, ...headers}),
      );
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  static Future<Response<T>> post<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
  }) async {
    try {
      return await _client.post<T>(
        path,
        data: body,
        queryParameters: query,
        options: headers == null
            ? null
            : Options(headers: {..._client.options.headers, ...headers}),
      );
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  static Future<Response<T>> put<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
  }) async {
    try {
      return await _client.put<T>(
        path,
        data: body,
        queryParameters: query,
        options: headers == null
            ? null
            : Options(headers: {..._client.options.headers, ...headers}),
      );
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  static Future<Response<T>> delete<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
  }) async {
    try {
      return await _client.delete<T>(
        path,
        data: body,
        queryParameters: query,
        options: headers == null
            ? null
            : Options(headers: {..._client.options.headers, ...headers}),
      );
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }
}

// Helpers --------------------------------------------------------------------
String _composeUrl(RequestOptions o) {
  final b = o.baseUrl;
  final p = o.path;
  if (p.startsWith('http')) return p;
  if (b.endsWith('/') && p.startsWith('/')) return b + p.substring(1);
  if (!b.endsWith('/') && !p.startsWith('/')) return '$b/$p';
  return '$b$p';
}

String? _extractSnippet(dynamic data, {int max = 600}) {
  if (data == null) return null;
  try {
    if (data is String) {
      return data.length > max
          ? '${data.substring(0, max)}...<truncated>'
          : data;
    }
    final s = jsonEncode(data);
    return s.length > max ? '${s.substring(0, max)}...<truncated>' : s;
  } catch (_) {
    final s = data.toString();
    return s.length > max ? '${s.substring(0, max)}...<truncated>' : s;
  }
}

NetworkException _mapDioError(DioException e) {
  final status = e.response?.statusCode;
  final method = e.requestOptions.method;
  final url = _composeUrl(e.requestOptions);
  final reason = e.message ?? '';
  final serverMsg = _extractSnippet(e.response?.data);

  final msg =
      '[$method $url] '
      'status=${status ?? "n/a"} '
      'type=${e.type} '
      '${reason.isNotEmpty ? "reason=$reason " : ""}'
      '${serverMsg != null ? "server=${serverMsg.replaceAll("\n", " ")}" : ""}';

  switch (status) {
    case 400:
      return NetworkException.badRequest(msg);
    case 401:
      return NetworkException.unauthorized();
    case 403:
      return NetworkException.forbidden();
    case 404:
      return NetworkException.notFound();
    case 408:
      return NetworkException.timeout(msg);
    case 500:
      return NetworkException.server(msg);
  }

  // Tipos sin status (muy útiles para saber qué pasó)
  if (e.type == DioExceptionType.connectionTimeout) {
    return NetworkException.timeout('Connection timeout: $msg');
  }
  if (e.type == DioExceptionType.sendTimeout) {
    return NetworkException.timeout('Send timeout: $msg');
  }
  if (e.type == DioExceptionType.receiveTimeout) {
    return NetworkException.timeout('Receive timeout: $msg');
  }
  if (e.type == DioExceptionType.badCertificate) {
    return NetworkException('Bad certificate: $msg');
  }
  if (e.type == DioExceptionType.connectionError) {
    return NetworkException('Connection error: $msg');
  }
  if (e.type == DioExceptionType.cancel) {
    return NetworkException('Request cancelled: $msg');
  }
  if (e.type == DioExceptionType.badResponse) {
    return NetworkException('Bad response: $msg');
  }

  return NetworkException('Error de red: $msg');
}
