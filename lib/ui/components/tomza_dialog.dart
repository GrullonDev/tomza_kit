import 'package:flutter/material.dart';

enum CustomDialogType { error, warning, info, success }

class DialogAction {
  const DialogAction({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isPrimary = false,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isPrimary;
}

class CustomDialog extends StatelessWidget {
  const CustomDialog({
    super.key,
    required this.title,
    required this.description,
    required this.type,
    required this.onAccept,
    this.actions,
  });

  final String title;
  final String description;
  final CustomDialogType type;
  final VoidCallback onAccept;
  final List<DialogAction>? actions;

  IconData _getIcon() {
    switch (type) {
      case CustomDialogType.error:
        return Icons.error_outline;
      case CustomDialogType.warning:
        return Icons.warning_amber_rounded;
      case CustomDialogType.info:
        return Icons.info_outline;
      case CustomDialogType.success:
        return Icons.check_circle_outline;
    }
  }

  Color _baseColor(BuildContext context) {
    switch (type) {
      case CustomDialogType.error:
        return Colors.redAccent;
      case CustomDialogType.warning:
        return Colors.amber;
      case CustomDialogType.info:
        return Colors.lightBlue;
      case CustomDialogType.success:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = _baseColor(context);
    final muted = theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.75) ??
        (theme.brightness == Brightness.dark ? Colors.white70 : Colors.black54);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: base.withValues(alpha: 0.15),
              radius: 32,
              child: Icon(_getIcon(), color: base, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(color: muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (actions != null && actions!.isNotEmpty)
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: actions!.map((a) {
                  final child = a.icon != null
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(a.icon, size: 18),
                            const SizedBox(width: 8),
                            Text(a.label),
                          ],
                        )
                      : Text(a.label);
                  if (a.isPrimary) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: base,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: a.onPressed,
                      child: child,
                    );
                  }
                  return OutlinedButton(
                    onPressed: a.onPressed,
                    child: child,
                  );
                }).toList(),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onAccept,
                  child: const Text('Aceptar'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

