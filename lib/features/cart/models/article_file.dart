class ArticleFile {
  const ArticleFile({
    required this.id,
    required this.name,
    required this.size,
    required this.expiresAt,
  });
  final String id;
  final String name;
  final int size;
  final DateTime expiresAt;

  bool get available => expiresAt.isAfter(DateTime.now());

  factory ArticleFile.fromJson(Map<String, dynamic> json) => ArticleFile(
    id: json['id'] as String,
    name: json['name'] as String,
    size: (json['size'] as num).toInt(),
    expiresAt: DateTime.parse(json['expiresAt'] as String),
  );
}
