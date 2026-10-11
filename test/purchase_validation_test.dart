import 'package:flutter_test/flutter_test.dart';
import 'package:nameretailer_mobile/features/cart/models/brief_validation.dart';
import 'package:nameretailer_mobile/features/cart/models/cart.dart';
import 'package:nameretailer_mobile/features/cart/models/article_file.dart';
import 'package:nameretailer_mobile/features/checkout/data/payment_repository.dart';
import 'package:nameretailer_mobile/features/checkout/models/checkout.dart';

void main() {
  test('Promoted URL validation matches the web public URL rules', () {
    for (final value in [
      '',
      'example.com',
      'ftp://example.com',
      'https://user:secret@example.com',
      'https://127.0.0.1',
      'https://example.local',
      'https://client.example',
      'https://example.com:3000',
      'https://bad_host.com',
      'https://example.com/space here',
    ]) {
      expect(validatePromotedUrl(value), isNotNull, reason: value);
    }
    for (final value in [
      'https://example.com/page',
      'http://www.example.com/page?q=campaign',
      'https://client-site.com',
    ]) {
      expect(validatePromotedUrl(value), isNull, reason: value);
    }
  });
  test('Brief fields enforce required text, limits and safe Markdown', () {
    expect(validateBriefText('', max: 200, required: true), isNotNull);
    expect(validateBriefText('x' * 201, max: 200), isNotNull);
    expect(
      validateBriefText('<script>alert(1)</script>', max: 40000),
      isNotNull,
    );
    expect(
      validateBriefText(
        '**Headline**\n- First point\n[Reference](https://example.com)',
        max: 40000,
      ),
      isNull,
    );
  });
  test('Only HTTPS addresses for the selected payment provider can open', () {
    expect(
      paymentBrowserUri('https://checkout.stripe.com/c/pay/fixture', 'stripe'),
      isNotNull,
    );
    expect(
      paymentBrowserUri('https://www.sandbox.paypal.com/checkoutnow', 'paypal'),
      isNotNull,
    );
    expect(
      paymentBrowserUri('https://www.paypal.com/checkoutnow', 'paypal'),
      isNotNull,
    );
    for (final value in [
      'javascript:alert(1)',
      'http://checkout.stripe.com',
      'https://checkout.stripe.com.evil.com',
      'https://secret@checkout.stripe.com',
      'https://checkout.stripe.com:8080',
    ]) {
      expect(paymentBrowserUri(value, 'stripe'), isNull);
    }
    expect(
      paymentBrowserUri('https://www.paypal.com/checkoutnow', 'stripe'),
      isNull,
    );
  });
  test(
    'Checkout reads available methods and all supported billing countries',
    () {
      final view = CheckoutView.fromJson({
        'paymentMethods': {'stripe': false, 'paypal': true},
        'paymentAvailable': true,
        'orderSubmissionAvailable': true,
        'billingCountries': [
          {'code': 'BR', 'name': 'Brazil'},
        ],
      });
      expect(view.paymentMethods.available('paypal'), isTrue);
      expect(view.paymentMethods.available('stripe'), isFalse);
      expect(view.billingCountries.single.code, 'BR');
      expect(CheckoutView.fromJson({}).paymentMethods.paypal, isFalse);
    },
  );
  test('Cart blocks incomplete, changed and expired briefs', () {
    CartItem item({
      String status = 'ready',
      String article = '',
      String? fileId,
      ArticleFile? file,
      int words = 0,
    }) => CartItem(
      productId: 'p1',
      productVersion: 1,
      writingWords: words,
      status: status,
      file: file,
      brief: PlacementBrief(
        promotedUrl: 'https://client-site.com/page',
        keyword: 'anchor',
        articleText: article,
        fileId: fileId,
      ),
    );
    expect(item().issue, isNotNull);
    expect(item(article: 'Article text').issue, isNull);
    expect(item(status: 'changed', article: 'Article').issue, isNotNull);
    expect(item(status: 'unavailable', article: 'Article').issue, isNotNull);
    expect(item(words: 500).issue, isNotNull);
    expect(item(words: 500, article: 'Writing brief').issue, isNull);
    expect(item(fileId: 'f1').issue, isNotNull);
    expect(
      item(
        fileId: 'f1',
        file: ArticleFile(
          id: 'f1',
          name: 'article.txt',
          size: 20,
          expiresAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ).issue,
      isNotNull,
    );
    expect(
      item(
        fileId: 'f1',
        file: ArticleFile(
          id: 'f1',
          name: 'article.txt',
          size: 20,
          expiresAt: DateTime.now().add(const Duration(days: 1)),
        ),
      ).issue,
      isNull,
    );
  });
}
