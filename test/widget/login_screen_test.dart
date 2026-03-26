import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lokerku_apps/core/constants/app_strings.dart';
import 'package:lokerku_apps/data/services/app_preferences.dart';
import 'package:lokerku_apps/features/auth/login_screen.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await AppPreferences.init();
  });

  setUp(() async {
    await AppPreferences.clearAll();
  });

  testWidgets('shows migration dialog and syncs local data after login', (
    WidgetTester tester,
  ) async {
    var synced = false;
    var completed = false;
    await AppPreferences.setGuestMode(true);

    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(
          signInAction: () async => const AuthenticatedUserData(
            displayName: 'Aji',
            email: 'aji@example.com',
            photoUrl: null,
          ),
          localJobCountLoader: () async => 3,
          localToCloudSyncAction: () async => synced = true,
          onLoginComplete: () async => completed = true,
        ),
      ),
    );

    await tester.tap(find.text(AppStrings.loginWithGoogle));
    await tester.pumpAndSettle();

    expect(find.text('Sinkronkan data lokal?'), findsOneWidget);
    expect(find.textContaining('3 data lamaran'), findsOneWidget);

    await tester.tap(find.text('Sync sekarang'));
    await tester.pumpAndSettle();

    expect(synced, isTrue);
    expect(completed, isTrue);
  });
}
