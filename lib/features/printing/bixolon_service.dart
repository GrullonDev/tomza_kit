/// BixolonService: stub de conexión/impresión para impresoras Bixolon.
library;

class BixolonService {
  Future<bool> connect({String? address}) async {
    // TODO: integrar con canal nativo o paquete específico.
    return true;
  }

  Future<void> printText(String text) async {}
  Future<void> printQr(String data) async {}
  Future<void> disconnect() async {}
}
