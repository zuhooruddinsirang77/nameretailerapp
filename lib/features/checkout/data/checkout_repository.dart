import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/checkout.dart';

class CheckoutRepository {
  final ApiClient _apiClient;

  CheckoutRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<CheckoutView> getCheckout() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.checkout);
      return CheckoutView.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiException(_apiClient.extractErrorMessage(e));
    }
  }

  Future<CheckoutView> deleteDraft() async {
    try {
      await _apiClient.dio.delete(ApiConstants.checkout);
      return getCheckout();
    } catch (error) {
      throw ApiException(_apiClient.extractErrorMessage(error));
    }
  }

  Future<CheckoutView> saveCheckoutDraft({
    required int version,
    required int cartVersion,
    required BillingDetails billing,
    required String notes,
    required String paymentPreference,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        ApiConstants.checkout,
        data: {
          'version': version,
          'cartVersion': cartVersion,
          'billing': billing.toJson(),
          'notes': notes.trim(),
          'paymentPreference': paymentPreference,
        },
      );
      return CheckoutView.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiException(_apiClient.extractErrorMessage(e));
    }
  }
}
