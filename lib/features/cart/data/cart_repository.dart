import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/cart.dart';

class CartRepository {
  final ApiClient _apiClient;

  CartRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<CartView> getCart() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.cart);
      return CartView.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiException(_apiClient.extractErrorMessage(e));
    }
  }

  Future<CartView> saveItem({
    required CartItem item,
    required int cartVersion,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        ApiConstants.cart,
        data: {'version': cartVersion, 'item': item.toSelectionJson()},
      );
      return CartView.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiException(_apiClient.extractErrorMessage(e));
    }
  }

  Future<CartView> removeItem({
    required String productId,
    required int cartVersion,
  }) async {
    try {
      final response = await _apiClient.dio.delete(
        ApiConstants.cart,
        data: {'version': cartVersion, 'productId': productId},
      );
      return CartView.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiException(_apiClient.extractErrorMessage(e));
    }
  }
}
