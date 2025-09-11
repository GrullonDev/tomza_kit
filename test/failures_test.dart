import 'package:flutter_test/flutter_test.dart';
import 'package:tomza_kit/tomza_kit.dart';

void main() {
  test('Failure equality', () {
    const a = AuthFailure(message: 'Error de autenticación', statusCode: 401);
    const b = AuthFailure(message: 'Error de autenticación', statusCode: 401);
    expect(a, equals(b));
  });

  test('FailureMapper unauthorized', () {
    final f = FailureMapper.fromNetworkException('Unauthorized 401');
    expect(f, isA<AuthFailure>());
  });
}
