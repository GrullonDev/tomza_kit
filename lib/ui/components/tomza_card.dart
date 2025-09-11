import 'package:flutter/material.dart';

class TomzaCard extends StatelessWidget {
  final Widget child;
  const TomzaCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: child,
      ),
    );
  }
}
