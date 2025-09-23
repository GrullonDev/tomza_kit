import 'package:flutter/material.dart';

import 'package:tomza_kit/core/network/failures.dart';
import 'package:tomza_kit/utils/animated_snack_content.dart';

class ErrorNotifier {
  const ErrorNotifier._();

  /// Optional global key that the host app can set so ErrorNotifier
  /// can show SnackBars without a BuildContext.
  static GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;

  /// Optional custom show callback. If provided, it's used instead of
  /// internal SnackBar logic. Signature: (message, icon, color)
  static void Function(String message, IconData icon, Color color)? showCallback;

  /// Initialize the global key or custom callback from the host app.
  /// Example: ErrorNotifier.scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  /// and pass the key to MaterialApp.scaffoldMessengerKey.
  static void initialize({GlobalKey<ScaffoldMessengerState>? messengerKey, void Function(String, IconData, Color)? callback}) {
    scaffoldMessengerKey = messengerKey ?? scaffoldMessengerKey;
    showCallback = callback ?? showCallback;
  }

  static void showFailure(BuildContext? context, Failure failure) {
    final String msg = _mapFailureMessage(failure);
    final IconData icon = _mapFailureIcon(failure);
    final Color color = _resolveColor(context, (cs) => cs.error, Colors.red);
    _show(msg, icon: icon, color: color, context: context);
  }

  static void showInfo(BuildContext? context, String message) {
    final Color color = _resolveColor(context, (cs) => cs.primary, Colors.blue);
    _show(message, icon: Icons.info_outline, color: color, context: context);
  }

  static void showSuccess(BuildContext? context, String message) {
    final Color color = Colors.green;
    _show(message, icon: Icons.check_circle, color: color, context: context);
  }

  // Helper: resolve a color using the provided context's ColorScheme when
  // available, otherwise return the provided fallback color.
  static Color _resolveColor(BuildContext? context, Color Function(ColorScheme) pick, Color fallback) {
    if (context != null) {
      try {
        final ColorScheme cs = Theme.of(context).colorScheme;
        return pick(cs);
      } catch (_) {
        // ignore and return fallback
      }
    }
    return fallback;
  }

  static void _show(
    String message, {
    required IconData icon,
    required Color color,
    BuildContext? context,
  }) {
    // If a custom callback is provided, use it
    if (showCallback != null) {
      showCallback!(message, icon, color);
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

    // Prefer context if available and mounted
    if (context != null) {
      try {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(snack);
          return;
        }
      } catch (_) {}
    }

    // Fallback to global scaffoldMessengerKey if available
    if (scaffoldMessengerKey?.currentState != null) {
      scaffoldMessengerKey!.currentState!
        ..clearSnackBars()
        ..showSnackBar(snack);
      return;
    }

    // Last resort: print to console so host app devs can see the message
    // (avoids silent failure when neither context nor key are set).
    // This keeps library usage possible without forcing context usage.
    // ignore: avoid_print
    print('[TomzaKit] $message');
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
