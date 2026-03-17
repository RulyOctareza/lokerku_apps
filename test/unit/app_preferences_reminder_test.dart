import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lokerku_apps/data/services/app_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await AppPreferences.init();
  });

  setUp(() async {
    await AppPreferences.clearAll();
  });

  test('stores and clears a job reminder', () async {
    final reminder = DateTime(2026, 3, 17, 10, 45);
    expect(AppPreferences.getJobReminder(42), isNull);

    await AppPreferences.setJobReminder(42, reminder);
    final stored = AppPreferences.getJobReminder(42);
    expect(stored?.toIso8601String(), reminder.toIso8601String());

    await AppPreferences.setJobReminder(42, null);
    expect(AppPreferences.getJobReminder(42), isNull);
  });
}
