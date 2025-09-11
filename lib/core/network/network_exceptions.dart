/// Excepciones de red estandarizadas.
library;

class NetworkException implements Exception {
  final String message;
  final int? code;

  NetworkException(this.message, {this.code});

  factory NetworkException.badRequest([String msg = 'Bad Request']) =>
      NetworkException(msg, code: 400);
  factory NetworkException.unauthorized([String msg = 'Unauthorized']) =>
      NetworkException(msg, code: 401);
  factory NetworkException.forbidden([String msg = 'Forbidden']) =>
      NetworkException(msg, code: 403);
  factory NetworkException.notFound([String msg = 'Not Found']) =>
      NetworkException(msg, code: 404);
  factory NetworkException.timeout([String msg = 'Timeout']) =>
      NetworkException(msg, code: 408);
  factory NetworkException.server([String msg = 'Server Error']) =>
      NetworkException(msg, code: 500);

  @override
  String toString() => 'NetworkException(code: $code, message: $message)';
}
