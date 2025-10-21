import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'env_config.dart';
import 'network_exceptions.dart';

typedef Json = Map<String, dynamic>;

class ApiClient {
  ApiClient._();

  static Dio? _dio;

  /// Handler opcional para manejar 401 centralizadamente (refresh/logout).
  static Future<bool> Function(Object error)? unauthorizedHandler;

  /// Callbacks opcionales para integrarte con tu store (AuthTokenStore, etc.).
  static String? Function()? _tokenProvider;
  static Future<void> Function(String token)? _tokenSaver;

  static void registerUnauthorizedHandler(
    Future<bool> Function(Object error)? handler,
  ) {
    unauthorizedHandler = handler;
  }

  static void registerTokenAccess({
    String? Function()? getToken,
    Future<void> Function(String token)? saveToken,
  }) {
    _tokenProvider = getToken;
    _tokenSaver = saveToken;
  }

  // -------------------- Cliente Dio --------------------
  static Dio get _client {
    final cfg = EnvConfig.instance;
    if (_dio != null) return _dio!;

    final options = BaseOptions(
      baseUrl: cfg.baseUrl,
      connectTimeout: cfg.connectTimeout,
      receiveTimeout: cfg.receiveTimeout,
      headers: {
        ...cfg.defaultHeaders,
        'Content-Type': 'application/json',
      },
      responseType: ResponseType.json,
    );

    final dio = Dio(options);

    // TLS flexible en dev o si se fuerza insecureSsl
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
        onRequest: (options, handler) {
          // Inyectar Authorization si tenemos token y no viene ya.
          final t = _tokenProvider?.call();
          if (t != null && t.isNotEmpty) {
            final hasAuth = options.headers.keys.any(
              (k) => k.toLowerCase() == 'authorization',
            );
            if (!hasAuth) {
              options.headers['Authorization'] =
                  t.startsWith('Bearer ') ? t : 'Bearer $t';
            }
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          // Captura de token desde headers/body si corresponde
          try {
            final hdrs = _normalizeHeaders(response.headers);
            _tryCaptureTokenFromHeaders(hdrs);
            final data = response.data;
            if (data is Map<String, dynamic>) {
              _tryCaptureTokenFromBody(data);
            } else if (data is String) {
              try {
                final parsed = jsonDecode(data);
                if (parsed is Map<String, dynamic>) {
                  _tryCaptureTokenFromBody(parsed);
                }
              } catch (_) {}
            }
          } catch (_) {}
          handler.next(response);
        },
        onError: (e, handler) async {
          try {
            if (e.response?.statusCode == 401 && unauthorizedHandler != null) {
              await unauthorizedHandler!(e);
            }
          } catch (_) {}
          handler.next(e);
        },
      ),
    );

    if (cfg.isDevelopment) {
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          logPrint: (obj) => debugPrint(obj.toString()),
        ),
      );
    }

    _dio = dio;
    return dio;
  }

  /// Si cambias entorno/baseUrl/headers globales, llama a reset().
  static void reset() {
    _dio = null;
  }

  // -------------------- Métodos HTTP --------------------

  static Future<Response<T>> get<T>(
    String endpoint, {
    Object? data,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    Set<int> acceptableStatusCodes = const {200},
  }) async {
    try {
      final req = _resolveRequest(endpoint);
      final resp = await _client.get<T>(
        req.pathForDio,
        data: data,
        queryParameters: query,
        options: _mergeHeaders(headers),
      );
      _ensureAcceptable(resp, acceptableStatusCodes);
      return resp;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  static Future<Response<T>> post<T>(
    String endpoint, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    Set<int> acceptableStatusCodes = const {200},
    bool enableAndroidRenegotiationFallback = true,
  }) async {
    final req = _resolveRequest(endpoint);
    try {
      final resp = await _client.post<T>(
        req.pathForDio,
        data: body,
        queryParameters: query,
        options: _mergeHeaders(headers),
      );
      _ensureAcceptable(resp, acceptableStatusCodes);
      return resp;
    } on DioException catch (e) {
      // Fallback nativo si está habilitado por EnvConfig y la app lo solicita
      final cfg = EnvConfig.instance;
      if (_shouldDoNativeFallback(e) &&
          cfg.enableNativeFallback &&
          enableAndroidRenegotiationFallback &&
          Platform.isAndroid) {
        final raw = await _nativePost(
          fullUrl: req.fullUrlWithQuery(query),
          headers: _finalHeaders(headers),
          body: body,
        );
        return Response<T>(
          requestOptions: RequestOptions(path: req.pathForDio),
          statusCode: 200,
          data: raw as T,
        );
      }
      throw _mapDioError(e);
    }
  }

  static Future<Response<T>> postList<T>(
    String endpoint, {
    required List<dynamic> listBody,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    Set<int> acceptableStatusCodes = const {200},
    bool enableAndroidRenegotiationFallback = true,
  }) {
    return post<T>(
      endpoint,
      body: listBody,
      query: query,
      headers: headers,
      acceptableStatusCodes: acceptableStatusCodes,
      enableAndroidRenegotiationFallback: enableAndroidRenegotiationFallback,
    );
  }

  static Future<dynamic> postRaw(
    String endpoint, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    Set<int> acceptableStatusCodes = const {200},
    bool tryLowercaseFallback = false,
    bool enableAndroidRenegotiationFallback = true,
    dynamic Function(dynamic raw)? responseTransform,
  }) async {
    try {
      final r = await post<dynamic>(
        endpoint,
        body: body,
        query: query,
        headers: headers,
        acceptableStatusCodes: acceptableStatusCodes,
        enableAndroidRenegotiationFallback:
            enableAndroidRenegotiationFallback,
      );
      final raw = r.data;
      if (responseTransform != null) return responseTransform(raw);
      return raw;
    } on NetworkException {
      if (tryLowercaseFallback && endpoint != endpoint.toLowerCase()) {
        return postRaw(
          endpoint.toLowerCase(),
          body: body,
          query: query,
          headers: headers,
          acceptableStatusCodes: acceptableStatusCodes,
          tryLowercaseFallback: false,
          enableAndroidRenegotiationFallback:
              enableAndroidRenegotiationFallback,
          responseTransform: responseTransform,
        );
      }
      rethrow;
    }
  }

  static Future<Response<T>> put<T>(
    String endpoint, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    Set<int> acceptableStatusCodes = const {200},
  }) async {
    try {
      final req = _resolveRequest(endpoint);
      final resp = await _client.put<T>(
        req.pathForDio,
        data: body,
        queryParameters: query,
        options: _mergeHeaders(headers),
      );
      _ensureAcceptable(resp, acceptableStatusCodes);
      return resp;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  static Future<Response<T>> delete<T>(
    String endpoint, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    Set<int> acceptableStatusCodes = const {200, 204},
  }) async {
    try {
      final req = _resolveRequest(endpoint);
      final resp = await _client.delete<T>(
        req.pathForDio,
        data: body,
        queryParameters: query,
        options: _mergeHeaders(headers),
      );
      _ensureAcceptable(resp, acceptableStatusCodes);
      return resp;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  static Future<dynamic> getRaw(
    String endpoint, {
    Object? data,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    Set<int> acceptableStatusCodes = const {200},
  }) async {
    final r = await get<dynamic>(
      endpoint,
      data: data,
      query: query,
      headers: headers,
      acceptableStatusCodes: acceptableStatusCodes,
    );
    return r.data;
  }

  // -------------------- Helpers internos --------------------

  static Options? _mergeHeaders(Map<String, String>? headers) {
    if (headers == null || headers.isEmpty) return null;
    final merged = {
      ..._client.options.headers.map((k, v) => MapEntry(k.toString(), v)),
      ...headers,
    };
    return Options(headers: merged);
  }

  static Map<String, String> _finalHeaders(Map<String, String>? headers) {
    final merged = <String, String>{};
    _client.options.headers.forEach((k, v) {
      if (v != null) merged[k.toString()] = v.toString();
    });
    if (headers != null) merged.addAll(headers);
    merged.putIfAbsent('Content-Type', () => 'application/json');

    // Inyectar Authorization si falta
    final t = _tokenProvider?.call();
    if (t != null && t.isNotEmpty) {
      final hasAuth = merged.keys.any((k) => k.toLowerCase() == 'authorization');
      if (!hasAuth) {
        merged['Authorization'] = t.startsWith('Bearer ') ? t : 'Bearer $t';
      }
    }
    return merged;
  }

  static void _ensureAcceptable<T>(
    Response<T> resp,
    Set<int> acceptableStatusCodes,
  ) {
    final sc = resp.statusCode ?? 0;
    if (!acceptableStatusCodes.contains(sc)) {
      final text = _extractSnippet(resp.data);
      throw NetworkException.badRequest(
        'HTTP ${resp.requestOptions.method} ${_composeUrl(resp.requestOptions)} '
        'status=$sc body=${text ?? "<vacío>"}',
      );
    }
  }

  static bool _shouldDoNativeFallback(DioException e) {
    final msg = (e.message ?? '').toUpperCase();
    return msg.contains('NO_RENEGOTIATION') || msg.contains('RENEGOTIATION');
  }

  static MethodChannel _methodChannelFromEnv(EnvConfig cfg) {
    // No hardcodeamos nada: si está habilitado, el canal debe venir por EnvConfig.
    final name = cfg.nativeChannelName;
    if (!cfg.enableNativeFallback || name == null || name.trim().isEmpty) {
      throw const NetworkException(
        'Fallback nativo habilitado pero nativeChannelName no está configurado en EnvConfig.',
      );
    }
    return MethodChannel(name);
  }

  /// Fallback nativo Android: realiza un POST con MethodChannel.
  /// Espera JSON en texto y lo parsea a Map<String, dynamic>.
  static Future<Map<String, dynamic>> _nativePost({
    required String fullUrl,
    required Map<String, String> headers,
    Object? body,
  }) async {
    final cfg = EnvConfig.instance;
    final channel = _methodChannelFromEnv(cfg);

    final String payload;
    if (body == null) {
      payload = '{}';
    } else if (body is String) {
      payload = body;
    } else {
      payload = jsonEncode(body);
    }

    final result = await channel.invokeMethod<String>(
      'nativePost',
      <String, dynamic>{
        'url': fullUrl,
        'headers': headers,
        'body': payload,
      },
    );

    if (result == null || result.isEmpty) {
      throw const NetworkException('Respuesta nativa vacía');
    }
    final decoded = jsonDecode(result);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is String) return jsonDecode(decoded) as Map<String, dynamic>;
    return Map<String, dynamic>.from(decoded as Map);
  }
}

// -------------------- Utilidades compartidas --------------------

class _ResolvedRequest {
  _ResolvedRequest(this._endpoint);

  final String _endpoint;

  bool get isAbsolute =>
      _endpoint.startsWith('http://') || _endpoint.startsWith('https://');

  String get pathForDio {
    if (!isAbsolute) return _cleanRelative(_endpoint);
    try {
      final uri = Uri.parse(_endpoint);
      return _cleanRelative(uri.path);
    } catch (_) {
      return _endpoint;
    }
  }

  String fullUrlWithQuery(Map<String, dynamic>? query) {
    if (isAbsolute) {
      final uri = Uri.parse(_endpoint);
      return uri.replace(
        queryParameters: {
          ...uri.queryParameters,
          if (query != null)
            ...query.map((k, v) => MapEntry(k, v?.toString() ?? '')),
        },
      ).toString();
    }
    final base = EnvConfig.instance.baseUrl;
    final baseClean = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    final path = _cleanRelative(_endpoint);
    final uri = Uri.parse('$baseClean/$path').replace(
      queryParameters: query?.map((k, v) => MapEntry(k, v?.toString() ?? '')),
    );
    return uri.toString();
  }

  String _cleanRelative(String input) =>
      input.startsWith('/') ? input.substring(1) : input;
}

_ResolvedRequest _resolveRequest(String endpoint) => _ResolvedRequest(endpoint);

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
      return data.length > max ? '${data.substring(0, max)}...<truncated>' : data;
    }
    final s = jsonEncode(data);
    return s.length > max ? '${s.substring(0, max)}...<truncated>' : s;
  } catch (_) {
    final s = data.toString();
    return s.length > max ? '${s.substring(0, max)}...<truncated>' : s;
  }
}

Map<String, List<String>> _normalizeHeaders(Headers hdrs) {
  final out = <String, List<String>>{};
  hdrs.map.forEach((k, v) {
    out[k] = v.map((e) => e.toString()).toList();
  });
  return out;
}

void _tryCaptureTokenFromHeaders(Map<String, List<String>> headers) {
  const candidates = <String>[
    'authorization',
    'Authorization',
    'x-token',
    'X-Token',
    'x-auth-token',
    'X-Auth-Token',
    'token',
    'Token',
    'set-cookie',
    'Set-Cookie',
  ];
  for (final key in candidates) {
    final values = headers[key];
    if (values == null || values.isEmpty) continue;
    final raw = values.first.trim();
    if (raw.isEmpty) continue;

    String toSave = raw;
    if ((key.toLowerCase() == 'set-cookie' || key.toLowerCase() == 'cookie') &&
        raw.toLowerCase().contains('token=')) {
      final parts = raw.split(';');
      for (final p in parts) {
        final kv = p.split('=');
        if (kv.length == 2 && kv[0].trim().toLowerCase() == 'token') {
          toSave = kv[1].trim();
          break;
        }
      }
    }
    ApiClient._tokenSaver?.call(toSave);
    return;
  }
}

void _tryCaptureTokenFromBody(Map<String, dynamic> body) {
  const bodyKeys = [
    'token',
    'access_token',
    'accessToken',
    'jwt',
    'authorization',
  ];
  for (final k in bodyKeys) {
    if (!body.containsKey(k)) continue;
    final v = body[k];
    if (v is String && v.isNotEmpty) {
      ApiClient._tokenSaver?.call(v);
      return;
    }
    if (v is Map<String, dynamic>) {
      for (final k2 in bodyKeys) {
        final vv = v[k2];
        if (vv is String && vv.isNotEmpty) {
          ApiClient._tokenSaver?.call(vv);
          return;
        }
      }
    }
  }
}

NetworkException _mapDioError(DioException e) {
  final status = e.response?.statusCode;
  final method = e.requestOptions.method;
  final url = _composeUrl(e.requestOptions);
  final reason = e.message ?? '';
  final serverMsg = _extractSnippet(e.response?.data);

  final msg = '[$method $url] '
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
