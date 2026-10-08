import 'package:flutter_test/flutter_test.dart';
import 'package:nameretailer_mobile/core/utils/formatters.dart';

void main() {
  group('Formatters Tests', () {
    test('formatCurrency formats cents to USD properly', () {
      expect(Formatters.formatCurrency(8844), '\$88.44');
      expect(Formatters.formatCurrency(10174), '\$101.74');
      expect(Formatters.formatCurrency(0), '\$0.00');
      expect(Formatters.formatCurrency(null), '\$0.00');
    });

    test('formatMetric formats integers with commas or fallback', () {
      expect(Formatters.formatMetric(15000), '15,000');
      expect(Formatters.formatMetric(46), '46');
      expect(Formatters.formatMetric(null), '—');
    });

    test('cleanDomain strips https:// and trailing paths', () {
      expect(Formatters.cleanDomain('https://0000yic.com'), '0000yic.com');
      expect(Formatters.cleanDomain('https://0000yic.com/path'), '0000yic.com');
      expect(Formatters.cleanDomain('0000yic.com'), '0000yic.com');
    });
  });
}
