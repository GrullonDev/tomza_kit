import 'package:flutter/material.dart';

import 'package:tomza_kit/core/network/failures.dart';
import 'package:tomza_kit/utils/animated_snack_content.dart';

class ErrorNotifier {
  const ErrorNotifier._();

  static void showFailure(BuildContext context, Failure failure) {
    final String msg = _mapFailureMessage(failure);
    final IconData icon = _mapFailureIcon(failure);
    final ColorScheme cs = Theme.of(context).colorScheme;
    _showSnack(context, msg, icon: icon, color: cs.error);
  }

  static void showInfo(BuildContext context, String message) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    _showSnack(context, message, icon: Icons.info_outline, color: cs.primary);
  }

  static void showSuccess(BuildContext context, String message) {
    _showSnack(context, message, icon: Icons.check_circle, color: Colors.green);
  }

  static void _showSnack(
    BuildContext context,
    String message, {
    required IconData icon,
    required Color color,
  }) {
    if (!context.mounted) {
      return;
    }
    final SnackBar snack = SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: color.withValues(alpha: 0.94),
      elevation: 5,
      content: AnimatedSnackContent(
        icon: icon,
        color: Colors.white,
        text: message,
      ),
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(snack);
  }

  static String _mapFailureMessage(Failure f) {
    if (f is NetworkFailure) {
      return f.message.isNotEmpty ? f.message : 'Sin conexión a internet';
    }
    if (f is TimeoutFailure) {
      return f.message;
    }
    if (f is AuthFailure) {
      return f.message.isNotEmpty ? f.message : 'Sesión expirada';
    }
    if (f is AuthorizationFailure) {
      return f.message.isNotEmpty ? f.message : 'Acceso denegado';
    }
    if (f is ValidationFailure) {
      return f.message.isNotEmpty ? f.message : 'Recurso no encontrado';
    }
    if (f is UnexpectedFailure) {
      return f.message;
    }
    if (f is FormatFailure) {
      return f.message;
    }
    if (f is ServerFailure) {
      return f.message.isNotEmpty ? f.message : 'Error de servidor';
    }
    return f.message;
  }

  static IconData _mapFailureIcon(Failure f) {
    if (f is NetworkFailure) {
      return Icons.wifi_off_rounded;
    }
    if (f is TimeoutFailure) {
      return Icons.timer_off_outlined;
    }
    if (f is AuthFailure) {
      return Icons.lock_outline;
    }
    if (f is AuthorizationFailure) {
      return Icons.block_rounded;
    }
    if (f is UnexpectedFailure) {
      return Icons.search_off_rounded;
    }
    if (f is FormatFailure) {
      return Icons.warning_amber_rounded;
    }
    if (f is ServerFailure) {
      return Icons.dns_rounded;
    }
    if (f is FormatFailure) {
      return Icons.description_outlined;
    }
    return Icons.error_outline;
  }
}

extension ErrorNotifierContext on BuildContext {
  void showFailure(Failure f) => ErrorNotifier.showFailure(this, f);
  void showInfo(String m) => ErrorNotifier.showInfo(this, m);
  void showSuccess(String m) => ErrorNotifier.showSuccess(this, m);
}
