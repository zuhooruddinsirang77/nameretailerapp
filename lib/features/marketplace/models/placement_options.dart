class WritingOption {
  final int words;
  final int priceCents;

  WritingOption({
    required this.words,
    required this.priceCents,
  });

  factory WritingOption.fromJson(Map<String, dynamic> json) {
    return WritingOption(
      words: (json['words'] as num?)?.toInt() ?? 500,
      priceCents: (json['priceCents'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'words': words,
      'priceCents': priceCents,
    };
  }
}

class PlacementOptions {
  final String productId;
  final int productVersion;
  final String domain;
  final int placementCents;
  final String currency;
  final List<WritingOption> writingOptions;
  final String requirements;
  final String turnaround;
  final String linkType;

  PlacementOptions({
    required this.productId,
    required this.productVersion,
    required this.domain,
    required this.placementCents,
    required this.currency,
    required this.writingOptions,
    required this.requirements,
    required this.turnaround,
    required this.linkType,
  });

  factory PlacementOptions.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['writingOptions'] as List? ?? [];
    return PlacementOptions(
      productId: json['productId'] as String? ?? '',
      productVersion: (json['productVersion'] as num?)?.toInt() ?? 1,
      domain: json['domain'] as String? ?? '',
      placementCents: (json['placementCents'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'USD',
      writingOptions: rawOptions
          .map((opt) => WritingOption.fromJson(opt as Map<String, dynamic>))
          .toList(),
      requirements: json['requirements'] as String? ?? '',
      turnaround: json['turnaround'] as String? ?? '',
      linkType: json['linkType'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productVersion': productVersion,
      'domain': domain,
      'placementCents': placementCents,
      'currency': currency,
      'writingOptions': writingOptions.map((o) => o.toJson()).toList(),
      'requirements': requirements,
      'turnaround': turnaround,
      'linkType': linkType,
    };
  }
}
