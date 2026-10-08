import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nameretailer_mobile/core/providers/core_providers.dart';
import 'package:nameretailer_mobile/core/theme/app_theme.dart';
import 'package:nameretailer_mobile/features/home/screens/home_screen.dart';
import 'package:nameretailer_mobile/features/marketplace/models/product.dart';

void main() {
  testWidgets('HomeScreen smoke test with mock provider', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();

    final dummyProduct = Product(
      id: 'test-1',
      domain: 'https://testdomain.com',
      language: 'English',
      country: 'United States',
      category: 'Technology',
      priceCents: 5000,
      currency: 'USD',
      status: 'active',
      metrics: ProductMetrics(da: 50, dr: 45, traffic: 12000),
      linkType: 'DoFollow',
      turnaround: '3 days',
      requirements: '',
      version: 1,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          featuredProductsProvider.overrideWith(
            (ref) => Future.value(
              ProductPage(data: [dummyProduct], total: 1, page: 1, pageSize: 5),
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const HomeScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('NameRetailer'), findsWidgets);
    expect(find.text('DIRECT GUEST-POST PLACEMENTS'), findsOneWidget);
    expect(find.text('56,000+'), findsOneWidget);
  });
}
