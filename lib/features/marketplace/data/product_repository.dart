import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/facets.dart';
import '../models/placement_options.dart';
import '../models/product.dart';

class ProductFilterParams {
  final String? query;
  final String? country;
  final String? language;
  final String? category;
  final int? minDr;
  final int? maxDr;
  final int? minDa;
  final int? maxDa;
  final int? minTraffic;
  final int? maxTraffic;
  final double? minPrice;
  final double? maxPrice;
  final String sort;
  final int page;
  final int pageSize;

  ProductFilterParams({
    this.query,
    this.country,
    this.language,
    this.category,
    this.minDr,
    this.maxDr,
    this.minDa,
    this.maxDa,
    this.minTraffic,
    this.maxTraffic,
    this.minPrice,
    this.maxPrice,
    this.sort = 'domain',
    this.page = 1,
    this.pageSize = 20,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      'sort': sort,
    };

    if (query != null && query!.trim().isNotEmpty) {
      params['q'] = query!.trim();
    }
    if (country != null && country!.isNotEmpty) {
      params['country'] = country;
    }
    if (language != null && language!.isNotEmpty) {
      params['language'] = language;
    }
    if (category != null && category!.isNotEmpty) {
      params['category'] = category;
    }
    if (minDr != null) params['minDr'] = minDr;
    if (maxDr != null) params['maxDr'] = maxDr;
    if (minDa != null) params['minDa'] = minDa;
    if (maxDa != null) params['maxDa'] = maxDa;
    if (minTraffic != null) params['minTraffic'] = minTraffic;
    if (maxTraffic != null) params['maxTraffic'] = maxTraffic;
    if (minPrice != null) params['minPrice'] = minPrice!.toStringAsFixed(0);
    if (maxPrice != null) params['maxPrice'] = maxPrice!.toStringAsFixed(0);

    return params;
  }

  ProductFilterParams copyWith({
    String? query,
    String? country,
    String? language,
    String? category,
    int? minDr,
    int? maxDr,
    int? minDa,
    int? maxDa,
    int? minTraffic,
    int? maxTraffic,
    double? minPrice,
    double? maxPrice,
    String? sort,
    int? page,
    int? pageSize,
  }) {
    return ProductFilterParams(
      query: query ?? this.query,
      country: country ?? this.country,
      language: language ?? this.language,
      category: category ?? this.category,
      minDr: minDr ?? this.minDr,
      maxDr: maxDr ?? this.maxDr,
      minDa: minDa ?? this.minDa,
      maxDa: maxDa ?? this.maxDa,
      minTraffic: minTraffic ?? this.minTraffic,
      maxTraffic: maxTraffic ?? this.maxTraffic,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      sort: sort ?? this.sort,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  bool get hasActiveFilters {
    return (query != null && query!.trim().isNotEmpty) ||
        (country != null && country!.isNotEmpty) ||
        (language != null && language!.isNotEmpty) ||
        (category != null && category!.isNotEmpty) ||
        minDr != null ||
        maxDr != null ||
        minDa != null ||
        maxDa != null ||
        minTraffic != null ||
        maxTraffic != null ||
        minPrice != null ||
        maxPrice != null;
  }
}

class ProductRepository {
  final ApiClient _apiClient;

  ProductRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<ProductPage> getProducts(ProductFilterParams params) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.products,
        queryParameters: params.toQueryParams(),
      );
      return ProductPage.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiException(_apiClient.extractErrorMessage(e));
    }
  }

  Future<ProductFacets> getFacets() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.facets);
      final data = response.data as Map<String, dynamic>;
      final facetsData = data['data'] as Map<String, dynamic>? ?? {};
      return ProductFacets.fromJson(facetsData);
    } catch (e) {
      throw ApiException(_apiClient.extractErrorMessage(e));
    }
  }

  Future<Map<String, dynamic>> getProductDetail(String id) async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.productDetail(id));
      final data = response.data as Map<String, dynamic>;
      final product = Product.fromJson(data['product'] as Map<String, dynamic>);
      final options = data['options'] != null
          ? PlacementOptions.fromJson(data['options'] as Map<String, dynamic>)
          : null;
      return {
        'product': product,
        'options': options,
      };
    } catch (e) {
      // Robust fallback for live production server
      try {
        final options = await getProductOptions(id);
        final cleanDomain =
            options.domain.replaceFirst(RegExp(r'^https?://'), '');
        final searchRes = await _apiClient.dio.get(
          ApiConstants.products,
          queryParameters: {'q': cleanDomain, 'pageSize': 5},
        );
        final page =
            ProductPage.fromJson(searchRes.data as Map<String, dynamic>);
        final matched = page.data
                .where((p) => p.id == id || p.domain == options.domain)
                .firstOrNull ??
            (page.data.isNotEmpty ? page.data.first : null);

        final product = matched ??
            Product(
              id: options.productId,
              domain: options.domain,
              language: 'English',
              country: 'United States',
              category: 'General',
              priceCents: options.placementCents,
              currency: options.currency,
              status: 'active',
              metrics: ProductMetrics(),
              linkType: options.linkType,
              turnaround: options.turnaround,
              requirements: options.requirements,
              version: options.productVersion,
            );

        return {
          'product': product,
          'options': options,
        };
      } catch (_) {
        throw ApiException(_apiClient.extractErrorMessage(e));
      }
    }
  }

  Future<PlacementOptions> getProductOptions(String productId) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.productOptions(productId),
      );
      return PlacementOptions.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiException(_apiClient.extractErrorMessage(e));
    }
  }
}
