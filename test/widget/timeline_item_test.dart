import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lokerku_apps/features/job_detail/widgets/timeline_item.dart';

void main() {
  testWidgets('shows status and time safely on narrow widths', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(280, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: TimelineItem(
              data: TimelineData(
                status: 'Interview User Sangat Panjang Sekali',
                time: 'Kemarin pukul 19.30 WIB',
                notes:
                    'Catatan yang cukup panjang untuk memastikan layout tetap stabil.',
                isActive: true,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Interview User'), findsOneWidget);
    expect(find.text('Kemarin pukul 19.30 WIB'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
