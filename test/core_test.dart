import 'package:flutter_test/flutter_test.dart';
import 'package:tomza_kit/tomza_kit.dart';

void main() {
  test('Auth sign in/out cycle', () async {
    final auth = InMemoryAuthService();
    expect(auth.isAuthenticated, isFalse);
    final ok = await auth.signIn(username: 'user', password: 'pass');
    expect(ok, isTrue);
    expect(auth.isAuthenticated, isTrue);
    await auth.signOut();
    expect(auth.isAuthenticated, isFalse);
  });
}
