import '../data/product_repository.dart';

const Object _keep = Object();

/// `ProductFilterParams.copyWith` treats `null` as "keep the old value", so it
/// cannot clear a filter. These helpers let the UI explicitly set or clear
/// individual criteria without changing the data layer.
extension ProductFilterEditing on ProductFilterParams {
  /// Pass a value to set a criterion, pass `null` to clear it, omit to keep.
  ProductFilterParams edit({
    Object? query = _keep,
    Object? country = _keep,
    Object? language = _keep,
    Object? category = _keep,
    Object? minDr = _keep,
    Object? maxDr = _keep,
    Object? minDa = _keep,
    Object? maxDa = _keep,
    Object? minTraffic = _keep,
    Object? maxTraffic = _keep,
    Object? minPrice = _keep,
    Object? maxPrice = _keep,
    String? sort,
    int? page,
  }) {
    T? pick<T>(Object? v, T? current) =>
        identical(v, _keep) ? current : v as T?;

    return ProductFilterParams(
      query: pick<String>(query, this.query),
      country: pick<String>(country, this.country),
      language: pick<String>(language, this.language),
      category: pick<String>(category, this.category),
      minDr: pick<int>(minDr, this.minDr),
      maxDr: pick<int>(maxDr, this.maxDr),
      minDa: pick<int>(minDa, this.minDa),
      maxDa: pick<int>(maxDa, this.maxDa),
      minTraffic: pick<int>(minTraffic, this.minTraffic),
      maxTraffic: pick<int>(maxTraffic, this.maxTraffic),
      minPrice: pick<double>(minPrice, this.minPrice),
      maxPrice: pick<double>(maxPrice, this.maxPrice),
      sort: sort ?? this.sort,
      page: page ?? this.page,
      pageSize: pageSize,
    );
  }

  /// Number of active criteria excluding the free-text query (for the filter
  /// button badge).
  int get activeFilterCount {
    var n = 0;
    if (country != null && country!.isNotEmpty) n++;
    if (language != null && language!.isNotEmpty) n++;
    if (category != null && category!.isNotEmpty) n++;
    if (minDr != null || maxDr != null) n++;
    if (minDa != null || maxDa != null) n++;
    if (minTraffic != null || maxTraffic != null) n++;
    if (minPrice != null || maxPrice != null) n++;
    return n;
  }
}
