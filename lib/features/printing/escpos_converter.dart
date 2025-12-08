import 'dart:developer' as dev;
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as im;

/// Conversor de imágenes PNG a comandos ESC/POS para impresoras térmicas
/// Optimizado para impresoras Bixolon de 3 pulgadas (576 dots @ 203 DPI)
class EscPosConverter {
  /// Convierte PNG a bytes ESC/POS listos para enviar.
  ///
  /// [png]          : PNG bytes de entrada
  /// [maxDotsWidth] : ancho máximo imprimible (576 para Bixolon 3")
  /// [bandHeight]   : filas por banda (256 es óptimo para velocidad/memoria)
  /// Valores mayores o iguales se convierten a blanco (255)
  static im.Image _toMonoThreshold(im.Image g, int threshold) {
    final im.Image out = im.Image(
      width: g.width,
      height: g.height,
      numChannels: 1,
    );

    for (int y = 0; y < g.height; y++) {
      for (int x = 0; x < g.width; x++) {
        final im.Pixel pixel = g.getPixel(x, y);
        final num luminance = pixel.r;

        // Aplicar threshold con margen de error para evitar grises
        final int value = luminance < threshold ? 0 : 255;
        out.setPixelR(x, y, value);
      }
    }

    return out;
  }

  /// Floyd–Steinberg dithering para mejor detalle en fotos
  /// Distribuye el error de cuantización a píxeles vecinos
  static im.Image toMonoDitherFS(im.Image g) {
    final im.Image out = im.Image.from(g); // Crear copia

    // Aplicar dithering sobre el canal R (que contiene la escala de grises)
    for (int y = 0; y < out.height; y++) {
      for (int x = 0; x < out.width; x++) {
        final im.Pixel pixel = out.getPixel(x, y);
        final num oldL = pixel.r;

        // Cuantizar a 0 o 255
        final int newL = oldL < 128 ? 0 : 255;
        final num err = oldL - newL;

        out.setPixelR(x, y, newL);

        // Distribuir error a píxeles vecinos:
        //     X   7/16
        // 3/16 5/16 1/16
        addErr(out, x + 1, y, (err * 7) ~/ 16);
        addErr(out, x - 1, y + 1, (err * 3) ~/ 16);
        addErr(out, x, y + 1, (err * 5) ~/ 16);
        addErr(out, x + 1, y + 1, (err * 1) ~/ 16);
      }
    }

    return out;
  }

  /// Helper para agregar error de dithering a un píxel
  static void addErr(im.Image img, int x, int y, int v) {
    if (x < 0 || y < 0 || x >= img.width || y >= img.height) return;

    final num currentL = img.getPixel(x, y).r;
    final int newL = (currentL + v).clamp(0, 255) as int;
    img.setPixelR(x, y, newL);
  }

  // === Comandos ESC/POS básicos ===

  /// ESC @ - Inicializar impresora
  static List<int> _escInit() => <int>[0x1B, 0x40];

  /// ESC a 0 - Alinear a la izquierda
  static List<int> _alignLeft() => <int>[0x1B, 0x61, 0x00];

  /// ESC a 1 - Alinear al centro
  static List<int> _alignCenter() => <int>[0x1B, 0x61, 0x01];

  /// ESC a 2 - Alinear a la derecha
  static List<int> _alignRight() => <int>[0x1B, 0x61, 0x02];

  /// GS V m - Cortar papel
  /// m=0: Corte total
  /// m=1: Corte parcial (si la impresora lo soporta)
  static List<int> _cut({bool partial = false}) => <int>[
    0x1D,
    0x56,
    partial ? 0x01 : 0x00,
  ];

  /// LF - Line feed (nueva línea)
  static List<int> _lineFeed({int count = 1}) => List.filled(count, 0x0A);

  // === Métodos de utilidad adicionales ===

  /// Crear comando ESC/POS para imprimir texto plano
  static Uint8List textToEscPos(
    String text, {
    bool bold = false,
    bool underline = false,
    int fontSize = 0, // 0=normal, 1=2x height, 2=2x width, 3=2x both
    String alignment = 'left', // 'left', 'center', 'right'
    bool cut = true,
  }) {
    final BytesBuilder bytes = BytesBuilder();

    // Inicializar
    bytes.add(_escInit());

    // Alineación
    switch (alignment.toLowerCase()) {
      case 'center':
        bytes.add(_alignCenter());
      case 'right':
        bytes.add(_alignRight());
      default:
        bytes.add(_alignLeft());
    }

    // Negrita: ESC E 1
    if (bold) {
      bytes.add(<int>[0x1B, 0x45, 0x01]);
    }

    // Subrayado: ESC - 1
    if (underline) {
      bytes.add(<int>[0x1B, 0x2D, 0x01]);
    }

    // Tamaño: GS ! n
    if (fontSize > 0) {
      int n = 0;
      if (fontSize == 1 || fontSize == 3) n |= 0x01;
      if (fontSize == 2 || fontSize == 3) n |= 0x10;
      bytes.add(<int>[0x1D, 0x21, n]);
    }

    // Texto
    bytes.add(text.codeUnits);

    // Reset estilos
    if (bold) bytes.add(<int>[0x1B, 0x45, 0x00]);
    if (underline) bytes.add(<int>[0x1B, 0x2D, 0x00]);
    if (fontSize > 0) bytes.add(<int>[0x1D, 0x21, 0x00]);

    // Line feeds
    bytes.add(_lineFeed(count: 2));

    // Cortar
    if (cut) {
      bytes.add(_cut());
    }

    return bytes.toBytes();
  }

  /// Validar que la imagen cumpla con los requisitos de la impresora
  static Map<String, dynamic> validateImage(Uint8List png, int maxDotsWidth) {
    try {
      final im.Image? decoded = im.decodeImage(png);
      if (decoded == null) {
        return <String, dynamic>{
          'valid': false,
          'error': 'No se pudo decodificar la imagen',
        };
      }

      return <String, dynamic>{
        'valid': true,
        'width': decoded.width,
        'height': decoded.height,
        'willResize': decoded.width > maxDotsWidth,
        'finalWidth': math.min(decoded.width, maxDotsWidth),
        'finalHeight': decoded.width > maxDotsWidth
            ? (decoded.height * (maxDotsWidth / decoded.width)).round()
            : decoded.height,
      };
    } catch (e) {
      return <String, dynamic>{
        'valid': false,
        'error': 'Error validando imagen: $e',
      };
    }
  }
}
