import '../../marketplace/models/placement_options.dart';
import 'article_file.dart';
import 'brief_validation.dart';

class PlacementBrief {
  final String promotedUrl;
  final String keyword;
  final String specialRequirements;
  final String articleText;
  final String? fileId;

  PlacementBrief({
    this.promotedUrl = '',
    this.keyword = '',
    this.specialRequirements = '',
    this.articleText = '',
    this.fileId,
  });

  factory PlacementBrief.fromJson(Map<String, dynamic> json) {
    return PlacementBrief(
      promotedUrl: json['promotedUrl'] as String? ?? '',
      keyword: json['keyword'] as String? ?? '',
      specialRequirements: json['specialRequirements'] as String? ?? '',
      articleText: json['articleText'] as String? ?? '',
      fileId: json['fileId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'promotedUrl': promotedUrl,
      'keyword': keyword,
      'specialRequirements': specialRequirements,
      'articleText': articleText,
      'fileId': fileId,
    };
  }

  PlacementBrief copyWith({
    String? promotedUrl,
    String? keyword,
    String? specialRequirements,
    String? articleText,
    String? fileId,
  }) {
    return PlacementBrief(
      promotedUrl: promotedUrl ?? this.promotedUrl,
      keyword: keyword ?? this.keyword,
      specialRequirements: specialRequirements ?? this.specialRequirements,
      articleText: articleText ?? this.articleText,
      fileId: fileId ?? this.fileId,
    );
  }
}

class CartItem {
  String? get issue {
    if (status == 'unavailable') {
      return 'This publication is no longer available.';
    }
    if (status == 'changed') {
      return 'Pricing or terms changed. Review and save the brief again.';
    }
    final value = brief;
    if (value == null) return 'Complete the placement brief.';
    if (validatePromotedUrl(value.promotedUrl) != null ||
        value.keyword.trim().isEmpty) {
      return 'Complete the destination URL and keyword.';
    }
    if (value.fileId != null && !(file?.available ?? false)) {
      return 'Your article file expired or is unavailable. Upload it again.';
    }
    if (writingWords == 0 &&
        value.articleText.trim().isEmpty &&
        !(file?.available ?? false)) {
      return 'Supply article text or an available article file.';
    }
    if (writingWords != 0 && value.articleText.trim().isEmpty) {
      return 'Add an article brief for the writing package.';
    }
    return null;
  }

  final String productId;
  final int productVersion;
  final int writingWords; // 0, 500, 750, 1000
  final String? domain;
  final int? placementCents;
  final int? writingCents;
  final int? totalCents;
  final String status; // 'ready', 'changed', 'unavailable'
  final PlacementOptions? options;
  final PlacementBrief? brief;
  final ArticleFile? file;

  CartItem({
    required this.productId,
    required this.productVersion,
    required this.writingWords,
    this.domain,
    this.placementCents,
    this.writingCents,
    this.totalCents,
    this.status = 'ready',
    this.options,
    this.brief,
    this.file,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'] as String? ?? '',
      productVersion: (json['productVersion'] as num?)?.toInt() ?? 1,
      writingWords: (json['writingWords'] as num?)?.toInt() ?? 0,
      domain: json['domain'] as String?,
      placementCents: (json['placementCents'] as num?)?.toInt(),
      writingCents: (json['writingCents'] as num?)?.toInt(),
      totalCents: (json['totalCents'] as num?)?.toInt(),
      status: json['status'] as String? ?? 'ready',
      options:
          json['options'] != null && json['options'] is Map<String, dynamic>
          ? PlacementOptions.fromJson(json['options'] as Map<String, dynamic>)
          : null,
      brief: json['brief'] != null && json['brief'] is Map<String, dynamic>
          ? PlacementBrief.fromJson(json['brief'] as Map<String, dynamic>)
          : null,
      file: json['file'] is Map<String, dynamic>
          ? ArticleFile.fromJson(json['file'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toSelectionJson() {
    return {
      'productId': productId,
      'productVersion': productVersion,
      'writingWords': writingWords,
      if (brief != null) 'brief': brief!.toJson(),
    };
  }
}

class CartView {
  final int version;
  final String currency;
  final List<CartItem> items;
  final int? totalCents;
  final bool checkoutAvailable;

  CartView({
    required this.version,
    this.currency = 'USD',
    required this.items,
    this.totalCents,
    this.checkoutAvailable = false,
  });

  factory CartView.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List? ?? [];
    return CartView(
      version: (json['version'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'USD',
      items: rawItems
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalCents: (json['totalCents'] as num?)?.toInt(),
      checkoutAvailable: json['checkoutAvailable'] as bool? ?? false,
    );
  }

  factory CartView.empty() {
    return CartView(
      version: 0,
      currency: 'USD',
      items: [],
      totalCents: 0,
      checkoutAvailable: false,
    );
  }
}
