import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nameretailer_mobile/core/network/api_client.dart';
import 'package:nameretailer_mobile/core/widgets/widgets.dart';
import 'package:nameretailer_mobile/features/cart/data/article_repository.dart';
import 'package:nameretailer_mobile/features/cart/models/article_file.dart';
import 'package:nameretailer_mobile/features/cart/models/cart.dart';
import 'package:nameretailer_mobile/features/cart/providers/cart_provider.dart';
import 'package:nameretailer_mobile/features/cart/screens/configure_placement_sheet.dart';
import 'package:nameretailer_mobile/features/marketplace/models/placement_options.dart';
import 'package:nameretailer_mobile/features/marketplace/providers/product_provider.dart';
import 'support/harness.dart';

class BriefCartRepo extends FakeCartRepo {
  BriefCartRepo({List<CartItem>? items, this.fail = false})
    : super(items: items ?? []);
  final bool fail;
  CartItem? saved;
  @override
  Future<CartView> saveItem({
    required CartItem item,
    required int cartVersion,
  }) async {
    if (fail) {
      throw ApiException(
        'The publication changed. Review the price and retry.',
      );
    }
    saved = item;
    return CartView(
      version: cartVersion + 1,
      items: [item],
      totalCents: item.totalCents,
    );
  }
}

class NoWritingRepo extends FakeProductRepo {
  @override
  Future<PlacementOptions> getProductOptions(String id) async =>
      PlacementOptions(
        productId: id,
        productVersion: 8,
        domain: 'https://example-publisher.com',
        placementCents: 4321,
        currency: 'USD',
        writingOptions: [],
        requirements: '',
        turnaround: '4 days',
        linkType: 'DoFollow',
      );
}

class RetainedArticleRepo extends FakeArticleRepo {
  final file = ArticleFile(
    id: 'fixture-file',
    name: 'campaign.txt',
    size: 30,
    expiresAt: DateTime.now().add(const Duration(days: 1)),
  );
  @override
  Future<List<ArticleFile>> list() async => [file];
}

void main() {
  Widget opener({int price = 8800}) => Scaffold(
    body: Builder(
      builder: (context) => AppButton(
        label: 'Open brief',
        onPressed: () =>
            showPlacementSheet(context, sampleProduct('p1', price: price)),
      ),
    ),
  );
  testWidgets(
    'Publication prices replace listing snapshots and no writing tiers are invented',
    (tester) async {
      await pumpApp(
        tester,
        opener(price: 99999),
        overrides: [
          ...await testOverrides(),
          productRepositoryProvider.overrideWithValue(NoWritingRepo()),
        ],
      );
      await tester.tap(find.text('Open brief'));
      await tester.pumpAndSettle();
      expect(find.text('Link + article'), findsNothing);
      expect(
        find.text('Article writing is unavailable for this publication.'),
        findsOneWidget,
      );
      expect(
        tester.widget<PriceActionRow>(find.byType(PriceActionRow)).cents,
        4321,
      );
    },
  );
  testWidgets(
    'Editing restores the saved brief and uses the current product version',
    (tester) async {
      final saved = CartItem(
        productId: 'p1',
        productVersion: 1,
        writingWords: 750,
        brief: PlacementBrief(
          promotedUrl: 'https://client-site.com/page',
          keyword: 'original keyword',
          specialRequirements: 'Original requirements',
          articleText: 'Original writing brief',
        ),
      );
      final repo = BriefCartRepo(items: [saved]);
      await pumpApp(
        tester,
        opener(),
        overrides: [
          ...await testOverrides(),
          cartRepositoryProvider.overrideWithValue(repo),
        ],
      );
      await tester.tap(find.text('Open brief'));
      await tester.pumpAndSettle();
      final fields = tester
          .widgetList<TextFormField>(find.byType(TextFormField))
          .toList();
      expect(fields[0].controller?.text, saved.brief!.promotedUrl);
      expect(fields[1].controller?.text, 'original keyword');
      expect(fields.last.controller?.text, 'Original writing brief');
      await tester.ensureVisible(find.text('Save placement'));
      await tester.tap(find.text('Save placement'));
      await tester.pumpAndSettle();
      expect(repo.saved?.productVersion, 7);
      expect(repo.saved?.writingWords, 750);
      expect(repo.saved?.writingCents, 5000);
      expect(repo.saved?.brief?.articleText, 'Original writing brief');
    },
  );
  testWidgets(
    'A failed save keeps the placement open and preserves the typed article',
    (tester) async {
      final repo = BriefCartRepo(fail: true);
      await pumpApp(
        tester,
        opener(),
        overrides: [
          ...await testOverrides(),
          cartRepositoryProvider.overrideWithValue(repo),
        ],
      );
      await tester.tap(find.text('Open brief'));
      await tester.pumpAndSettle();
      final fields = find.byType(TextFormField);
      for (final input in [
        (0, 'https://client-site.com/page'),
        (1, 'target keyword'),
        (3, 'My original article'),
      ]) {
        await tester.ensureVisible(fields.at(input.$1));
        await tester.enterText(fields.at(input.$1), input.$2);
      }
      await tester.ensureVisible(find.text('Save placement'));
      await tester.tap(find.text('Save placement'));
      await tester.pumpAndSettle();
      expect(find.byType(ConfigurePlacementSheet), findsOneWidget);
      expect(
        tester.widget<TextFormField>(fields.at(3)).controller?.text,
        'My original article',
      );
      expect(
        find.text('The publication changed. Review the price and retry.'),
        findsOneWidget,
      );
    },
  );
  testWidgets('Retained article files satisfy Link only without pasted text', (
    tester,
  ) async {
    final repo = BriefCartRepo();
    final files = RetainedArticleRepo();
    await pumpApp(
      tester,
      opener(),
      overrides: [
        ...await testOverrides(),
        cartRepositoryProvider.overrideWithValue(repo),
        articleRepositoryProvider.overrideWithValue(files),
      ],
    );
    await tester.tap(find.text('Open brief'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.ensureVisible(fields.at(0));
    await tester.enterText(fields.at(0), 'https://client-site.com/page');
    await tester.ensureVisible(fields.at(1));
    await tester.enterText(fields.at(1), 'target keyword');
    await tester.ensureVisible(find.text('Upload file'));
    await tester.tap(find.text('Upload file'));
    await tester.pumpAndSettle();
    final retained = find.byType(DropdownButtonFormField<String>);
    await tester.ensureVisible(retained);
    await tester.tap(retained);
    await tester.pumpAndSettle();
    await tester.tap(find.text('campaign.txt').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save placement'));
    await tester.tap(find.text('Save placement'));
    await tester.pumpAndSettle();
    expect(repo.saved?.writingWords, 0);
    expect(repo.saved?.brief?.articleText, isEmpty);
    expect(repo.saved?.brief?.fileId, files.file.id);
    expect(tester.takeException(), isNull);
  });
}
