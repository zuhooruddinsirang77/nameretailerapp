class ApiConstants {
  // Default to live production deployment with option to override via dart-define
  static const String defaultBaseUrl = 'https://nameretailer.vercel.app';
  static const String localAndroidBaseUrl = 'http://10.0.2.2:3000';
  static const String localIosBaseUrl = 'http://localhost:3000';

  static String baseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: defaultBaseUrl,
  );

  // Auth endpoints
  static const String login = '/api/mobile/auth/login/';
  static const String register = '/api/mobile/auth/register/';
  static const String profile = '/api/mobile/auth/profile/';

  // Product & Marketplace endpoints
  static const String products = '/api/products/';
  static const String facets = '/api/products/facets/';
  static String productDetail(String id) => '/api/mobile/products/$id/';
  static String productOptions(String id) => '/api/products/$id/options/';

  // Cart endpoints
  static const String cart = '/api/mobile/cart/';

  // Checkout endpoints
  static const String checkout = '/api/mobile/checkout/';

  // Inquiry endpoints
  static const String inquiries = '/api/mobile/inquiries/';
}
