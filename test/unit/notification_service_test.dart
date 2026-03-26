import 'package:flutter_test/flutter_test.dart';

import 'package:lokerku_apps/data/services/notification_service.dart';

void main() {
  test(
    'initialize does not throw when Firebase messaging is unavailable',
    () async {
      await expectLater(NotificationService().initialize(), completes);
    },
  );

  test('scheduleJobReminder does not throw', () async {
    await expectLater(
      NotificationService().scheduleJobReminder(
        10,
        'PT Contoh - Flutter Dev',
        DateTime(2026, 3, 26, 10, 0),
      ),
      completes,
    );
  });
}
