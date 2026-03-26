import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lokerku_apps/data/models/job_application.dart';
import 'package:lokerku_apps/features/stats/stats_screen.dart';

void main() {
  testWidgets('stacks conversion cards on compact screens without overflow', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: StatsScreen(
          statusBreakdownLoader: () async => {
            ApplicationStatus.applied: 5,
            ApplicationStatus.interviewHR: 2,
            ApplicationStatus.offering: 1,
          },
          platformBreakdownLoader: () async => {
            JobPlatform.linkedin: 3,
            JobPlatform.jobstreet: 2,
            JobPlatform.website: 1,
          },
          totalCountLoader: () async => 6,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Applied → Interview'), findsOneWidget);
    expect(find.text('Interview → Offer'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
