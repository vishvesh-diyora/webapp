class PublishUsernameCheckResult {
  const PublishUsernameCheckResult({
    required this.isAvailable,
    this.message,
  });

  final bool isAvailable;
  final String? message;
}
