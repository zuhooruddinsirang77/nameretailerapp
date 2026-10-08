import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nameretailer_mobile/features/home/screens/home_screen.dart';
import 'package:nameretailer_mobile/features/marketplace/providers/product_provider.dart';
import 'package:nameretailer_mobile/features/navigation/app_router.dart';

import 'support/harness.dart';

void main() {
  for (final config in layoutConfigs) {
    testWidgets('Customer tabs work and preserve search at ${config.name}', (
      tester,
    ) async {
      final overrides = await testOverrides();
      final container = ProviderContainer(overrides: overrides);
      final router = container.read(routerProvider);
      addTearDown(() {
        router.dispose();
        container.dispose();
      });
      await pumpApp(
        tester,
        const HomeScreen(),
        config: config,
        overrides: overrides,
        router: router,
      );

      Future<void> select(String label, String location) async {
        final rail = find.byType(NavigationRail);
        final tab = rail.evaluate().isEmpty
            ? find.byTooltip(label).last
            : find.descendant(
                of: rail,
                matching: find.text(label == 'Planning cart' ? 'Cart' : label),
              );
        await tester.ensureVisible(tab);
        await tester.tap(tab);
        await tester.pumpAndSettle();
        expect(router.routeInformationProvider.value.uri.path, location);
        expect(tester.takeException(), isNull);
      }

      await select('Search', '/marketplace');
      final search = find.byType(TextField);
      await tester.enterText(search, 'technology');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      final scope = ProviderScope.containerOf(
        tester.element(find.byType(TextField)),
      );
      expect(scope.read(productFilterProvider).query, 'technology');
      await select('Favorites', '/shortlist');
      await select('Planning cart', '/cart');
      await select('Profile', '/profile');
      await select('Search', '/marketplace');
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller?.text,
        'technology',
      );
      expect(scope.read(productFilterProvider).query, 'technology');
    });
  }
}
