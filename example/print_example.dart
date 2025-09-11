import 'package:tomza_kit/tomza_kit.dart';

/// Ejemplo rápido no ejecutable directamente (usar main.dart) para imprimir.
Future<void> runPrintDemo() async {
  final manager = PrintManager();
  await manager.printItems([
    PrintText('Ticket #001'),
    PrintQr('https://example.com'),
  ]);
}
