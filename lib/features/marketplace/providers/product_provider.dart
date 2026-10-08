import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../data/product_repository.dart';
import '../models/facets.dart';
import '../models/product.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProductRepository(apiClient: apiClient);
});

final productFilterProvider =
    StateProvider<ProductFilterParams>((ref) => ProductFilterParams());

final productListProvider =
    FutureProvider.autoDispose<ProductPage>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  final params = ref.watch(productFilterProvider);
  return repository.getProducts(params);
});

final facetsProvider = FutureProvider<ProductFacets>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getFacets();
});

final productDetailProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
        (ref, id) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProductDetail(id);
});
