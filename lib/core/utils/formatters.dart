import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  static final NumberFormat _numberFormat = NumberFormat('#,##0');

  /// Formats cents (e.g. 8844) into formatted USD ($88.44)
  static String formatCurrency(int? cents) {
    if (cents == null) return '\$0.00';
    return _currencyFormat.format(cents / 100);
  }

  /// Formats metrics like DA, DR, Traffic into human-readable numbers
  static String formatMetric(int? value) {
    if (value == null) return '—';
    return _numberFormat.format(value);
  }

  /// Clean hostnames from URLs (e.g. https://0000yic.com -> 0000yic.com)
  static String cleanDomain(String raw) {
    try {
      final uri = Uri.parse(raw.trim());
      if (uri.hasScheme && uri.host.isNotEmpty) {
        return uri.host;
      }
      return raw.replaceFirst(RegExp(r'^https?://'), '').split('/')[0];
    } catch (_) {
      return raw;
    }
  }

  /// Format date strings
  static String formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '—';
    try {
      final dt = DateTime.parse(isoString);
      return DateFormat.yMMMd().format(dt);
    } catch (_) {
      return isoString;
    }
  }
}
