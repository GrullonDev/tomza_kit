/// Modelos de impresión.
library;

sealed class PrintItem {}

class PrintText extends PrintItem {
  final String text;
  PrintText(this.text);
}

class PrintQr extends PrintItem {
  final String data;
  PrintQr(this.data);
}
