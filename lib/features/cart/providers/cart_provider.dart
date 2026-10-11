import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/cart_repository.dart';
import '../models/cart.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CartRepository(apiClient: apiClient);
});

class CartNotifier extends StateNotifier<AsyncValue<CartView>> {
  final CartRepository _repository;
  final Ref _ref;
  String? lastError;

  CartNotifier(this._repository, this._ref)
    : super(const AsyncValue.loading()) {
    loadCart();
  }

  Future<void> loadCart() async {
    final authState = _ref.read(authStateProvider);
    if (!authState.isAuthenticated) {
      state = AsyncValue.data(CartView.empty());
      return;
    }

    state = const AsyncValue.loading();
    try {
      final cart = await _repository.getCart();
      state = AsyncValue.data(cart);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> saveItem(CartItem item) async {
    lastError = null;
    final current = state.valueOrNull ?? CartView.empty();
    try {
      final updated = await _repository.saveItem(
        item: item,
        cartVersion: current.version,
      );
      state = AsyncValue.data(updated);
      return true;
    } catch (e) {
      lastError = e.toString();
      // Reload on conflict
      await loadCart();
      return false;
    }
  }

  Future<bool> removeItem(String productId) async {
    final current = state.valueOrNull ?? CartView.empty();
    try {
      final updated = await _repository.removeItem(
        productId: productId,
        cartVersion: current.version,
      );
      state = AsyncValue.data(updated);
      return true;
    } catch (e) {
      await loadCart();
      return false;
    }
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, AsyncValue<CartView>>((
  ref,
) {
  final repository = ref.watch(cartRepositoryProvider);
  ref.watch(authStateProvider.select((state) => state.user?.id));
  return CartNotifier(repository, ref);
});

final cartItemCountProvider = Provider<int>((ref) {
  final cartState = ref.watch(cartProvider);
  return cartState.valueOrNull?.items.length ?? 0;
});
