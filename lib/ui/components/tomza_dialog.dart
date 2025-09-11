import 'package:flutter/material.dart';

class TomzaDialog extends StatelessWidget {
  final String title;
  final String message;
  final List<Widget>? actions;
  const TomzaDialog({super.key, required this.title, required this.message, this.actions});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: actions ?? [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
      ],
    );
  }
}
