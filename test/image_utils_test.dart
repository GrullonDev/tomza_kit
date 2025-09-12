import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:tomza_kit/tomza_kit.dart';

void main() {
  test('imageToBase64 and base64ToImage roundtrip', () {
    final originalBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
    final base64 = ImageUtils.imageToBase64(originalBytes);
    final decodedBytes = ImageUtils.base64ToImage(base64);
    expect(decodedBytes, equals(originalBytes));
  });

  test('base64ToImage with invalid string throws', () {
    expect(() => ImageUtils.base64ToImage('invalid_base64'), throwsA(isA<FormatException>()));
  });
}
