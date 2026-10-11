import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nameretailer_mobile/features/auth/screens/login_screen.dart';
import 'package:nameretailer_mobile/features/cart/screens/configure_placement_sheet.dart';
import 'package:nameretailer_mobile/features/checkout/screens/checkout_screen.dart';
import 'package:nameretailer_mobile/features/checkout/models/checkout.dart';
import 'package:nameretailer_mobile/features/checkout/providers/checkout_provider.dart';
import 'package:nameretailer_mobile/features/home/screens/home_screen.dart';
import 'package:nameretailer_mobile/features/marketplace/providers/shortlist_provider.dart';
import 'package:nameretailer_mobile/features/marketplace/screens/domain_detail_screen.dart';
import 'package:nameretailer_mobile/features/navigation/app_router.dart';

import 'support/harness.dart';

/// Optional screenshots with bundled fonts and fixture data. Run with
/// flutter test test/visual_review_test.dart --dart-define=CAPTURE_UI=true
void main() {
  testWidgets(
    'Capture the native design for visual review',
    (tester) async {
      final previousShadows = debugDisableShadows;
      debugDisableShadows = false;
      addTearDown(() => debugDisableShadows = previousShadows);
      final fonts = FontLoader('Manrope');
      for (final weight in [500, 600, 700, 800]) {
        fonts.addFont(rootBundle.load('assets/fonts/Manrope-$weight.ttf'));
      }
      await fonts.load();
      final icons = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await icons.load();

      Future<void> capture(String name) async {
        await tester.runAsync(() async {
          final context = tester.element(
            find.byKey(const ValueKey('screen-capture')),
          );
          for (final size in [36, 44, 48]) {
            await precacheImage(
              ResizeImage(
                const AssetImage('assets/images/logo_emblem.png'),
                width: size,
              ),
              context,
            );
          }
        });
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.runAsync(() async {
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(const ValueKey('screen-capture')),
          );
          final image = await boundary.toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File('docs/previews/$name.png');
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }

      final overrides = await testOverrides();
      final container = ProviderContainer(overrides: overrides);
      addTearDown(container.dispose);
      final router = container.read(routerProvider);
      for (final dark in [false, true]) {
        await pumpApp(
          tester,
          const HomeScreen(),
          config: LayoutConfig(
            'review',
            const Size(390, 844),
            dark: dark,
            reduceMotion: true,
            platform: TargetPlatform.iOS,
          ),
          overrides: overrides,
          router: router,
        );
        router.go('/home');
        await capture(dark ? 'home-dark' : 'home');
        router.go('/marketplace');
        await capture(dark ? 'catalog-dark' : 'catalog');
        if (!dark) {
          final screenContainer = ProviderScope.containerOf(
            tester.element(find.byKey(const ValueKey('screen-capture'))),
          );
          for (final product in sampleProducts().take(2)) {
            screenContainer.read(shortlistProvider.notifier).toggle(product);
          }
          router.go('/shortlist');
          await capture('favorites');
          router.go('/profile');
          await capture('account');
          router.go('/cart');
          await capture('cart');
        }
      }
      for (final entry in <String, Widget>{
        'publication': const DomainDetailScreen(productId: 'p1'),
        'sign-in': const LoginScreen(),
        'checkout': const CheckoutScreen(),
      }.entries) {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        await pumpApp(
          tester,
          entry.value,
          config: const LayoutConfig(
            'review',
            Size(390, 844),
            reduceMotion: true,
            platform: TargetPlatform.iOS,
          ),
          overrides: [
            ...await testOverrides(),
            if (entry.key == 'checkout')
              checkoutRepositoryProvider.overrideWithValue(
                FakeCheckoutRepo(
                  draft: CheckoutDraft(
                    version: 1,
                    cartVersion: 1,
                    billing: BillingDetails(
                      email: 'alex@example.com',
                      firstName: 'Alex',
                      lastName: 'Morgan',
                      country: 'PK',
                      street: '12 Market Street',
                      city: 'Islamabad',
                    ),
                    notes: '',
                    paymentPreference: 'stripe',
                  ),
                ),
              ),
          ],
        );
        await capture(entry.key);
        if (entry.key == 'checkout') {
          await tester.tap(find.text('Continue to payment'));
          await capture('payment');
          await tester.tap(find.text('Review order'));
          await capture('order-review');
        }
      }
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await pumpApp(
        tester,
        Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showPlacementSheet(context, sampleProduct('p1')),
              child: const Text('Open placement'),
            ),
          ),
        ),
        config: const LayoutConfig(
          'review',
          Size(390, 844),
          reduceMotion: true,
        ),
        overrides: await testOverrides(),
      );
      await tester.tap(find.text('Open placement'));
      await capture('placement-sheet');
      debugDisableShadows = previousShadows;
    },
    skip: !const bool.fromEnvironment('CAPTURE_UI'),
  );
}
