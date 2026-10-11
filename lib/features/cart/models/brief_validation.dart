String? validatePromotedUrl(String? raw) {
  final value = raw?.trim() ?? '';
  final uri = Uri.tryParse(value);
  if (value.length > 2048 ||
      uri == null ||
      !['http', 'https'].contains(uri.scheme.toLowerCase()) ||
      RegExp(r'[\s\\\x00-\x1f\x7f]').hasMatch(value) ||
      uri.userInfo.isNotEmpty ||
      uri.hasPort ||
      !uri.host.contains('.') ||
      RegExp(r'^[\d.]+$').hasMatch(uri.host) ||
      RegExp(
        r'\.(localhost|local|internal|invalid|test|example)$',
        caseSensitive: false,
      ).hasMatch(uri.host) ||
      uri.host
          .split('.')
          .any(
            (label) => !RegExp(
              r'^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?$',
              caseSensitive: false,
            ).hasMatch(label),
          )) {
    return 'Enter a complete public HTTP(S) URL without credentials or a port.';
  }
  return null;
}

String? validateBriefText(
  String? raw, {
  required int max,
  bool required = false,
}) {
  final value = raw?.trim() ?? '';
  if (required && value.isEmpty) return 'This field is required.';
  if (value.length > max) return 'Use at most $max characters.';
  if (RegExp(
    r'[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]|</?[a-z!][^>]*>',
    caseSensitive: false,
  ).hasMatch(value)) {
    return 'Use plain text without HTML or control characters.';
  }
  return null;
}
