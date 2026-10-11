import '../../cart/models/cart.dart';
import 'payment.dart';

class BillingDetails {
  final String email;
  final String firstName;
  final String lastName;
  final String country;
  final String street;
  final String apartment;
  final String city;
  final String region;
  final String postalCode;
  final String phone;

  BillingDetails({
    this.email = '',
    this.firstName = '',
    this.lastName = '',
    this.country = 'US',
    this.street = '',
    this.apartment = '',
    this.city = '',
    this.region = '',
    this.postalCode = '',
    this.phone = '',
  });

  factory BillingDetails.fromJson(Map<String, dynamic> json) {
    return BillingDetails(
      email: json['email'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      country: json['country'] as String? ?? 'US',
      street: json['street'] as String? ?? '',
      apartment: json['apartment'] as String? ?? '',
      city: json['city'] as String? ?? '',
      region: json['region'] as String? ?? '',
      postalCode: json['postalCode'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'country': country,
      'street': street,
      'apartment': apartment,
      'city': city,
      'region': region,
      'postalCode': postalCode,
      'phone': phone,
    };
  }

  BillingDetails copyWith({
    String? email,
    String? firstName,
    String? lastName,
    String? country,
    String? street,
    String? apartment,
    String? city,
    String? region,
    String? postalCode,
    String? phone,
  }) {
    return BillingDetails(
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      country: country ?? this.country,
      street: street ?? this.street,
      apartment: apartment ?? this.apartment,
      city: city ?? this.city,
      region: region ?? this.region,
      postalCode: postalCode ?? this.postalCode,
      phone: phone ?? this.phone,
    );
  }
}

class CheckoutDraft {
  final int version;
  final int cartVersion;
  final BillingDetails billing;
  final String notes;
  final String paymentPreference; // 'stripe' or 'paypal'
  final String? updatedAt;
  final String? expiresAt;

  CheckoutDraft({
    required this.version,
    required this.cartVersion,
    required this.billing,
    required this.notes,
    required this.paymentPreference,
    this.updatedAt,
    this.expiresAt,
  });

  factory CheckoutDraft.fromJson(Map<String, dynamic> json) {
    return CheckoutDraft(
      version: (json['version'] as num?)?.toInt() ?? 0,
      cartVersion: (json['cartVersion'] as num?)?.toInt() ?? 0,
      billing: json['billing'] != null
          ? BillingDetails.fromJson(json['billing'] as Map<String, dynamic>)
          : BillingDetails(),
      notes: json['notes'] as String? ?? '',
      paymentPreference: json['paymentPreference'] as String? ?? 'stripe',
      updatedAt: json['updatedAt'] as String?,
      expiresAt: json['expiresAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'cartVersion': cartVersion,
      'billing': billing.toJson(),
      'notes': notes,
      'paymentPreference': paymentPreference,
    };
  }
}

class CheckoutView {
  final CheckoutDraft? draft;
  final CartView cart;
  final List<String> issues;
  final bool paymentAvailable;
  final bool orderSubmissionAvailable;
  final PaymentMethods paymentMethods;
  final List<({String code, String name})> billingCountries;

  CheckoutView({
    this.draft,
    required this.cart,
    required this.issues,
    this.paymentAvailable = false,
    this.orderSubmissionAvailable = false,
    this.paymentMethods = const PaymentMethods(),
    this.billingCountries = const [],
  });

  factory CheckoutView.fromJson(Map<String, dynamic> json) {
    final issuesList = json['issues'] as List? ?? [];
    return CheckoutView(
      draft: json['draft'] != null && json['draft'] is Map<String, dynamic>
          ? CheckoutDraft.fromJson(json['draft'] as Map<String, dynamic>)
          : null,
      cart: json['cart'] != null && json['cart'] is Map<String, dynamic>
          ? CartView.fromJson(json['cart'] as Map<String, dynamic>)
          : CartView.empty(),
      issues: issuesList.map((e) => e.toString()).toList(),
      paymentAvailable: json['paymentAvailable'] as bool? ?? false,
      orderSubmissionAvailable:
          json['orderSubmissionAvailable'] as bool? ?? false,
      paymentMethods: PaymentMethods.fromJson(
        json['paymentMethods'] as Map<String, dynamic>?,
      ),
      billingCountries: (json['billingCountries'] as List? ?? [])
          .map(
            (value) =>
                (code: value['code'] as String, name: value['name'] as String),
          )
          .toList(),
    );
  }
}
