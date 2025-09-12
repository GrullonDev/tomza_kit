// ignore_for_file: always_specify_types
import 'package:flutter/material.dart';

/// Botón primario general (fuera de autenticación) con estados de carga opcional.
enum AppButtonSize { dense, regular }

EdgeInsets _paddingFor(AppButtonSize size) {
  switch (size) {
    case AppButtonSize.dense:
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
    case AppButtonSize.regular:
      return const EdgeInsets.symmetric(horizontal: 20, vertical: 14);
  }
}

/// Botón primario general (fuera de autenticación) con estados de carga opcional.
class TomzaPrimaryButton extends StatelessWidget {
  const TomzaPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.expand = false,
    this.size = AppButtonSize.regular,
    this.minWidth,
    this.showLoadingLabel = false,
    this.loadingLabel = 'Cargando...',
  });
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool expand;
  final AppButtonSize size;
  final double? minWidth;
  final bool showLoadingLabel;
  final String loadingLabel;

  // Keys exposed for testing specific internal states without relying solely on widget tree order.
  static const Key spinnerKey = ValueKey('appPrimaryButton_spinner');
  static const Key loadingLabelKey = ValueKey('appPrimaryButton_loadingLabel');

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Widget text = Text(
      label,
      style: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onPrimary,
      ),
    );
    Widget child; // explicit type for analyzer
    if (isLoading) {
      final Widget spinner = SizedBox(
        key: spinnerKey,
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            theme.colorScheme.onPrimary,
          ),
        ),
      );
      if (showLoadingLabel) {
        child = Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            spinner,
            const SizedBox(width: 8),
            Text(
              loadingLabel,
              key: loadingLabelKey,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ],
        );
      } else {
        child = spinner;
      }
    } else if (icon != null) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 18, color: theme.colorScheme.onPrimary),
          const SizedBox(width: 8),
          text,
        ],
      );
    } else {
      child = text;
    }

    final ButtonStyle style = ElevatedButton.styleFrom(
      padding: _paddingFor(size),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );

    final ElevatedButton button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: style,
      child: child,
    );

    Widget wrapped = button; // explicit type for analyzer
    if (expand) {
      wrapped = SizedBox(width: double.infinity, child: wrapped);
    } else if (minWidth != null) {
      wrapped = ConstrainedBox(
        constraints: BoxConstraints(minWidth: minWidth!),
        child: wrapped,
      );
    }
    return wrapped;
  }
}

/// Botón secundario (gris / tonal) que mantiene jerarquía visual debajo del primario.
class TomzaSecondaryButton extends StatelessWidget {
  const TomzaSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expand = false,
    this.size = AppButtonSize.regular,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;
  final AppButtonSize size;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color bg = theme.colorScheme.surfaceContainerHighest;
    final Color fg = theme.colorScheme.onSurfaceVariant;
    final Widget text = Text(
      label,
      style: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: fg,
      ),
    );
    Widget child;
    if (icon != null) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: 8),
          text,
        ],
      );
    } else {
      child = text;
    }
    final ButtonStyle style = ElevatedButton.styleFrom(
      backgroundColor: bg,
      foregroundColor: fg,
      padding: _paddingFor(size),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 0,
    );
    final ElevatedButton button = ElevatedButton(
      onPressed: onPressed,
      style: style,
      child: child,
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Botón de texto plano con padding consistente.
class TomzaTextButton extends StatelessWidget {
  const TomzaTextButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.size = AppButtonSize.regular,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonSize size;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color fg = theme.colorScheme.primary;
    final Widget text = Text(
      label,
      style: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: fg,
      ),
    );
    Widget child;
    if (icon != null) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: 6),
          text,
        ],
      );
    } else {
      child = text;
    }
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(padding: _paddingFor(size)),
      child: child,
    );
  }
}
