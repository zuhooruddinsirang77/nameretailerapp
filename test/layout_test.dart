import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nameretailer_mobile/core/providers/core_providers.dart';
import 'package:nameretailer_mobile/features/auth/screens/login_screen.dart';
import 'package:nameretailer_mobile/features/auth/screens/register_screen.dart';
import 'package:nameretailer_mobile/features/cart/screens/cart_screen.dart';
import 'package:nameretailer_mobile/features/checkout/screens/checkout_screen.dart';
import 'package:nameretailer_mobile/features/home/screens/home_screen.dart';
import 'package:nameretailer_mobile/features/inquiry/screens/inquiry_screen.dart';
import 'package:nameretailer_mobile/features/marketplace/models/product.dart';
import 'package:nameretailer_mobile/features/marketplace/providers/product_provider.dart';
import 'package:nameretailer_mobile/features/marketplace/providers/shortlist_provider.dart';
import 'package:nameretailer_mobile/features/marketplace/screens/domain_detail_screen.dart';
import 'package:nameretailer_mobile/features/marketplace/screens/marketplace_screen.dart';
import 'package:nameretailer_mobile/features/marketplace/screens/shortlist_screen.dart';
import 'package:nameretailer_mobile/features/profile/screens/about_screen.dart';
import 'package:nameretailer_mobile/features/profile/screens/help_screen.dart';
import 'package:nameretailer_mobile/features/profile/screens/profile_screen.dart';

import 'support/harness.dart';

/// Every customer screen is rendered at phone / large-phone / tablet sizes,
/// at 100–200 % text, in light and dark. Any RenderFlex overflow or build
/// exception fails the test.
void main() {
  final screens = <String, Widget Function()>{
    'Home': () => const HomeScreen(),
    'Marketplace': () => const MarketplaceScreen(),
    'Domain detail': () => const DomainDetailScreen(productId: 'p1'),
    'Shortlist': () => const ShortlistScreen(),
    'Cart': () => const CartScreen(),
    'Checkout': () => const CheckoutScreen(),
    'Profile': () => const ProfileScreen(),
    'Login': () => const LoginScreen(),
    'Register': () => const RegisterScreen(),
    'Inquiry': () => const InquiryScreen(domain: 'example.com'),
    'About': () => const AboutScreen(),
    'Help': () => const HelpScreen(),
  };

  Future<List<Override>> overridesWithShortlist() async {
    final base = await testOverrides();
    return [
      ...base,
      shortlistProvider.overrideWith((ref) {
        final n = ShortlistNotifier(ref.watch(storageServiceProvider));
        for (final p in sampleProducts()) {
          n.toggle(p);
        }
        return n;
      }),
    ];
  }

  for (final entry in screens.entries) {
    for (final config in layoutConfigs) {
      testWidgets('${entry.key} lays out at ${config.name}', (tester) async {
        await pumpApp(
          tester,
          entry.value(),
          config: config,
          overrides: await overridesWithShortlist(),
        );
        // Exercise lazily built content, including the bottom of long forms.
        final scrollables = tester
            .widgetList<Scrollable>(find.byType(Scrollable))
            .where((s) => s.axisDirection == AxisDirection.down)
            .toList();
        if (scrollables.isNotEmpty) {
          final scrollable = find.byWidget(scrollables.first);
          for (var i = 0; i < 6; i++) {
            await tester.drag(scrollable, const Offset(0, -500));
            await tester.pump(const Duration(milliseconds: 350));
            expect(tester.takeException(), isNull);
          }
        }
      });
    }
  }

  group('signed-out and failure states', () {
    for (final config in layoutConfigs.take(3)) {
      testWidgets('Cart signed out at ${config.name}', (tester) async {
        await pumpApp(
          tester,
          const CartScreen(),
          config: config,
          overrides: await testOverrides(signedIn: false),
        );
        expect(find.text('Sign in to use your cart'), findsOneWidget);
      });

      testWidgets('Checkout signed out at ${config.name}', (tester) async {
        await pumpApp(
          tester,
          const CheckoutScreen(),
          config: config,
          overrides: await testOverrides(signedIn: false),
        );
        expect(find.text('Sign in to check out'), findsOneWidget);
      });

      testWidgets('Profile as guest at ${config.name}', (tester) async {
        await pumpApp(
          tester,
          const ProfileScreen(),
          config: config,
          overrides: await testOverrides(signedIn: false),
        );
        await tester.scrollUntilVisible(
          find.text('Sign in'),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('Sign in'), findsWidgets);
      });

      testWidgets('Marketplace error state at ${config.name}', (tester) async {
        await pumpApp(
          tester,
          const MarketplaceScreen(),
          config: config,
          overrides: await testOverrides(failing: true),
        );
        expect(find.text('Try again'), findsOneWidget);
      });

      testWidgets('Home featured error state at ${config.name}', (
        tester,
      ) async {
        await pumpApp(
          tester,
          const HomeScreen(),
          config: config,
          overrides: await testOverrides(failing: true),
        );
        await tester.scrollUntilVisible(
          find.text('Try again'),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('Try again'), findsOneWidget);
      });

      testWidgets('Detail error state at ${config.name}', (tester) async {
        await pumpApp(
          tester,
          const DomainDetailScreen(productId: 'p1'),
          config: config,
          overrides: await testOverrides(failing: true),
        );
        expect(find.text('Try again'), findsOneWidget);
      });
    }
  });

  group('loading skeletons', () {
    for (final config in layoutConfigs.take(3)) {
      testWidgets('Marketplace skeleton at ${config.name}', (tester) async {
        final base = await testOverrides();
        await pumpApp(
          tester,
          const MarketplaceScreen(),
          config: config,
          overrides: [
            ...base,
            productListProvider.overrideWith(
              (ref) => Completer<ProductPage>().future,
            ),
          ],
        );
      });
    }
  });
}
