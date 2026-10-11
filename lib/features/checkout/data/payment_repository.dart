import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/providers/core_providers.dart';
import '../models/payment.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>(
  (ref) => PaymentRepository(ref.watch(apiClientProvider)),
);
final paymentBrowserProvider = Provider<Future<bool> Function(Uri)>(
  (ref) =>
      (uri) => launchUrl(uri, mode: LaunchMode.externalApplication),
);
final ordersProvider = FutureProvider.autoDispose<List<CustomerOrder>>(
  (ref) => ref.watch(paymentRepositoryProvider).listOrders(),
);

Uri? paymentBrowserUri(String value, String provider) {
  final uri = Uri.tryParse(value);
  if (uri == null ||
      uri.scheme != 'https' ||
      uri.userInfo.isNotEmpty ||
      (uri.hasPort && uri.port != 443)) {
    return null;
  }
  final hosts = provider == 'stripe'
      ? ['checkout.stripe.com']
      : provider == 'paypal'
      ? ['www.paypal.com', 'www.sandbox.paypal.com']
      : <String>[];
  return hosts.contains(uri.host) ? uri : null;
}

class PaymentRepository {
  PaymentRepository(this._client);
  final ApiClient _client;
  Future<PaymentRedirect> start({
    required int cartVersion,
    required int draftVersion,
    required String provider,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.payments,
        data: {
          'cartVersion': cartVersion,
          'draftVersion': draftVersion,
          'provider': provider,
          'termsAccepted': true,
        },
      );
      return PaymentRedirect.fromJson(response.data as Map<String, dynamic>);
    } catch (error) {
      throw ApiException(_client.extractErrorMessage(error));
    }
  }

  Future<CustomerOrder> confirm(String id) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.confirmPayment,
        data: {'orderId': id},
      );
      return CustomerOrder.fromJson(response.data as Map<String, dynamic>);
    } catch (error) {
      throw ApiException(_client.extractErrorMessage(error));
    }
  }

  Future<CustomerOrder> getOrder(String id) async {
    try {
      final response = await _client.dio.get('${ApiConstants.orders}$id/');
      return CustomerOrder.fromJson(response.data as Map<String, dynamic>);
    } catch (error) {
      throw ApiException(_client.extractErrorMessage(error));
    }
  }

  Future<List<CustomerOrder>> listOrders() async {
    try {
      final response = await _client.dio.get(ApiConstants.orders);
      return (response.data as List)
          .map((value) => CustomerOrder.fromJson(value as Map<String, dynamic>))
          .toList();
    } catch (error) {
      throw ApiException(_client.extractErrorMessage(error));
    }
  }
}
