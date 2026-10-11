import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nameretailer_mobile/core/widgets/widgets.dart';
import 'package:nameretailer_mobile/features/cart/models/cart.dart';
import 'package:nameretailer_mobile/features/cart/providers/cart_provider.dart';
import 'package:nameretailer_mobile/features/cart/screens/configure_placement_sheet.dart';
import 'package:nameretailer_mobile/features/home/screens/home_screen.dart';
import 'package:nameretailer_mobile/features/marketplace/data/product_repository.dart';
import 'package:nameretailer_mobile/features/marketplace/models/facets.dart';
import 'package:nameretailer_mobile/features/marketplace/providers/product_provider.dart';
import 'package:nameretailer_mobile/features/marketplace/screens/domain_detail_screen.dart';
import 'package:nameretailer_mobile/features/marketplace/screens/marketplace_screen.dart';
import 'package:nameretailer_mobile/features/marketplace/widgets/compare_table.dart';
import 'package:nameretailer_mobile/features/marketplace/widgets/filter_sheet.dart';

import 'support/harness.dart';

class RecordingCart extends FakeCartRepo {
  CartItem? saved;

  @override
  Future<CartView> saveItem({
    required CartItem item,
    required int cartVersion,
  }) async {
    saved = item;
    return CartView(
      version: cartVersion + 1,
      items: [item],
      checkoutAvailable: true,
    );
  }
}

void main() {
  for (final config in layoutConfigs) {
    testWidgets('Placement sheet and keyboard at ${config.name}', (
      tester,
    ) async {
      await pumpApp(
        tester,
        Scaffold(
          body: Builder(
            builder: (context) => AppButton(
              label: 'Open placement',
              onPressed: () => showPlacementSheet(context, longDomainProduct),
            ),
          ),
        ),
        config: config,
        overrides: await testOverrides(),
      );
      await tester.tap(find.text('Open placement'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      tester.view.viewInsets = FakeViewPadding(
        bottom: config.size.height < 500 ? 150 : 280,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final url = find.byType(TextFormField).first;
      await tester.ensureVisible(url);
      await tester.enterText(url, 'https://client.example/landing');
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      tester.view.viewInsets = FakeViewPadding.zero;
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Save placement'));
      expect(
        find.text('Save placement').hitTestable(),
        findsOneWidget,
      );
    });

    testWidgets('Filter sheet at ${config.name}', (tester) async {
      ProductFilterParams? applied;
      final initial = ProductFilterParams(
        language: 'English',
        minTraffic: 500,
        sort: 'drDesc',
      );
      await pumpApp(
        tester,
        Scaffold(
          body: Builder(
            builder: (context) => AppButton(
              label: 'Open filters',
              onPressed: () => showFilterSheet(
                context,
                initial: initial,
                facets: ProductFacets(
                  categories: ['Business', 'Technology'],
                  countries: ['United States', 'United Kingdom'],
                  languages: ['English'],
                ),
                onApply: (value) => applied = value,
              ),
            ),
          ),
        ),
        config: config,
        overrides: await testOverrides(),
      );
      await tester.tap(find.text('Open filters'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Technology'));
      await tester.tap(find.text('Technology'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Show results'));
      await tester.tap(find.text('Show results'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(applied?.category, 'Technology');
      expect(applied?.language, 'English');
      expect(applied?.minTraffic, 500);
      expect(applied?.sort, 'drDesc');
      expect(applied?.page, 1);
    });

    testWidgets('Comparison remains readable at ${config.name}', (
      tester,
    ) async {
      String? opened;
      String? removed;
      await pumpApp(
        tester,
        Scaffold(
          body: SingleChildScrollView(
            child: CompareTable(
              products: sampleProducts(),
              onOpen: (p) => opened = p.id,
              onRemove: (p) => removed = p.id,
            ),
          ),
        ),
        config: config,
        overrides: await testOverrides(),
      );
      await tester.tap(find.text('example-publisher.com'));
      expect(opened, 'p1');
      await tester.tap(
        find.byTooltip('Remove example-publisher.com from shortlist'),
      );
      expect(removed, 'p1');
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Narrow detail footer retains the inquiry action', (
    tester,
  ) async {
    await pumpApp(
      tester,
      const DomainDetailScreen(productId: 'p1'),
      config: const LayoutConfig('small', Size(320, 568), textScale: 2),
      overrides: await testOverrides(),
    );
    final inquiry = find.byTooltip(
      'Send an inquiry about example-publisher.com',
    );
    expect(inquiry.hitTestable(), findsOneWidget);
    await tester.tap(inquiry);
    await tester.pumpAndSettle();
    expect(find.text('stub'), findsOneWidget);
  });

  testWidgets('Placement submission retains its full cart brief and pricing', (
    tester,
  ) async {
    final repo = RecordingCart();
    final overrides = await testOverrides();
    await pumpApp(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => AppButton(
            label: 'Open placement',
            onPressed: () => showPlacementSheet(context, sampleProduct('p1')),
          ),
        ),
      ),
      overrides: [...overrides, cartRepositoryProvider.overrideWithValue(repo)],
    );
    await tester.tap(find.text('Open placement'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Link + article'));
    await tester.tap(find.text('Link + article'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.ensureVisible(fields.at(0));
    await tester.enterText(fields.at(0), 'https://client-site.com/page');
    await tester.ensureVisible(fields.at(1));
    await tester.enterText(fields.at(1), 'target keyword');
    await tester.ensureVisible(fields.at(2));
    await tester.enterText(fields.at(2), 'Publisher instructions');
    await tester.ensureVisible(fields.at(3));
    await tester.enterText(
      fields.at(3),
      'Describe enterprise software for a business audience.',
    );
    await tester.ensureVisible(find.text('Save placement'));
    await tester.tap(find.text('Save placement'));
    await tester.pumpAndSettle();
    expect(repo.saved?.productId, 'p1');
    expect(repo.saved?.productVersion, 7);
    expect(repo.saved?.writingWords, 500);
    expect(repo.saved?.placementCents, 8800);
    expect(repo.saved?.writingCents, 3500);
    expect(repo.saved?.totalCents, 12300);
    expect(repo.saved?.brief?.promotedUrl, 'https://client-site.com/page');
    expect(repo.saved?.brief?.keyword, 'target keyword');
    expect(repo.saved?.brief?.specialRequirements, 'Publisher instructions');
    expect(find.text('stub'), findsOneWidget);
  });

  testWidgets('Home search keeps query submission and destination', (
    tester,
  ) async {
    await pumpApp(tester, const HomeScreen(), overrides: await testOverrides());
    final container = ProviderScope.containerOf(
      tester.element(find.byType(HomeScreen)),
    );
    await tester.enterText(find.byType(TextField), '  technology  ');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(container.read(productFilterProvider).query, 'technology');
    expect(container.read(productFilterProvider).page, 1);
    expect(find.text('stub'), findsOneWidget);
  });

  testWidgets('Catalog sort keeps the selected server sort key', (
    tester,
  ) async {
    await pumpApp(
      tester,
      const MarketplaceScreen(),
      overrides: await testOverrides(),
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MarketplaceScreen)),
    );
    await tester.tap(find.byTooltip('Sort, currently Name A–Z'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Price: high to low'));
    await tester.pumpAndSettle();
    expect(container.read(productFilterProvider).sort, 'priceDesc');
    expect(container.read(productFilterProvider).page, 1);
  });
}
