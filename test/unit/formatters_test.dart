import 'package:flutter_test/flutter_test.dart';
import 'package:lokerku_apps/core/utils/formatters.dart';

void main() {
  group('DateFormatter', () {
    test('toRelativeTime should return "Baru saja" for recent timestamps', () {
      final now = DateTime.now();
      expect(DateFormatter.toRelativeTime(now), 'Baru saja');
    });

    test('toRelativeTime should return minutes ago', () {
      final thirtyMinutesAgo = DateTime.now().subtract(
        const Duration(minutes: 30),
      );
      expect(DateFormatter.toRelativeTime(thirtyMinutesAgo), '30 menit lalu');
    });

    test('toRelativeTime should return hours ago', () {
      final fiveHoursAgo = DateTime.now().subtract(const Duration(hours: 5));
      expect(DateFormatter.toRelativeTime(fiveHoursAgo), '5 jam lalu');
    });

    test('toRelativeTime should return days ago', () {
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      expect(DateFormatter.toRelativeTime(threeDaysAgo), '3 hari lalu');
    });

    test('toRelativeTime should return weeks ago', () {
      final twoWeeksAgo = DateTime.now().subtract(const Duration(days: 14));
      expect(DateFormatter.toRelativeTime(twoWeeksAgo), '2 minggu lalu');
    });

    test('toRelativeTime should return months ago', () {
      final threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));
      expect(DateFormatter.toRelativeTime(threeMonthsAgo), '3 bulan lalu');
    });

    test('toIso8601 and fromIso8601 should be reversible', () {
      final original = DateTime(2024, 6, 15, 10, 30, 0);
      final iso = DateFormatter.toIso8601(original);
      final parsed = DateFormatter.fromIso8601(iso);

      expect(parsed.year, original.year);
      expect(parsed.month, original.month);
      expect(parsed.day, original.day);
    });
  });

  group('CurrencyFormatter', () {
    test('toRupiah should format currency correctly', () {
      expect(CurrencyFormatter.toRupiah(15000000), 'Rp 15.000.000');
      expect(CurrencyFormatter.toRupiah(0), 'Rp 0');
      expect(CurrencyFormatter.toRupiah(null), '-');
    });

    test('toCompactRupiah should format large numbers', () {
      expect(CurrencyFormatter.toCompactRupiah(15000000), 'Rp 15 Jt');
      expect(CurrencyFormatter.toCompactRupiah(1500000000), 'Rp 1.5 M');
      expect(CurrencyFormatter.toCompactRupiah(150000), 'Rp 150 Rb');
      expect(CurrencyFormatter.toCompactRupiah(100), 'Rp 100');
      expect(CurrencyFormatter.toCompactRupiah(null), '-');
    });

    test('parseRupiah should extract numeric value', () {
      expect(CurrencyFormatter.parseRupiah('15000000'), 15000000);
      expect(CurrencyFormatter.parseRupiah('Rp 15.000.000'), 15000000);
      expect(CurrencyFormatter.parseRupiah(''), null);
    });
  });
}
