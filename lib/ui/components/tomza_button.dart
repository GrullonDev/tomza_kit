import 'package:flutter/material.dart';

class TomzaButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const TomzaButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed, child: Text(label));
  }
}
