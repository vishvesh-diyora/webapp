import 'package:equatable/equatable.dart';

class CloudflareTokens extends Equatable {
  const CloudflareTokens({
    required this.accessToken,
    this.refreshToken,
    this.expiresAt,
    this.accountId,
  });

  final String accessToken;
  final String? refreshToken;
  final DateTime? expiresAt;
  final String? accountId;

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!.subtract(const Duration(minutes: 2)));
  }

  CloudflareTokens copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
    String? accountId,
  }) {
    return CloudflareTokens(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      accountId: accountId ?? this.accountId,
    );
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        if (refreshToken != null) 'refreshToken': refreshToken,
        if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
        if (accountId != null) 'accountId': accountId,
      };

  factory CloudflareTokens.fromJson(Map<String, dynamic> json) {
    return CloudflareTokens(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String?,
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'] as String)
          : null,
      accountId: json['accountId'] as String?,
    );
  }

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresAt, accountId];
}
