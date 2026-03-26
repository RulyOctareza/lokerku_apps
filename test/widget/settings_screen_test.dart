import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lokerku_apps/data/services/app_preferences.dart';
import 'package:lokerku_apps/features/settings/settings_screen.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await AppPreferences.init();
  });

  testWidgets('does not throw when disposed before storage size loads', (
    WidgetTester tester,
  ) async {
    final completer = Completer<int>();

    await tester.pumpWidget(
      MaterialApp(
        home: SettingsScreen(storageSizeLoader: () => completer.future),
      ),
    );

    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));

    completer.complete(1024);
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('adapts profile card on compact screens without overflow', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await AppPreferences.setUserDisplayName(
      'Nama User Yang Sangat Panjang Untuk Layar Kecil',
    );
    await AppPreferences.setUserEmail(
      'alamat.email.panjang.sekali@exampledomain.com',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: SettingsScreen(storageSizeLoader: _compactStorageLoader),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edit Profil'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<int> _compactStorageLoader() async => 1024;
