import 'package:flutter_test/flutter_test.dart';
import 'package:nameretailer_mobile/features/auth/models/user.dart';
import 'package:nameretailer_mobile/features/marketplace/models/product.dart';
import 'package:nameretailer_mobile/features/marketplace/models/placement_options.dart';
import 'package:nameretailer_mobile/features/cart/models/cart.dart';

void main() {
  group('Models Serialization Tests', () {
    test('User fromJson and toJson', () {
      final json = {
        'id': 'user-123',
        'name': 'John Customer',
        'email': 'customer@example.com',
        'role': 'customer',
        'active': true,
      };

      final user = User.fromJson(json);
      expect(user.id, 'user-123');
      expect(user.name, 'John Customer');
      expect(user.email, 'customer@example.com');
      expect(user.role, 'customer');
      expect(user.active, true);
    });

    test('Product fromJson parses metrics correctly', () {
      final json = {
        'id': 'prod-1',
        'domain': 'https://exampledomain.com',
        'language': 'English',
        'country': 'United States',
        'category': 'Technology',
        'priceCents': 15000,
        'currency': 'USD',
        'status': 'active',
        'metrics': {
          'da': 55,
          'dr': 62,
          'traffic': 25000,
          'spamScore': 2,
        },
        'linkType': '02 DoFollow links',
        'turnaround': '4 days',
        'requirements': 'No casino or gambling links',
        'version': 1,
      };

      final product = Product.fromJson(json);
      expect(product.domain, 'https://exampledomain.com');
      expect(product.priceCents, 15000);
      expect(product.metrics.da, 55);
      expect(product.metrics.dr, 62);
      expect(product.metrics.traffic, 25000);
      expect(product.metrics.spamScore, 2);
    });

    test('PlacementOptions parses writing tiers', () {
      final json = {
        'productId': 'p-1',
        'productVersion': 1,
        'domain': 'https://techblog.com',
        'placementCents': 20000,
        'currency': 'USD',
        'writingOptions': [
          {'words': 500, 'priceCents': 3500},
          {'words': 750, 'priceCents': 5000},
          {'words': 1000, 'priceCents': 6500},
        ],
        'requirements': '',
        'turnaround': '3 days',
        'linkType': 'DoFollow',
      };

      final options = PlacementOptions.fromJson(json);
      expect(options.writingOptions.length, 3);
      expect(options.writingOptions[0].words, 500);
      expect(options.writingOptions[0].priceCents, 3500);
    });

    test('CartItem and CartView empty initialization', () {
      final cart = CartView.empty();
      expect(cart.version, 0);
      expect(cart.items, isEmpty);
      expect(cart.totalCents, 0);
    });

    test('ProductPage parses live API response structure', () {
      final apiResponse = {
        'data': [
          {
            'id': 'p-1',
            'domain': 'https://0000yic.com',
            'language': 'English',
            'country': 'United States',
            'category': 'Business',
            'priceCents': 8844,
            'currency': 'USD',
            'status': 'active',
            'metrics': {'da': 69, 'dr': 19},
            'linkType': '03 DoFollow links',
            'turnaround': '4 days',
            'requirements': '',
            'version': 2,
          }
        ],
        'total': 56005,
        'page': 1,
        'pageSize': 20,
      };

      final page = ProductPage.fromJson(apiResponse);
      expect(page.total, 56005);
      expect(page.data.length, 1);
      expect(page.data.first.domain, 'https://0000yic.com');
      expect(page.data.first.priceCents, 8844);
      expect(page.data.first.metrics.dr, 19);
    });
  });
}
