import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_palette.dart';
import '../../core/widgets/widgets.dart';
import '../cart/providers/cart_provider.dart';

/// Hosts the five tab branches. Phones get a Material 3 navigation bar with a
/// pill indicator; tablets / landscape get a navigation rail.
class BottomNavShell extends ConsumerWidget {
  const BottomNavShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onSelect(int index) {
    HapticFeedback.selectionClick();
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartItemCountProvider);
    final p = context.palette;
    final size = MediaQuery.sizeOf(context);
    final useRail = size.width >= 720 && size.height >= 480;

    Widget icon(IconData data, {int badge = 0, String? label}) => badge > 0
        ? CountBadge(count: badge, semanticLabel: label, child: Icon(data))
        : Icon(data);

    final items = <_Dest>[
      const _Dest('Home', Icons.home_outlined, Icons.home_rounded),
      const _Dest('Search', Icons.search_rounded, Icons.search_rounded),
      const _Dest(
        'Favorites',
        Icons.favorite_border_rounded,
        Icons.favorite_rounded,
      ),
      _Dest(
        'Cart',
        Icons.shopping_bag_outlined,
        Icons.shopping_bag_rounded,
        badge: cartCount,
        tooltip: 'Planning cart',
      ),
      const _Dest(
        'Profile',
        Icons.person_outline_rounded,
        Icons.person_rounded,
      ),
    ];

    if (useRail) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: _onSelect,
                labelType: NavigationRailLabelType.all,
                minWidth: 88,
                destinations: [
                  for (final d in items)
                    NavigationRailDestination(
                      icon: icon(
                        d.icon,
                        badge: d.badge,
                        label: '${d.badge} items in cart',
                      ),
                      selectedIcon: icon(
                        d.selectedIcon,
                        badge: d.badge,
                        label: '${d.badge} items in cart',
                      ),
                      label: Text(d.label),
                    ),
                ],
              ),
            ),
            VerticalDivider(width: 1, color: p.border),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: p.border)),
        ),
        child: NavigationBar(
          animationDuration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 220),
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _onSelect,
          destinations: [
            for (final d in items)
              NavigationDestination(
                icon: icon(
                  d.icon,
                  badge: d.badge,
                  label: '${d.badge} items in cart',
                ),
                selectedIcon: icon(
                  d.selectedIcon,
                  badge: d.badge,
                  label: '${d.badge} items in cart',
                ),
                label: d.label,
                tooltip: d.tooltip ?? d.label,
              ),
          ],
        ),
      ),
    );
  }
}

class _Dest {
  const _Dest(
    this.label,
    this.icon,
    this.selectedIcon, {
    this.badge = 0,
    this.tooltip,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final int badge;
  final String? tooltip;
}
