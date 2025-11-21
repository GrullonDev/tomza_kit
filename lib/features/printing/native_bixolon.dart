import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/services.dart';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:image/image.dart' as im;

import 'package:tomza_kit/core/network/api_client.dart';
import 'package:tomza_kit/features/printing/escpos_converter.dart';

/// Bridge para comunicarse con el SDK nativo de Bixolon en Android
///
/// Asegúrate de tener implementados los métodos en tu MainActivity.kt o
/// en un plugin personalizado que use el SDK de Bixolon
/// (bixolon_printer_V2.2.8.jar y libcommon_V1.3.9.jar)
class NativeBixolon {
  static const MethodChannel _channel = MethodChannel('com.tomza/bixolon');

  static Future<List<int>?> renderPdfToPrinterBytes(String filePath) async {
    try {
      dev.log('[NativeBixolon] renderPdfToPrinterBytes: $filePath');

      final String? res = await _channel.invokeMethod<String>(
        'printPdfWithBixolon',
        <String, String>{'path': filePath},
      );

      if (res == null) {
        dev.log('[NativeBixolon] renderPdfToPrinterBytes retornó null');
        return null;
      }

      final Uint8List decoded = base64Decode(res);
      dev.log('[NativeBixolon] ✓ Bytes renderizados: ${decoded.length}');
      return decoded;
    } catch (e, st) {
      dev.log(
        '[NativeBixolon] renderPdfToPrinterBytes error: $e',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  static Future<List<int>?> renderPdfToPrinterBytesWithOptions(
    String filePath,
    Json options,
  ) async {
    try {
      dev.log('[NativeBixolon] renderPdfToPrinterBytesWithOptions: $filePath');
      dev.log('[NativeBixolon] Options: $options');

      final res = await _channel.invokeMethod<dynamic>(
        'printPdfWithOptions',
        <String, Object>{'path': filePath, 'options': options},
      );

      if (res == null) {
        dev.log(
          '[NativeBixolon] renderPdfToPrinterBytesWithOptions retornó null',
        );
        return null;
      }

      if (res is Map) {
        final String? encoded =
            (res['encoded'] as String?) ?? (res['encodedBase64'] as String?);
        if (encoded != null) {
          final Uint8List decoded = base64Decode(encoded);
          dev.log(
            '[NativeBixolon] ✓ Bytes renderizados (Map): ${decoded.length}',
          );
          return decoded;
        }

        dev.log('[NativeBixolon] Map sin campo encoded: $res');
        return null;
      }

      if (res is String) {
        try {
          final Uint8List decoded = base64Decode(res);
          dev.log(
            '[NativeBixolon] ✓ Bytes renderizados (String): ${decoded.length}',
          );
          return decoded;
        } catch (e) {
          dev.log('[NativeBixolon] Error decodificando String: $e');
          return null;
        }
      }

      dev.log(
        '[NativeBixolon] Tipo de respuesta inesperado: ${res.runtimeType}',
      );
      return null;
    } catch (e, st) {
      dev.log(
        '[NativeBixolon] renderPdfToPrinterBytesWithOptions error: $e',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  static Future<Json?> printPdfNative(String filePath) async {
    try {
      dev.log('[NativeBixolon] printPdfNative: $filePath');

      final res = await _channel.invokeMethod<dynamic>(
        'printPdfNative',
        <String, String>{'path': filePath},
      );

      if (res == null) {
        dev.log('[NativeBixolon] printPdfNative retornó null');
        return null;
      }

      if (res is Map) {
        final Map<String, dynamic> result = Json.from(
          res.cast<String, dynamic>(),
        );
        dev.log('[NativeBixolon] printPdfNative result: $result');
        return result;
      }

      dev.log(
        '[NativeBixolon] printPdfNative tipo inesperado: ${res.runtimeType}',
      );
      return <String, dynamic>{
        'success': false,
        'message': 'unexpected native response',
      };
    } catch (e, st) {
      dev.log(
        '[NativeBixolon] printPdfNative error: $e',
        error: e,
        stackTrace: st,
      );
      return <String, dynamic>{'success': false, 'message': 'exception: $e'};
    }
  }

  static Future<Json?> printPdfWithOptions(
    String filePath,
    Json options,
  ) async {
    try {
      dev.log('[NativeBixolon] printPdfWithOptions: $filePath');
      dev.log('[NativeBixolon] Options: $options');

      final res = await _channel.invokeMethod<dynamic>(
        'printPdfWithOptions',
        <String, Object>{'path': filePath, 'options': options},
      );

      if (res == null) {
        dev.log('[NativeBixolon] printPdfWithOptions retornó null');
        return null;
      }
      if (res is Map) {
        final Map<String, dynamic> result = Json.from(
          res.cast<String, dynamic>(),
        );
        dev.log('[NativeBixolon] printPdfWithOptions result: $result');
        return result;
      }
      if (res is String) {
        dev.log('[NativeBixolon] printPdfWithOptions retornó String (bytes)');
        return <String, dynamic>{
          'success': true,
          'message': 'bytes returned',
          'encodedBase64': res,
        };
      }
      dev.log(
        '[NativeBixolon] printPdfWithOptions tipo inesperado: ${res.runtimeType}',
      );

      return <String, dynamic>{
        'success': false,
        'message': 'unexpected native response',
      };
    } catch (e, st) {
      dev.log(
        '[NativeBixolon] printPdfWithOptions error: $e',
        error: e,
        stackTrace: st,
      );

      return <String, dynamic>{'success': false, 'message': 'exception: $e'};
    }
  }

  static Future<Uint8List?> convertPdfToImage(
    String filePath, {
    Json? options,
  }) async {
    try {
      dev.log('[NativeBixolon] convertPdfToImage: $filePath');
      dev.log('[NativeBixolon] Options: $options');
      final Uint8List? res = await _channel.invokeMethod<Uint8List>(
        'convertPdfToImage',
        <String, Object?>{'path': filePath, 'options': options},
      );
      if (res == null) {
        dev.log('[NativeBixolon] convertPdfToImage returned null');
        return null;
      }
      dev.log('[NativeBixolon] ✓ Image converted: ${res.length} bytes');
      return res;
    } catch (e, st) {
      dev.log(
        '[NativeBixolon] convertPdfToImage error: $e',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  static Future<Json?> printPdfToBixolonOverBt(
    String filePath,
    String address, {
    Json? options,
  }) async {
    try {
      final Map<String, dynamic> merged = <String, dynamic>{
        'dpi': 203,
        'paperWidthInches': 3.0,
        // 'printWidth': 576,
        // 'alignment': 'left',
        // 'scaleMode': 'fit_width',
        // 'scale': 1.0,
        'threshold': 215,
        // 'dither': 'floyd',
        'gamma': 1.10,
        // 'sharpen': 0.10,
      };
      if (options != null) merged.addAll(options);
      dev.log('[NativeBixolon] BT opts => $merged');

      final res = await _channel.invokeMethod<dynamic>(
        'bixolonPrintPdfBluetooth',
        <String, Object>{
          'path': filePath,
          'address': address,
          'options': merged,
        },
      );
      if (res is Map) {
        return Json.from(res.cast<String, dynamic>());
      }
      return <String, dynamic>{
        'success': false,
        'message': 'unexpected native response',
      };
    } catch (e, st) {
      dev.log(
        '[NativeBixolon] bixolonPrintPdfBluetooth error: $e',
        error: e,
        stackTrace: st,
      );
      return <String, dynamic>{'success': false, 'message': 'exception: $e'};
    }
  }

  /// Convierte el PDF a imagen (nativo) y envía esa imagen a la impresora por Bluetooth
  /// usando comandos ESC/POS raster.
  static Future<Json?> printPdfAsImageOverBt(
    String filePath,
    String address, {
    Json? options,
  }) async {
    try {
      dev.log('[NativeBixolon] printPdfAsImageOverBt: $filePath -> $address');

      // 1) Convertir PDF a imagen PNG en nativo (usa los mismos options de tamaño/calidad)
      final Uint8List? png = await convertPdfToImage(
        filePath,
        options: options,
      );
      if (png == null || png.isEmpty) {
        return <String, dynamic>{
          'success': false,
          'message': 'conversion to image failed',
        };
      }

      // 2) Convertir PNG a bytes ESC/POS raster
      final int threshold = (options?['threshold'] as int?) ?? 215;
      final int maxDotsWidth = (options?['printWidth'] as int?) ?? 576;
      final bool useDither = (() {
        final d = options?['dither'];
        if (d is String) return d.toLowerCase() == 'floyd';
        return false;
      })();

      final Uint8List escpos = EscPosConverter.pngToEscPosRaster(
        png,
        maxDotsWidth: maxDotsWidth,
        threshold: threshold,
        useDither: useDither,
      );
      if (escpos.isEmpty) {
        return <String, dynamic>{
          'success': false,
          'message': 'failed to build ESC/POS payload',
        };
      }

      // 3) Enviar por Bluetooth usando flutter_bluetooth_serial (chunking para evitar overflow)
      final int chunkSize = (options?['chunkSize'] as int?) ?? 256;
      final int delayMs = (options?['interChunkDelayMs'] as int?) ?? 20;

      final bool ok = await _sendBt(
        address,
        escpos,
        chunkSize: chunkSize,
        delayMs: delayMs,
      );
      return <String, dynamic>{
        'success': ok,
        'message': ok ? 'sent' : 'bt send failed',
      };
    } catch (e, st) {
      dev.log(
        '[NativeBixolon] printPdfAsImageOverBt error: $e',
        error: e,
        stackTrace: st,
      );
      return <String, dynamic>{'success': false, 'message': 'exception: $e'};
    }
  }

  static Future<bool> _sendBt(
    String address,
    Uint8List payload, {
    int chunkSize = 256,
    int delayMs = 20,
  }) async {
    BluetoothConnection? connection;
    try {
      connection = await BluetoothConnection.toAddress(address);

      int offset = 0;
      while (offset < payload.length) {
        final int end = (offset + chunkSize) < payload.length
            ? (offset + chunkSize)
            : payload.length;
        final Uint8List slice = payload.sublist(offset, end);
        connection.output.add(slice);
        await connection.output.allSent;
        await Future.delayed(Duration(milliseconds: delayMs));
        offset = end;
      }

      // Feed 3 lines al final (ESC d n)
      connection.output.add(Uint8List.fromList(<int>[0x1B, 0x64, 0x03]));
      await connection.output.allSent;

      await Future.delayed(const Duration(milliseconds: 150));

      try {
        await connection.finish();
      } catch (_) {}
      try {
        await connection.close();
      } catch (_) {}
      return true;
    } catch (e, st) {
      dev.log('[NativeBixolon] _sendBt error: $e', error: e, stackTrace: st);
      try {
        await connection?.finish();
      } catch (_) {}
      try {
        await connection?.close();
      } catch (_) {}
      return false;
    }
  }

  static Future<Json?> printTextOverBt(
    String address, {
    required String text,
    Json? options,
  }) async {
    try {
      final res = await _channel.invokeMethod<dynamic>(
        'bixolonPrintTextBluetooth',
        <String, Object>{
          'address': address,
          'text': text,
          'options': <String, dynamic>{
            'codePage': 'CP1252',
            'lineSpacing': -1,
            'bold': false,
            'doubleWidth': false,
            'doubleHeight': false,
            'align': 'left',
            'feedEnd': 3,
            ...?options,
          },
        },
      );
      if (res is Map) return Json.from(res);
      return <String, dynamic>{
        'success': false,
        'message': 'unexpected native response',
      };
    } catch (e, st) {
      dev.log('[NativeBixolon] printTextOverBt error: $e', stackTrace: st);
      return <String, dynamic>{'success': false, 'message': 'exception: $e'};
    }
  }

  static Future<bool> cancelPrint() async {
    try {
      dev.log('[NativeBixolon] cancelPrint');

      final bool? res = await _channel.invokeMethod<bool>('cancelPrint');
      final bool success = res == true;

      dev.log('[NativeBixolon] cancelPrint result: $success');
      return success;
    } catch (e, st) {
      dev.log(
        '[NativeBixolon] cancelPrint error: $e',
        error: e,
        stackTrace: st,
      );
      return false;
    }
  }

  static Future<Json?> printTextAsImageOverBt(
    String address, {
    required String text,
    Json? options,
  }) async {
    try {
      final res = await _channel.invokeMethod<dynamic>(
        'bixolonPrintTextImageBluetooth',
        <String, Object>{
          'address': address,
          'text': text,
          'options': <String, dynamic>{
            'maxDotsWidth': 576,
            'fontSize': 22.0,
            'lineHeight': 28,
            'bold': false,
            'align': 'left',
            'leftPad': 0,
            'rightPad': 0,
            'topPad': 0,
            'bottomPad': 0,
            ...?options,
          },
        },
      );
      if (res is Map) return Json.from(res);
      return <String, dynamic>{
        'success': false,
        'message': 'unexpected native response',
      };
    } catch (e, st) {
      dev.log(
        '[NativeBixolon] printTextAsImageOverBt error: $e',
        error: e,
        stackTrace: st,
      );
      return <String, dynamic>{'success': false, 'message': 'exception: $e'};
    }
  }

  static Future<Json?> getSdkInfo() async {
    try {
      dev.log('[NativeBixolon] getSdkInfo');

      final res = await _channel.invokeMethod<dynamic>('getSdkInfo');

      if (res == null) return null;

      if (res is Map) {
        return Json.from(res.cast<String, dynamic>());
      }

      return null;
    } catch (e, st) {
      dev.log('[NativeBixolon] getSdkInfo error: $e', error: e, stackTrace: st);
      return null;
    }
  }

  static Future<bool> isSdkAvailable() async {
    try {
      dev.log('[NativeBixolon] Verificando disponibilidad del SDK');

      final bool? res = await _channel.invokeMethod<bool>('isSdkAvailable');
      final bool available = res == true;

      dev.log('[NativeBixolon] SDK disponible: $available');
      return available;
    } catch (e) {
      dev.log('[NativeBixolon] SDK no disponible: $e');
      return false;
    }
  }

  static Future<String?> testConnection() async {
    try {
      dev.log('[NativeBixolon] testConnection');

      final String? res = await _channel.invokeMethod<String>('testConnection');

      dev.log('[NativeBixolon] testConnection result: $res');
      return res;
    } catch (e, st) {
      dev.log(
        '[NativeBixolon] testConnection error: $e',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  static im.Image ditherFloydSteinberg(im.Image src) {
    return EscPosConverter.toMonoDitherFS(src);
  }
}
