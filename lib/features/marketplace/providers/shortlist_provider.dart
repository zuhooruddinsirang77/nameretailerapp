import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/storage/storage_service.dart';
import '../models/product.dart';

class ShortlistNotifier extends StateNotifier<List<Product>> {
  final StorageService _storageService;

  ShortlistNotifier(this._storageService) : super([]) {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    // We keep in-memory product items that have been shortlisted
  }

  bool isShortlisted(String productId) {
    return state.any((item) => item.id == productId);
  }

  void toggle(Product product) {
    if (isShortlisted(product.id)) {
      state = state.where((item) => item.id != product.id).toList();
    } else {
      if (state.length >= 8) {
        // limit to 8 for comparison focus
        state = [...state.sublist(1), product];
      } else {
        state = [...state, product];
      }
    }
    _saveToStorage();
  }

  void remove(String productId) {
    state = state.where((item) => item.id != productId).toList();
    _saveToStorage();
  }

  void clear() {
    state = [];
    _saveToStorage();
  }

  void _saveToStorage() {
    final ids = state.map((item) => item.id).toList();
    _storageService.saveShortlist(ids);
  }
}

final shortlistProvider =
    StateNotifierProvider<ShortlistNotifier, List<Product>>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return ShortlistNotifier(storageService);
});
