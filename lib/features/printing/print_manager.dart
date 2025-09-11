import 'bixolon_service.dart';
import 'print_models.dart';

/// PrintManager: fachada para imprimir tickets usando servicios concretos.
class PrintManager {
  final BixolonService _bixolon;

  PrintManager({BixolonService? bixolon}) : _bixolon = bixolon ?? BixolonService();

  Future<void> printItems(List<PrintItem> items) async {
    for (final item in items) {
      if (item is PrintText) {
        await _bixolon.printText(item.text);
      } else if (item is PrintQr) {
        await _bixolon.printQr(item.data);
      }
    }
  }
}
