import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lokerku_apps/data/services/app_preferences.dart';
import 'package:lokerku_apps/features/profile/profile_screen.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await AppPreferences.init();
  });

  setUp(() async {
    await AppPreferences.clearAll();
    await AppPreferences.setUserDisplayName('AJI');
    await AppPreferences.setUserEmail('aji@example.com');
  });

  testWidgets('saves selected gallery photo to preferences', (
    WidgetTester tester,
  ) async {
    final imagePath = '${Directory.current.path}/assets/images/app_icon.png';

    await tester.pumpWidget(
      MaterialApp(
        home: ProfileScreen(imagePickerAction: () async => imagePath),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.camera_alt));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(AppPreferences.userPhotoUrl, imagePath);
  });
}
