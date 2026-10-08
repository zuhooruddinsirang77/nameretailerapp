class ProductFacets {
  final List<String> countries;
  final List<String> languages;
  final List<String> categories;

  ProductFacets({
    required this.countries,
    required this.languages,
    required this.categories,
  });

  factory ProductFacets.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic val) {
      if (val is List) {
        return val.map((e) => e.toString()).toList();
      }
      return [];
    }

    return ProductFacets(
      countries: parseList(json['countries']),
      languages: parseList(json['languages']),
      categories: parseList(json['categories']),
    );
  }

  factory ProductFacets.empty() {
    return ProductFacets(
      countries: [],
      languages: [],
      categories: [],
    );
  }
}
