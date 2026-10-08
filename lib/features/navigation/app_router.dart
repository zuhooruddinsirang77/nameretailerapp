import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/screens/login_screen.dart';
import '../auth/screens/register_screen.dart';
import '../cart/screens/cart_screen.dart';
import '../checkout/screens/checkout_screen.dart';
import '../home/screens/home_screen.dart';
import '../inquiry/screens/inquiry_screen.dart';
import '../marketplace/screens/domain_detail_screen.dart';
import '../marketplace/screens/marketplace_screen.dart';
import '../marketplace/screens/shortlist_screen.dart';
import '../profile/screens/about_screen.dart';
import '../profile/screens/help_screen.dart';
import '../profile/screens/profile_screen.dart';
import 'bottom_nav_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return BottomNavShell(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Branch 1: Marketplace
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/marketplace',
                builder: (context, state) => const MarketplaceScreen(),
              ),
            ],
          ),
          // Branch 2: Cart
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cart',
                builder: (context, state) => const CartScreen(),
              ),
            ],
          ),
          // Branch 3: Profile / Account
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Domain detail screen
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/domain/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return DomainDetailScreen(productId: id);
        },
      ),

      // Shortlist screen
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/shortlist',
        builder: (context, state) => const ShortlistScreen(),
      ),

      // Checkout screen
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),

      // Inquiry screen
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/inquiry',
        builder: (context, state) {
          final domain = state.uri.queryParameters['domain'];
          return InquiryScreen(domain: domain);
        },
      ),

      // Auth screens
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Information screens
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/help',
        builder: (context, state) => const HelpScreen(),
      ),
    ],
  );
});
