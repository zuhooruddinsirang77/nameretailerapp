import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cart/models/cart.dart';
import '../data/checkout_repository.dart';
import '../models/checkout.dart';

final checkoutRepositoryProvider = Provider<CheckoutRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CheckoutRepository(apiClient: apiClient);
});

class CheckoutNotifier extends StateNotifier<AsyncValue<CheckoutView>> {
  final CheckoutRepository _repository;
  final Ref _ref;

  CheckoutNotifier(this._repository, this._ref)
      : super(const AsyncValue.loading()) {
    loadCheckout();
  }

  Future<void> loadCheckout() async {
    final authState = _ref.read(authStateProvider);
    if (!authState.isAuthenticated) {
      state = AsyncValue.data(
        CheckoutView(cart: CartView.empty(), issues: []),
      );
      return;
    }

    state = const AsyncValue.loading();
    try {
      final view = await _repository.getCheckout();
      state = AsyncValue.data(view);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> saveDraft({
    required BillingDetails billing,
    required String notes,
    required String paymentPreference,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return false;

    try {
      final updated = await _repository.saveCheckoutDraft(
        version: current.draft?.version ?? 0,
        cartVersion: current.cart.version,
        billing: billing,
        notes: notes,
        paymentPreference: paymentPreference,
      );
      state = AsyncValue.data(updated);
      return true;
    } catch (e) {
      await loadCheckout();
      return false;
    }
  }
}

final checkoutProvider =
    StateNotifierProvider<CheckoutNotifier, AsyncValue<CheckoutView>>((ref) {
  final repository = ref.watch(checkoutRepositoryProvider);
  return CheckoutNotifier(repository, ref);
});
