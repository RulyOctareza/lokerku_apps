import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lokerku_apps/features/home/providers/providers.dart';
import 'package:lokerku_apps/features/home/widgets/sync_status_indicator.dart';

void main() {
  testWidgets('shows last sync message and sync button when online', (
    WidgetTester tester,
  ) async {
    final notifier = SyncNotifier();
    notifier.state = SyncState(
      isSyncing: false,
      lastSyncedAt: DateTime.parse('2024-01-01T00:00:00Z'),
      message: 'Sinkronisasi sebelumnya',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          syncProvider.overrideWith((ref) => notifier),
          connectivityProvider.overrideWith(
            (ref) => Stream.value(ConnectivityResult.wifi),
          ),
          unsyncedCountProvider.overrideWith((ref) => 0),
        ],
        child: const MaterialApp(home: Scaffold(body: SyncStatusIndicator())),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Sinkron sekarang'), findsOneWidget);
    expect(find.textContaining('Terakhir sync'), findsOneWidget);
    expect(find.text('Terhubung'), findsOneWidget);
  });

  testWidgets('shows offline badge and unsynced count when disconnected', (
    WidgetTester tester,
  ) async {
    final notifier = SyncNotifier();
    notifier.state = const SyncState(
      isSyncing: false,
      message: 'Menunggu koneksi',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          syncProvider.overrideWith((ref) => notifier),
          connectivityProvider.overrideWith(
            (ref) => Stream.value(ConnectivityResult.none),
          ),
          unsyncedCountProvider.overrideWith((ref) => 3),
        ],
        child: const MaterialApp(home: Scaffold(body: SyncStatusIndicator())),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Offline'), findsOneWidget);
    expect(find.textContaining('3 belum sinkron'), findsOneWidget);
  });
}
