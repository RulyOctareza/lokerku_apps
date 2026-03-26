import 'package:flutter_test/flutter_test.dart';

import 'package:lokerku_apps/data/services/auth_service.dart';

void main() {
  test('auth getters stay safe when Firebase is unavailable', () {
    expect(() => AuthService.currentUser, returnsNormally);
    expect(() => AuthService.isLoggedIn, returnsNormally);
    expect(() => AuthService.userId, returnsNormally);
    expect(() => AuthService.displayName, returnsNormally);
    expect(() => AuthService.email, returnsNormally);
    expect(() => AuthService.photoUrl, returnsNormally);
  });

  test('auth state changes returns a safe stream', () async {
    expect(() => AuthService.authStateChanges, returnsNormally);
    await expectLater(AuthService.authStateChanges, emitsDone);
  });
}
