import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nameretailer_mobile/core/providers/core_providers.dart';
import 'package:nameretailer_mobile/core/theme/app_theme.dart';
import 'package:nameretailer_mobile/features/auth/data/auth_repository.dart';
import 'package:nameretailer_mobile/features/auth/models/user.dart';
import 'package:nameretailer_mobile/features/auth/providers/auth_provider.dart';
import 'package:nameretailer_mobile/features/cart/data/cart_repository.dart';
import 'package:nameretailer_mobile/features/cart/models/cart.dart';
import 'package:nameretailer_mobile/features/cart/providers/cart_provider.dart';
import 'package:nameretailer_mobile/features/checkout/data/checkout_repository.dart';
import 'package:nameretailer_mobile/features/checkout/models/checkout.dart';
import 'package:nameretailer_mobile/features/checkout/providers/checkout_provider.dart';
import 'package:nameretailer_mobile/features/home/screens/home_screen.dart';
import 'package:nameretailer_mobile/features/marketplace/models/facets.dart';
import 'package:nameretailer_mobile/features/marketplace/models/product.dart';
import 'package:nameretailer_mobile/features/marketplace/providers/product_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Product sampleProduct(
  String id, {
  String domain = 'https://example-publisher.com',
  int price = 8800,
  int? dr = 62,
  int? da = 55,
  int? traffic = 120000,
  int? spam = 3,
}) {
  return Product(
    id: id,
    domain: domain,
    language: 'English',
    country: 'United States',
    category: 'Technology',
    priceCents: price,
    currency: 'USD',
    status: 'active',
    metrics: ProductMetrics(
      da: da,
      dr: dr,
      tf: 31,
      ur: 40,
      traffic: traffic,
      referringDomains: 1450,
      backlinks: 250000,
      spamScore: spam,
    ),
    linkType: 'DoFollow',
    turnaround: '3-5 days',
    requirements: '',
    version: 1,
  );
}

final longDomainProduct = sampleProduct(
  'p-long',
  domain:
      'https://an-extremely-long-publication-domain-name-for-layout-testing.co.uk/news',
  price: 1234567,
  traffic: 98765432,
);

List<Product> sampleProducts() => [
  sampleProduct('p1'),
  sampleProduct(
    'p2',
    domain: 'https://second-site.io',
    price: 4500,
    dr: 71,
    da: 60,
  ),
  longDomainProduct,
  sampleProduct(
    'p4',
    domain: 'nometrics.org',
    dr: null,
    da: null,
    traffic: null,
    spam: null,
  ),
];

class _NoAuthRepo implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAuth extends AuthNotifier {
  FakeAuth(this._user) : super(_NoAuthRepo());
  final User? _user;

  @override
  Future<void> checkInitialAuth() async {
    state = _user == null
        ? AuthState(status: AuthStatus.unauthenticated)
        : AuthState(status: AuthStatus.authenticated, user: _user);
  }
}

CartItem sampleCartItem(
  String id, {
  String status = 'ready',
  int words = 500,
}) => CartItem(
  productId: id,
  productVersion: 1,
  writingWords: words,
  domain: 'https://cart-$id-publisher.com',
  placementCents: 8800,
  writingCents: words == 0 ? 0 : 3500,
  totalCents: 8800 + (words == 0 ? 0 : 3500),
  status: status,
  brief: PlacementBrief(
    promotedUrl: 'https://client-site.com/a-very/long/landing/page/path',
    keyword: 'enterprise software',
    specialRequirements: '',
    articleText: '',
  ),
);

class FakeCartRepo implements CartRepository {
  FakeCartRepo({this.items});
  final List<CartItem>? items;

  CartView get _view => CartView(
    version: 1,
    items:
        items ??
        [
          sampleCartItem('a'),
          sampleCartItem('b', status: 'changed', words: 0),
          sampleCartItem('c', status: 'unavailable'),
        ],
    totalCents: 40000,
    checkoutAvailable: true,
  );

  @override
  Future<CartView> getCart() async => _view;

  @override
  Future<CartView> saveItem({
    required CartItem item,
    required int cartVersion,
  }) async => _view;

  @override
  Future<CartView> removeItem({
    required String productId,
    required int cartVersion,
  }) async => _view;
}

class FakeCheckoutRepo implements CheckoutRepository {
  @override
  Future<CheckoutView> getCheckout() async => CheckoutView(
    cart: await FakeCartRepo().getCart(),
    issues: const ['One publication changed price since you added it.'],
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

User testUser() => User(
  id: 'u1',
  name: 'Alexandria Montgomery-Featherstonehaugh',
  email: 'alexandria.montgomery@very-long-company-domain.example.com',
  role: 'customer',
  active: true,
);

Future<List<Override>> testOverrides({
  bool signedIn = true,
  bool failing = false,
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final page = ProductPage(
    data: sampleProducts(),
    total: 4,
    page: 1,
    pageSize: 20,
  );
  return [
    sharedPreferencesProvider.overrideWithValue(prefs),
    authStateProvider.overrideWith(
      (ref) => FakeAuth(signedIn ? testUser() : null),
    ),
    cartRepositoryProvider.overrideWithValue(FakeCartRepo()),
    checkoutRepositoryProvider.overrideWithValue(FakeCheckoutRepo()),
    productListProvider.overrideWith(
      (ref) => failing ? Future.error('boom') : Future.value(page),
    ),
    facetsProvider.overrideWith(
      (ref) async => ProductFacets(
        countries: ['United States', 'United Kingdom', 'Germany'],
        languages: ['English'],
        categories: ['Technology', 'Business', 'Health', 'Travel'],
      ),
    ),
    featuredProductsProvider.overrideWith(
      (ref) => failing ? Future.error('boom') : Future.value(page),
    ),
    productDetailProvider.overrideWith(
      (ref, id) async => failing
          ? throw Exception('boom')
          : {'product': sampleProduct(id), 'options': null},
    ),
  ];
}

class LayoutConfig {
  const LayoutConfig(
    this.name,
    this.size, {
    this.textScale = 1,
    this.dark = false,
    this.reduceMotion = false,
    this.platform = TargetPlatform.android,
  });

  final String name;
  final Size size;
  final double textScale;
  final bool dark;
  final bool reduceMotion;
  final TargetPlatform platform;
}

const layoutConfigs = [
  LayoutConfig('360dp phone', Size(360, 640)),
  LayoutConfig('320dp iPhone', Size(320, 568), platform: TargetPlatform.iOS),
  LayoutConfig('360dp phone, 200% text', Size(360, 640), textScale: 2),
  LayoutConfig('412dp phone, dark', Size(412, 915), dark: true),
  LayoutConfig('tablet 820dp', Size(820, 1180)),
  LayoutConfig('landscape phone', Size(740, 360), reduceMotion: true),
  LayoutConfig(
    'tablet dark, 150% text',
    Size(820, 1180),
    textScale: 1.5,
    dark: true,
  ),
];

/// Pumps [home] inside the app theme, a router (screens use go_router) and
/// the given provider overrides, at the requested size / text scale / theme.
Future<void> pumpApp(
  WidgetTester tester,
  Widget home, {
  LayoutConfig config = const LayoutConfig('default', Size(412, 915)),
  List<Override> overrides = const [],
  GoRouter? router,
}) async {
  tester.view.physicalSize = config.size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final r =
      router ??
      GoRouter(
        routes: [
          GoRoute(path: '/', builder: (_, _) => home),
          for (final path in [
            '/login',
            '/register',
            '/cart',
            '/checkout',
            '/inquiry',
            '/shortlist',
            '/marketplace',
            '/domain/:id',
          ])
            GoRoute(
              path: path,
              builder: (_, _) => const Scaffold(body: Text('stub')),
            ),
        ],
      );

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp.router(
        theme: AppTheme.lightTheme.copyWith(platform: config.platform),
        darkTheme: AppTheme.darkTheme.copyWith(platform: config.platform),
        themeMode: config.dark ? ThemeMode.dark : ThemeMode.light,
        routerConfig: r,
        builder: (context, child) => RepaintBoundary(
          key: const ValueKey('screen-capture'),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(config.textScale),
              disableAnimations: config.reduceMotion,
            ),
            child: SafeArea(top: false, bottom: false, child: child!),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 700));
}
