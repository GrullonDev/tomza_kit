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
  /// [useDither]    : activa Floyd–Steinberg (mejor para fotos, peor para texto)
  /// [threshold]    : umbral 0..255 para conversión a B/N (180 es óptimo para texto)
  /// [appendCut]    : añade comando de corte al final
  static Uint8List pngToEscPosRaster(
    Uint8List png, {
    int maxDotsWidth = 576,
    int bandHeight = 256,
    bool useDither = false,
    int threshold = 180,
    bool appendCut = true,
  }) {
    try {
      final im.Image? decoded = im.decodeImage(png);
      if (decoded == null) {
        dev.log('[EscPosConverter] No se pudo decodificar PNG');
        return Uint8List(0);
      }

      dev.log(
        '[EscPosConverter] Imagen original: ${decoded.width}x${decoded.height}',
      );

      // 1) Resize al ancho máximo y asegurar múltiplo de 8
      int w = math.min(decoded.width, maxDotsWidth);
      w = w - (w % 8); // Redondear hacia abajo al múltiplo de 8 más cercano
      if (w < 8) {
        dev.log('[EscPosConverter] Ancho muy pequeño: $w');
        return Uint8List(0);
      }

      final int h = (decoded.height * (w / decoded.width)).round();

      dev.log('[EscPosConverter] Redimensionando a: ${w}x$h');

      final im.Image resized = im.copyResize(
        decoded,
        width: w,
        height: h,
        // Lanczos3 no está disponible, cubic es la mejor alternativa integrada
        interpolation: im.Interpolation.cubic,
      );

      // 2) Convertir a escala de grises
      final im.Image gray = im.grayscale(resized);

      // 3) Aumentar contraste para texto más nítido
      final im.Image contrasted = im.adjustColor(
        gray,
        contrast: 1.2, // Incrementar contraste
        brightness: 1.0,
      );

      // 4) Convertir a 1-bit (blanco y negro)
      final im.Image bw = useDither
          ? toMonoDitherFS(contrasted)
          : _toMonoThreshold(
              contrasted,
              threshold,
            ); // Umbral (mejor para texto)

      dev.log(
        '[EscPosConverter] Conversión a B/N: ${useDither ? "dithering" : "threshold=$threshold"}',
      );

      // 5) Construir comandos ESC/POS en bandas
      final BytesBuilder bytes = BytesBuilder();

      // Comandos de inicialización
      bytes.add(_escInit());
      bytes.add(_alignLeft());
      // Eliminado GS ! 0x00 para imágenes ya que no es necesario y ahorra bytes

      final int width = bw.width;
      final int height = bw.height;
      final int rowBytes = width ~/ 8; // width ya es múltiplo de 8

      dev.log(
        '[EscPosConverter] Procesando $height filas en bandas de $bandHeight',
      );

      int bandCount = 0;
      for (int y0 = 0; y0 < height; y0 += bandHeight) {
        final int yEnd = math.min(y0 + bandHeight, height);
        final int bandRows = yEnd - y0;

        final int xL = rowBytes & 0xFF;
        final int xH = (rowBytes >> 8) & 0xFF;
        final int yL = bandRows & 0xFF;
        final int yH = (bandRows >> 8) & 0xFF;

        // GS v 0 m - Comando de imagen raster
        // m=0: modo normal
        bytes.add(<int>[0x1D, 0x76, 0x30, 0x00, xL, xH, yL, yH]);

        // Datos de la banda: MSB=bit izquierdo, 1=negro
        for (int y = y0; y < yEnd; y++) {
          final Uint8List row = Uint8List(rowBytes);
          int byteIndex = 0;
          int bit = 7;

          for (int x = 0; x < width; x++) {
            final im.Pixel pixel = bw.getPixel(x, y);
            // En escala de grises: 0=negro, 255=blanco
            final bool isBlack = pixel.r == 0;
            if (isBlack) {
              row[byteIndex] |= (1 << bit);
            }
            if (--bit < 0) {
              bit = 7;
              byteIndex++;
            }
          }
          bytes.add(row);
        }

        bandCount++;
      }

      dev.log('[EscPosConverter] Procesadas $bandCount bandas');

      // 6) Alimentación y corte
      bytes.add(<int>[0x0A, 0x0A, 0x0A, 0x0A]);
      if (appendCut) {
        bytes.add(<int>[0x1D, 0x56, 0x00]);
      }

      final Uint8List result = bytes.toBytes();
      dev.log('[EscPosConverter] ✓ ESC/POS generado: ${result.length} bytes');

      return result;
    } catch (e, st) {
      dev.log('[EscPosConverter] Error: $e', error: e, stackTrace: st);
      return Uint8List(0);
    }
  }

  /// Conversión a monocromo usando umbral fijo (mejor para texto)
  /// Valores menores que threshold se convierten a negro (0)
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
        break;
      case 'right':
        bytes.add(_alignRight());
        break;
      default:
        bytes.add(_alignLeft());
        break;
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
        'finalWidth':
            math.min(decoded.width, maxDotsWidth) -
            (math.min(decoded.width, maxDotsWidth) % 8),
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
