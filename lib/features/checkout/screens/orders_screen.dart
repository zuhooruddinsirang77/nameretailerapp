import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/widgets.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/payment_repository.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authenticated = ref.watch(
      authStateProvider.select((state) => state.isAuthenticated),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Your orders')),
      body: !authenticated
          ? EmptyState(
              icon: Icons.lock_outline,
              title: 'Sign in to view orders',
              message: 'Review your placement orders and payment status.',
              actionLabel: 'Sign in',
              onAction: () => context.push('/login'),
            )
          : ref
                .watch(ordersProvider)
                .when(
                  loading: () => const FormSkeleton(),
                  error: (error, _) => ErrorState(
                    error: error,
                    onRetry: () => ref.invalidate(ordersProvider),
                  ),
                  data: (orders) => orders.isEmpty
                      ? EmptyState(
                          icon: Icons.receipt_long_outlined,
                          title: 'No orders yet',
                          message:
                              'Your orders will appear here when you continue to payment.',
                          actionLabel: 'Browse publications',
                          onAction: () => context.go('/marketplace'),
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            ref.invalidate(ordersProvider);
                            await ref.read(ordersProvider.future);
                          },
                          child: ListView.separated(
                            padding: context.pagePadding(),
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: orders.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: AppSpace.md),
                            itemBuilder: (context, index) {
                              final order = orders[index];
                              return AppCard(
                                onTap: () =>
                                    context.push('/orders/${order.id}'),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      order.items
                                          .map(
                                            (item) => Formatters.cleanDomain(
                                              item.domain ?? 'Publication',
                                            ),
                                          )
                                          .join(', '),
                                    ),
                                    KeyValueRow(
                                      label: order.paid ? 'Paid' : order.status,
                                      value: Formatters.formatCurrency(
                                        order.totalCents,
                                      ),
                                    ),
                                    Text(
                                      '${order.provider == 'paypal' ? 'PayPal' : 'Stripe'} · ${order.id.substring(0, 12)}',
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                ),
    );
  }
}
