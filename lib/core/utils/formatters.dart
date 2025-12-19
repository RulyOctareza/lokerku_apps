import 'package:intl/intl.dart';

/// Date and Time Formatting Utilities
class DateFormatter {
  DateFormatter._();

  /// Format timestamp to relative time (e.g., "2 jam lalu")
  static String toRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks minggu lalu';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months bulan lalu';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years tahun lalu';
    }
  }

  /// Format date to readable format (e.g., "20 Okt 2023")
  static String toReadableDate(DateTime dateTime) {
    return DateFormat('d MMM yyyy', 'id_ID').format(dateTime);
  }

  /// Format date with time (e.g., "20 Okt 2023, 14:30")
  static String toReadableDateTime(DateTime dateTime) {
    return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(dateTime);
  }

  /// Format to full date (e.g., "Jumat, 20 Oktober 2023")
  static String toFullDate(DateTime dateTime) {
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(dateTime);
  }

  /// Format time only (e.g., "14:30")
  static String toTimeOnly(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  /// Format for API (ISO 8601)
  static String toIso8601(DateTime dateTime) {
    return dateTime.toUtc().toIso8601String();
  }

  /// Parse from API (ISO 8601)
  static DateTime fromIso8601(String dateString) {
    return DateTime.parse(dateString).toLocal();
  }
}

/// Currency Formatting Utilities
class CurrencyFormatter {
  CurrencyFormatter._();

  /// Format number to Indonesian Rupiah (e.g., "Rp 15.000.000")
  static String toRupiah(double? amount) {
    if (amount == null) return '-';
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  /// Format number to compact form (e.g., "15 Jt")
  static String toCompactRupiah(double? amount) {
    if (amount == null) return '-';

    if (amount >= 1000000000) {
      return 'Rp ${(amount / 1000000000).toStringAsFixed(1)} M';
    } else if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(0)} Jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)} Rb';
    }
    return 'Rp ${amount.toStringAsFixed(0)}';
  }

  /// Parse string to double (handles Indonesian format)
  static double? parseRupiah(String value) {
    if (value.isEmpty) return null;
    // Remove non-numeric characters except decimal point
    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
    return double.tryParse(cleaned);
  }
}
