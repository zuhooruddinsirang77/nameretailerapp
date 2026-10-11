import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/widgets.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../data/payment_repository.dart';
import '../models/payment.dart';
import '../providers/checkout_provider.dart';

class OrderScreen extends ConsumerStatefulWidget {
  const OrderScreen({super.key, required this.orderId, this.redirect});
  final String orderId;
  final PaymentRedirect? redirect;
  @override
  ConsumerState<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends ConsumerState<OrderScreen>
    with WidgetsBindingObserver {
  CustomerOrder? _order;
  String? _error;
  bool _loading = true, _checking = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() async {
      await _load();
      if (mounted &&
          _order != null &&
          !_order!.paid &&
          widget.redirect != null) {
        await _openPayment();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _order?.status == 'pending' &&
        !_checking) {
      _check();
    }
  }

  void _accept(CustomerOrder order) {
    setState(() {
      _order = order;
      _loading = false;
    });
    if (order.paid) {
      ref.invalidate(cartProvider);
      ref.invalidate(checkoutProvider);
      ref.invalidate(ordersProvider);
    }
  }

  Future<void> _load() async {
    if (!ref.read(authStateProvider).isAuthenticated) {
      setState(() => _loading = false);
      return;
    }
    try {
      final order = await ref
          .read(paymentRepositoryProvider)
          .getOrder(widget.orderId);
      if (mounted) _accept(order);
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _check() async {
    if (_checking || !ref.read(authStateProvider).isAuthenticated) return;
    setState(() {
      _checking = true;
      _error = null;
    });
    try {
      final order = await ref
          .read(paymentRepositoryProvider)
          .confirm(widget.orderId);
      if (mounted) _accept(order);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _openPayment() async {
    final redirect = widget.redirect;
    if (redirect == null || _order == null) return;
    final uri = paymentBrowserUri(redirect.url, _order!.provider);
    if (uri == null) {
      setState(
        () => _error =
            'This payment link is unavailable. Check order status before retrying checkout.',
      );
      return;
    }
    try {
      final opened = await ref.read(paymentBrowserProvider)(uri);
      if (!opened && mounted) {
        setState(
          () => _error =
              'Could not open your browser. Try opening payment again.',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not open the payment page. Try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authenticated = ref.watch(
      authStateProvider.select((state) => state.isAuthenticated),
    );
    final order = _order;
    return Scaffold(
      appBar: AppBar(title: const Text('Order status')),
      body: !authenticated
          ? EmptyState(
              icon: Icons.lock_outline,
              title: 'Sign in to view your order',
              message: 'Your orders are private to your account.',
              actionLabel: 'Sign in',
              onAction: () async {
                await context.push('/login');
                if (mounted) await _load();
              },
            )
          : _loading
          ? const FormSkeleton()
          : order == null
          ? ErrorState(error: _error, onRetry: _load)
          : ListView(
              padding: context.pagePadding(),
              children: [
                InlineMessage(
                  tone: order.paid
                      ? MessageTone.success
                      : order.status == 'pending'
                      ? MessageTone.info
                      : MessageTone.warning,
                  icon: order.paid
                      ? Icons.check_circle_outline
                      : Icons.payments_outlined,
                  title: order.paid
                      ? 'Payment confirmed'
                      : order.status == 'pending'
                      ? 'Awaiting payment confirmation'
                      : 'Payment ${order.status}',
                  message: order.paid
                      ? 'Your payment has been verified and your placement order is saved.'
                      : order.status == 'pending'
                      ? 'Complete payment in your browser, then return to this app and check payment. Your order is marked paid only after verification.'
                      : 'No confirmed payment is recorded for this attempt. Check the status before trying checkout again.',
                ),
                const SizedBox(height: AppSpace.lg),
                if (_error != null) ...[
                  InlineMessage(tone: MessageTone.danger, message: _error!),
                  const SizedBox(height: AppSpace.md),
                ],
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Order reference'),
                      SelectableText(order.id),
                      const SizedBox(height: AppSpace.md),
                      KeyValueRow(
                        label: 'Payment method',
                        value: order.provider == 'paypal' ? 'PayPal' : 'Stripe',
                      ),
                      KeyValueRow(
                        label: 'Total (USD)',
                        value: Formatters.formatCurrency(order.totalCents),
                        emphasis: true,
                      ),
                      if (order.paidAt != null)
                        KeyValueRow(
                          label: 'Paid',
                          value: Formatters.formatDate(order.paidAt),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpace.lg),
                for (final item in order.items) ...[
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Formatters.cleanDomain(item.domain ?? 'Publication'),
                        ),
                        Text(
                          item.writingWords == 0
                              ? 'Link only'
                              : 'Link + ${item.writingWords}-word article',
                        ),
                        Text(Formatters.formatCurrency(item.totalCents)),
                        if (item.brief != null)
                          Text(
                            '${item.brief!.keyword}\n${item.brief!.promotedUrl}',
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpace.md),
                ],
                if (!order.paid) ...[
                  AppButton(
                    label: 'Check payment',
                    icon: Icons.refresh,
                    loading: _checking,
                    onPressed: _checking ? null : _check,
                  ),
                  if (widget.redirect != null && order.status == 'pending')
                    TextButton(
                      onPressed: _checking ? null : _openPayment,
                      child: const Text('Open payment again'),
                    ),
                ],
                TextButton(
                  onPressed: () => context.go('/orders'),
                  child: const Text('View all orders'),
                ),
                TextButton(
                  onPressed: () =>
                      context.go(order.paid ? '/marketplace' : '/checkout'),
                  child: Text(
                    order.paid ? 'Browse publications' : 'Back to checkout',
                  ),
                ),
              ],
            ),
    );
  }
}
