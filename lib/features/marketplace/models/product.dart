class ProductMetrics {
  final int? da;
  final int? dr;
  final int? tf;
  final int? ur;
  final int? traffic;
  final int? referringDomains;
  final int? backlinks;
  final int? spamScore;

  ProductMetrics({
    this.da,
    this.dr,
    this.tf,
    this.ur,
    this.traffic,
    this.referringDomains,
    this.backlinks,
    this.spamScore,
  });

  factory ProductMetrics.fromJson(Map<String, dynamic> json) {
    return ProductMetrics(
      da: (json['da'] as num?)?.toInt(),
      dr: (json['dr'] as num?)?.toInt(),
      tf: (json['tf'] as num?)?.toInt(),
      ur: (json['ur'] as num?)?.toInt(),
      traffic: (json['traffic'] as num?)?.toInt(),
      referringDomains: (json['referringDomains'] as num?)?.toInt(),
      backlinks: (json['backlinks'] as num?)?.toInt(),
      spamScore: (json['spamScore'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'da': da,
      'dr': dr,
      'tf': tf,
      'ur': ur,
      'traffic': traffic,
      'referringDomains': referringDomains,
      'backlinks': backlinks,
      'spamScore': spamScore,
    };
  }
}

class Product {
  final String id;
  final String domain;
  final String language;
  final String country;
  final String category;
  final int priceCents;
  final String currency;
  final String status;
  final ProductMetrics metrics;
  final String linkType;
  final String turnaround;
  final String requirements;
  final int version;
  final String? createdAt;
  final String? updatedAt;

  Product({
    required this.id,
    required this.domain,
    required this.language,
    required this.country,
    required this.category,
    required this.priceCents,
    required this.currency,
    required this.status,
    required this.metrics,
    required this.linkType,
    required this.turnaround,
    required this.requirements,
    required this.version,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String? ?? '',
      domain: json['domain'] as String? ?? '',
      language: json['language'] as String? ?? 'English',
      country: json['country'] as String? ?? 'United States',
      category: json['category'] as String? ?? 'General',
      priceCents: (json['priceCents'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'USD',
      status: json['status'] as String? ?? 'active',
      metrics: json['metrics'] != null && json['metrics'] is Map<String, dynamic>
          ? ProductMetrics.fromJson(json['metrics'] as Map<String, dynamic>)
          : ProductMetrics(),
      linkType: json['linkType'] as String? ?? 'DoFollow',
      turnaround: json['turnaround'] as String? ?? '3-5 days',
      requirements: json['requirements'] as String? ?? '',
      version: (json['version'] as num?)?.toInt() ?? 1,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'domain': domain,
      'language': language,
      'country': country,
      'category': category,
      'priceCents': priceCents,
      'currency': currency,
      'status': status,
      'metrics': metrics.toJson(),
      'linkType': linkType,
      'turnaround': turnaround,
      'requirements': requirements,
      'version': version,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }
}

class ProductPage {
  final List<Product> data;
  final int total;
  final int page;
  final int pageSize;

  ProductPage({
    required this.data,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory ProductPage.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List? ?? [];
    return ProductPage(
      data: list.map((item) => Product.fromJson(item as Map<String, dynamic>)).toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 20,
    );
  }
}
