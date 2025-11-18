import 'package:flutter/material.dart';

/// Tamaños disponibles para los botones.
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
    this.color,
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
  final Color? color;
  final Key spinnerKey = const ValueKey('appPrimaryButton_spinner');
  final Key loadingLabelKey = const ValueKey('appPrimaryButton_loadingLabel');

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color backgroundColor = color ?? theme.colorScheme.primary;
    final Color foregroundColor = theme.colorScheme.onPrimary;

    final Widget text = Text(
      label,
      style: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: foregroundColor,
      ),
    );

    Widget child;
    if (isLoading) {
      final Widget spinner = SizedBox(
        key: spinnerKey,
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
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
                color: foregroundColor,
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
          Icon(icon, size: 18, color: foregroundColor),
          const SizedBox(width: 8),
          text,
        ],
      );
    } else {
      child = text;
    }

    final ButtonStyle style = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      padding: _paddingFor(size),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );

    final ElevatedButton button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: style,
      child: child,
    );

    Widget wrapped = button;
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

/// Botón secundario (gris / tonal) con posibilidad de personalizar color.
class TomzaSecondaryButton extends StatelessWidget {
  const TomzaSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expand = false,
    this.size = AppButtonSize.regular,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;
  final AppButtonSize size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color backgroundColor = color ?? theme.colorScheme.secondary;
    final Color foregroundColor = color != null
        ? Colors.white
        : theme.colorScheme.onSecondary;

    final Widget text = Text(
      label,
      style: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: foregroundColor,
      ),
    );

    Widget child;
    if (icon != null) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 18, color: foregroundColor),
          const SizedBox(width: 8),
          text,
        ],
      );
    } else {
      child = text;
    }

    final ButtonStyle style = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
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

/// Botón de texto plano con color personalizable.
class TomzaTextButton extends StatelessWidget {
  const TomzaTextButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.size = AppButtonSize.regular,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonSize size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color foregroundColor = color ?? theme.colorScheme.primary;

    final Widget text = Text(
      label,
      style: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: foregroundColor,
      ),
    );

    Widget child;
    if (icon != null) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 18, color: foregroundColor),
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
