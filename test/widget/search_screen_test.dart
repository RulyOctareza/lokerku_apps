import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lokerku_apps/data/models/job_application.dart';
import 'package:lokerku_apps/features/search/search_screen.dart';

void main() {
  testWidgets('does not throw when disposed before jobs finish loading', (
    WidgetTester tester,
  ) async {
    final completer = Completer<List<JobApplication>>();

    await tester.pumpWidget(
      MaterialApp(home: SearchScreen(jobsLoader: () => completer.future)),
    );

    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));

    completer.complete([]);
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('adapts filter controls on compact screens without overflow', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final job = JobApplication.create(
      companyName: 'PT Sempit Sekali',
      role: 'Flutter Developer',
      platform: JobPlatform.linkedin,
    );

    await tester.pumpWidget(
      MaterialApp(home: SearchScreen(jobsLoader: () async => [job])),
    );
    await tester.pumpAndSettle();

    expect(find.text('Semua tanggal'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
