// api_client.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import 'env_config.dart';
import 'network_exceptions.dart';

typedef Json = Map<String, dynamic>;

class ApiClient {
  ApiClient._();

  // ---------------- Configuración / inyección ----------------
  static Dio? _dio;

  /// Handler opcional para manejar 401 centralizadamente (refresh/logout).
  static Future<bool> Function(Object error)? unauthorizedHandler;

  /// Callbacks para integración con tu store de tokens (AuthTokenStore, etc.)
  static String? Function()? _tokenProvider;
  static Future<void> Function(String token)? _tokenSaver;

  // Fallback nativo Android (configurable desde la app; NO depende de EnvConfig)
  static bool _nativeFallbackEnabled = false;
  static String? _nativeChannelName;

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

  /// Activa/desactiva el fallback nativo y define el channel.
  /// Si [enable] es true, debes pasar [channelName].
  static void configureNativeFallback({
    required bool enable,
    String? channelName,
  }) {
    _nativeFallbackEnabled = enable;
    _nativeChannelName = channelName;
    if (enable && (channelName == null || channelName.trim().isEmpty)) {
      throw ArgumentError(
        'Para habilitar el fallback nativo debes proporcionar un native channel name.',
      );
    }
  }

  // ---------------- Cliente Dio ----------------
  static Dio get _client {
    final cfg = EnvConfig.instance;
    if (_dio != null) return _dio!;

    final options = BaseOptions(
      baseUrl: cfg.baseUrl,
      connectTimeout: cfg.connectTimeout,
      receiveTimeout: cfg.receiveTimeout,
      headers: {...cfg.defaultHeaders, 'Content-Type': 'application/json'},
      responseType: ResponseType.json,
    );

    final dio = Dio(options);

    // TLS flexible en dev / insecure
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
          final t = _tokenProvider?.call();
          if (t != null && t.isNotEmpty) {
            final hasAuth = options.headers.keys.any(
              (k) => k.toLowerCase() == 'authorization',
            );
            if (!hasAuth) {
              options.headers['Authorization'] = t.startsWith('Bearer ')
                  ? t
                  : 'Bearer $t';
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

  // ---------------- Métodos HTTP -> SIEMPRE Map<String, dynamic> / List<Json> ----------------

  /// GET que garantiza Map<String, dynamic>.
  /// Por defecto solo acepta status 200 (puedes pasar acceptableStatusCodes para otro comportamiento).
  static Future<Json> getJson(
    String endpoint, {
    Object? data,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    Set<int> acceptableStatusCodes = const {200},
  }) async {
    try {
      final req = _resolveRequest(endpoint);
      final resp = await _client.get<dynamic>(
        req.pathForDio,
        data: data,
        queryParameters: query,
        options: _mergeHeaders(headers),
      );
      _ensureAcceptable(resp, acceptableStatusCodes);
      return _asJson(resp.data, resp);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  /// POST que garantiza Map<String, dynamic>. Incluye fallback nativo opcional.
  /// Por defecto solo acepta status 200.
  static Future<Json> postJson(
    String endpoint, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    Set<int> acceptableStatusCodes = const {200},
    bool enableAndroidRenegotiationFallback = true,
  }) async {
    final req = _resolveRequest(endpoint);
    try {
      final resp = await _client.post<dynamic>(
        req.pathForDio,
        data: body,
        queryParameters: query,
        options: _mergeHeaders(headers),
      );
      _ensureAcceptable(resp, acceptableStatusCodes);
      return _asJson(resp.data, resp);
    } on DioException catch (e) {
      // Fallback nativo Android si está habilitado localmente
      if (_shouldDoNativeFallback(e) &&
          _nativeFallbackEnabled &&
          enableAndroidRenegotiationFallback &&
          Platform.isAndroid) {
        final raw = await _nativePost(
          fullUrl: req.fullUrlWithQuery(query),
          headers: _finalHeaders(headers),
          body: body,
        );

        // Native fallback devuelve Map o lanza; asumimos que el fallback ya devolvió Map válido.
        return raw;
        // Si no es un Map, lanzar para mantener la regla "solo 200 -> success"
        throw NetworkException.badRequest('Respuesta nativa inesperada');
      }
      throw _mapDioError(e);
    }
  }

  /// POST con cuerpo de lista (array JSON raíz) y respuesta List<Json>.
  /// Por defecto solo acepta status 200.
  // static Future<List<Json>> postListJson(
  //   String endpoint, {
  //   required List<dynamic> listBody,
  //   Map<String, dynamic>? query,
  //   Map<String, String>? headers,
  //   Set<int> acceptableStatusCodes = const {200},
  //   bool enableAndroidRenegotiationFallback = true,
  // }) async {
  //   final req = _resolveRequest(endpoint);
  //   try {
  //     final resp = await _client.post<dynamic>(
  //       req.pathForDio,
  //       data: listBody,
  //       queryParameters: query,
  //       options: _mergeHeaders(headers),
  //     );
  //     _ensureAcceptable(resp, acceptableStatusCodes);
  //     return _asJsonList(resp.data, resp);
  //   } on DioException catch (e) {
  //     if (_shouldDoNativeFallback(e) &&
  //         _nativeFallbackEnabled &&
  //         enableAndroidRenegotiationFallback &&
  //         Platform.isAndroid) {
  //       final raw = await _nativePost(
  //         fullUrl: req.fullUrlWithQuery(query),
  //         headers: _finalHeaders(headers),
  //         body: listBody,
  //       );

  //       if (raw is List) {
  //         return raw.map<Json>((e) {
  //           if (e is Map<String, dynamic>) return e;
  //           if (e is Map) return _toStringKeyedMap(e);
  //           throw NetworkException.badRequest(
  //             'Elemento de array no es un objeto JSON. Recibido ${e.runtimeType}',
  //           );
  //         }).toList();
  //       }

  //       throw NetworkException.badRequest('Respuesta nativa inesperada');
  //     }
  //     throw _mapDioError(e);
  //   }
  // }

  /// PUT que garantiza Map<String, dynamic>.
  /// Por defecto solo acepta status 200.
  static Future<Json> putJson(
    String endpoint, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    Set<int> acceptableStatusCodes = const {200},
  }) async {
    try {
      final req = _resolveRequest(endpoint);
      final resp = await _client.put<dynamic>(
        req.pathForDio,
        data: body,
        queryParameters: query,
        options: _mergeHeaders(headers),
      );
      _ensureAcceptable(resp, acceptableStatusCodes);
      return _asJson(resp.data, resp);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  /// DELETE que garantiza Map<String, dynamic>. Para 204 devuelve {}.
  /// Por defecto acepta 200 y 204.
  static Future<Json> deleteJson(
    String endpoint, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    Set<int> acceptableStatusCodes = const {200, 204},
  }) async {
    try {
      final req = _resolveRequest(endpoint);
      final resp = await _client.delete<dynamic>(
        req.pathForDio,
        data: body,
        queryParameters: query,
        options: _mergeHeaders(headers),
      );
      _ensureAcceptable(resp, acceptableStatusCodes);
      if ((resp.statusCode ?? 0) == 204 || resp.data == null) {
        return <String, dynamic>{};
      }
      return _asJson(resp.data, resp);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  // ---------------- Helpers ----------------

  /// Convierte la respuesta esperada a Map<String,dynamic>.
  /// Lanza NetworkException.badRequest si no se puede convertir o si la respuesta está vacía.
  static Json _asJson(dynamic data, Response resp) {
    try {
      if (data == null) {
        throw NetworkException.badRequest(
          'Respuesta vacía (status=${resp.statusCode})',
        );
      }
      if (data is Map<String, dynamic>) return data;

      if (data is String) {
        final trimmed = data.trim();
        if (trimmed.isEmpty) {
          throw NetworkException.badRequest(
            'Respuesta vacía (status=${resp.statusCode})',
          );
        }
        final parsed = jsonDecode(trimmed);
        if (parsed is Map<String, dynamic>) return parsed;
        throw NetworkException.badRequest(
          'Se esperaba objeto JSON. String decodifica a ${parsed.runtimeType}',
        );
      }

      if (data is Map) {
        return _toStringKeyedMap(data);
      }

      throw NetworkException.badRequest(
        'Se esperaba objeto JSON (Map). Recibido ${data.runtimeType}',
      );
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw NetworkException.badRequest(
        'No se pudo parsear la respuesta a Map<String,dynamic>: $e',
      );
    }
  }

  /// Helper: convierte cualquier Map (dynamic) a Map<String, dynamic>
  /// evitando el uso directo de .map(...) que puede confundir al analyzer.
  static List<Json> _asJsonList(dynamic data, Response resp) {
    try {
      if (data == null) {
        throw NetworkException.badRequest(
          'Respuesta vacía (status=${resp.statusCode})',
        );
      }

      List<dynamic> rawList;
      if (data is List) {
        rawList = data;
      } else if (data is String) {
        final trimmed = data.trim();
        if (trimmed.isEmpty) {
          throw NetworkException.badRequest(
            'Respuesta vacía (status=${resp.statusCode})',
          );
        }
        final parsed = jsonDecode(trimmed);
        if (parsed is List) {
          rawList = parsed;
        } else {
          throw NetworkException.badRequest(
            'Se esperaba array JSON, se obtuvo ${parsed.runtimeType}',
          );
        }
      } else {
        throw NetworkException.badRequest(
          'Se esperaba array JSON, recibido ${data.runtimeType}',
        );
      }

      return rawList.map<Json>((e) {
        if (e is Map<String, dynamic>) return e;
        if (e is Map) return _toStringKeyedMap(e);
        throw NetworkException.badRequest(
          'Elemento de array no es un objeto JSON. Recibido ${e.runtimeType}',
        );
      }).toList();
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw NetworkException.badRequest(
        'No se pudo parsear la respuesta a List<Map>: $e',
      );
    }
  }

  /// Convierte cualquier Map (posible dynamic) a Map<String, String>.
  /// Útil para queryParameters y para Uri.replace(queryParameters: ...).
  Map<String, String> _stringifyToStringMap(Map? maybeMap) {
    final out = <String, String>{};
    if (maybeMap == null) return out;
    try {
      // Si ya es Map<String, String> retorna copia.
      if (maybeMap is Map<String, String>) {
        return Map<String, String>.from(maybeMap);
      }
      // Si es Map<String, dynamic> o Map<dynamic, dynamic>
      maybeMap.forEach((k, v) {
        final key = k?.toString() ?? '';
        final value = v == null ? '' : v.toString();
        out[key] = value;
      });
    } catch (_) {
      // En caso de error devolvemos map vacío (no lanzar para no romper la URI builder).
    }
    return out;
  }

  /// Convierte cualquier Map (posible dynamic) a Map<String, dynamic>.
  /// Útil para normalizar headers u objetos JSON que pueden tener claves no-String.
  static Map<String, dynamic> _toStringKeyedMap(dynamic maybeMap) {
    final out = <String, dynamic>{};
    if (maybeMap is Map<String, dynamic>) {
      return Map<String, dynamic>.from(maybeMap);
    }
    if (maybeMap is Map) {
      maybeMap.forEach((k, v) {
        final key = k?.toString() ?? '';
        out[key] = v;
      });
    }
    return out;
  }

  static Options? _mergeHeaders(Map<String, String>? headers) {
    if (headers == null || headers.isEmpty) return null;

    // Construir merged a mano a partir de _client.options.headers
    final merged = <String, dynamic>{};
    try {
      final original = _client.options.headers;
      if (original != null) {
        original.forEach((k, v) {
          final key = k.toString();
          if (v != null) merged[key] = v;
        });
      }
    } catch (_) {}

    // Añadir/overrides desde headers param
    merged.addAll(headers);

    return Options(headers: merged);
  }

  static Map<String, String> _finalHeaders(Map<String, String>? headers) {
    final merged = <String, String>{};

    // Copiar headers del cliente (pueden ser dynamic)
    try {
      final clientHeaders = _client.options.headers;
      if (clientHeaders != null) {
        clientHeaders.forEach((k, v) {
          if (v != null) merged[k.toString()] = v.toString();
        });
      }
    } catch (_) {}

    if (headers != null) merged.addAll(headers);
    merged.putIfAbsent('Content-Type', () => 'application/json');

    final t = _tokenProvider?.call();
    if (t != null && t.isNotEmpty) {
      final hasAuth = merged.keys.any(
        (k) => k.toLowerCase() == 'authorization',
      );
      if (!hasAuth) {
        merged['Authorization'] = t.startsWith('Bearer ') ? t : 'Bearer $t';
      }
    }

    return merged;
  }

  /// Revisa que el status code esté en acceptableStatusCodes.
  /// Si no está, extrae un snippet del body y lanza NetworkException.badRequest con contexto.
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

  // ---------------- Fallback nativo Android ----------------

  static bool _shouldDoNativeFallback(DioException e) {
    final msg = (e.message ?? '').toUpperCase();
    return msg.contains('NO_RENEGOTIATION') || msg.contains('RENEGOTIATION');
  }

  static Future<Json> _nativePost({
    required String fullUrl,
    required Map<String, String> headers,
    Object? body,
  }) async {
    if (!_nativeFallbackEnabled ||
        _nativeChannelName == null ||
        _nativeChannelName!.trim().isEmpty) {
      throw NetworkException(
        'Fallback nativo está deshabilitado o el channel no fue configurado.',
      );
    }

    final String payload;
    if (body == null) {
      payload = '{}';
    } else if (body is String) {
      payload = body;
    } else {
      payload = jsonEncode(body);
    }

    final channel = MethodChannel(_nativeChannelName!);
    final result = await channel.invokeMethod<String>(
      'nativePost',
      <String, dynamic>{'url': fullUrl, 'headers': headers, 'body': payload},
    );

    if (result == null || result.isEmpty) {
      throw NetworkException('Respuesta nativa vacía');
    }
    final decoded = jsonDecode(result);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is String) {
      final inner = jsonDecode(decoded);
      if (inner is Map<String, dynamic>) return inner;
      return _toStringKeyedMap(inner);
    }
    return _toStringKeyedMap(decoded);
  }
}

// ---------------- Utilidades compartidas ----------------

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
      return uri
          .replace(
            queryParameters: {
              ...uri.queryParameters,
              if (query != null)
                ...query.map((k, v) => MapEntry(k, v?.toString() ?? '')),
            },
          )
          .toString();
    }
    final base = EnvConfig.instance.baseUrl;
    final baseClean = base.endsWith('/')
        ? base.substring(0, base.length - 1)
        : base;
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
