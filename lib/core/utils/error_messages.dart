import '../network/api_client.dart';

/// User-facing description of a failure.
class FriendlyError {
  const FriendlyError({
    required this.title,
    required this.message,
    this.offline = false,
  });

  final String title;
  final String message;

  /// True when the failure looks like missing connectivity / timeout.
  final bool offline;
}

/// Maps any thrown object to copy that is safe to show to a customer. Raw
/// exception text is never shown for unexpected error types.
FriendlyError describeError(Object? error) {
  final raw = error is ApiException ? error.message : error?.toString() ?? '';
  final lower = raw.toLowerCase();

  final looksOffline =
      lower.contains('timed out') ||
      lower.contains('unable to connect') ||
      lower.contains('connection') ||
      lower.contains('socket') ||
      lower.contains('internet') ||
      lower.contains('network');

  if (looksOffline) {
    return const FriendlyError(
      title: 'You appear to be offline',
      message:
          'We could not reach NameRetailer. Check your connection and try again.',
      offline: true,
    );
  }

  if (error is ApiException && raw.trim().isNotEmpty) {
    return FriendlyError(title: 'Something went wrong', message: raw);
  }

  return const FriendlyError(
    title: 'Something went wrong',
    message: 'We could not load this right now. Please try again in a moment.',
  );
}
