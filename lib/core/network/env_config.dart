/// EnvConfig: configuración global de red para tomza_kit.
/// Debe inicializarse desde la app consumidora antes de primeras llamadas.
class EnvConfig {
  EnvConfig._internal({
    required this.baseUrl,
    required this.isDevelopment,
    required this.insecureSsl,
    required this.connectTimeout,
    required this.receiveTimeout,
    Map<String, String>? defaultHeaders,
  }) : defaultHeaders = defaultHeaders ?? const {};

  static EnvConfig? _instance;
  static EnvConfig get instance {
    final inst = _instance;
    if (inst == null) {
      throw StateError('EnvConfig no inicializado. Llama EnvConfig.initialize(...) antes.');
    }
    return inst;
  }

  final String baseUrl;
  final bool isDevelopment;
  final bool insecureSsl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Map<String, String> defaultHeaders;

  static void initialize({
    required String baseUrl,
    bool isDevelopment = false,
    bool insecureSsl = false,
    Duration connectTimeout = const Duration(seconds: 10),
    Duration receiveTimeout = const Duration(seconds: 15),
    Map<String, String>? defaultHeaders,
  }) {
    _instance = EnvConfig._internal(
      baseUrl: baseUrl,
      isDevelopment: isDevelopment,
      insecureSsl: insecureSsl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      defaultHeaders: defaultHeaders,
    );
  }
}
