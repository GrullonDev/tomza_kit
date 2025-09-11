import 'package:equatable/equatable.dart';

/// Clase base para todas las fallas del dominio.
/// SRP: encapsula información de errores de la capa de dominio.
abstract class Failure extends Equatable {
  const Failure({required this.message, this.statusCode});

  /// Mensaje descriptivo de la falla.
  final String message;

  /// Código de estado HTTP asociado, si aplica.
  final int? statusCode;

  @override
  List<Object?> get props => <Object?>[message, statusCode];

  @override
  String toString() => '${runtimeType.toString()}(statusCode: $statusCode, message: $message)';
}

/// Falla que representa errores provenientes del servidor.
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

/// Falla que representa errores de conectividad de red.
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No hay conexión a internet'});
}

/// Falla que representa errores de acceso o escritura en caché.
class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Error en el almacenamiento local'});
}

/// Falla que representa errores de validación de datos.
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

/// Falla que representa errores de autenticación.
class AuthFailure extends Failure {
  const AuthFailure({super.message = 'Error de autenticación', super.statusCode});
}

/// Falla que representa errores de autorización.
class AuthorizationFailure extends Failure {
  const AuthorizationFailure({
    super.message = 'No tienes permisos para realizar esta acción',
    super.statusCode,
  });
}

/// Falla genérica para errores inesperados.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({super.message = 'Ha ocurrido un error inesperado'});
}

/// Falla que representa operaciones que exceden el tiempo límite.
class TimeoutFailure extends Failure {
  const TimeoutFailure({super.message = 'Tiempo de espera agotado'});
}

/// Falla que representa errores de formato en los datos.
class FormatFailure extends Failure {
  const FormatFailure({super.message = 'Formato de datos inválido'});
}

/// Utilidad para mapear excepciones de red/Dio a Failures.
class FailureMapper {
  static Failure fromNetworkException(Object error) {
    // Evitar dependencia circular directa; se evalúa por tipo/texto.
    final msg = error.toString();
    if (msg.contains('Timeout')) return const TimeoutFailure();
    if (msg.contains('Unauthorized') || msg.contains('401')) {
      return const AuthFailure(statusCode: 401);
    }
    if (msg.contains('403')) return const AuthorizationFailure(statusCode: 403);
    if (msg.contains('404')) return const ServerFailure(message: 'Recurso no encontrado', statusCode: 404);
    if (msg.contains('500')) return const ServerFailure(message: 'Error interno del servidor', statusCode: 500);
    return UnexpectedFailure(message: msg);
  }
}
