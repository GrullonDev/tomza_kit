import 'package:flutter_test/flutter_test.dart';
import 'package:tomza_kit/tomza_kit.dart';

void main() {
  test('PrintManager handles items', () async {
    final manager = PrintManager();
    await manager.printItems([PrintText('Hola'), PrintQr('DATA')]);
  });
}
