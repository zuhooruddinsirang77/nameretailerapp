import '../../cart/models/cart.dart';

class PaymentMethods {
  const PaymentMethods({this.stripe = false, this.paypal = false});
  final bool stripe, paypal;
  bool available(String provider) =>
      provider == 'stripe' ? stripe : provider == 'paypal' && paypal;
  factory PaymentMethods.fromJson(Map<String, dynamic>? json) => PaymentMethods(
    stripe: json?['stripe'] == true,
    paypal: json?['paypal'] == true,
  );
}

class PaymentRedirect {
  const PaymentRedirect({required this.orderId, required this.url});
  final String orderId, url;
  factory PaymentRedirect.fromJson(Map<String, dynamic> json) =>
      PaymentRedirect(
        orderId: json['orderId'] as String,
        url: json['url'] as String,
      );
}

class CustomerOrder {
  const CustomerOrder({
    required this.id,
    required this.provider,
    required this.status,
    required this.totalCents,
    required this.items,
    required this.createdAt,
    this.paidAt,
  });
  final String id, provider, status, createdAt;
  final int totalCents;
  final List<CartItem> items;
  final String? paidAt;
  bool get paid => status == 'paid';
  factory CustomerOrder.fromJson(Map<String, dynamic> json) => CustomerOrder(
    id: json['id'] as String,
    provider: json['provider'] as String,
    status: json['status'] as String,
    totalCents: (json['totalCents'] as num).toInt(),
    createdAt: json['createdAt'] as String,
    paidAt: json['paidAt'] as String?,
    items: (json['items'] as List)
        .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
        .toList(),
  );
}
