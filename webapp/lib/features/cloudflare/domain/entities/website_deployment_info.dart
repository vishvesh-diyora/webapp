import 'package:equatable/equatable.dart';

/// Cloudflare deployment metadata stored in Supabase (not in published content.json).
class WebsiteDeploymentInfo extends Equatable {
  const WebsiteDeploymentInfo({
    required this.publishedUrl,
    required this.projectName,
    required this.projectId,
    required this.deploymentId,
    required this.accountId,
    this.updatedAt,
  });

  final String publishedUrl;
  final String projectName;
  final String projectId;
  final String deploymentId;
  final String accountId;
  final DateTime? updatedAt;

  factory WebsiteDeploymentInfo.fromJson(Map<String, dynamic> json) {
    return WebsiteDeploymentInfo(
      publishedUrl: json['publishedUrl'] as String? ?? '',
      projectName: json['projectName'] as String? ?? '',
      projectId: json['projectId'] as String? ?? '',
      deploymentId: json['deploymentId'] as String? ?? '',
      accountId: json['accountId'] as String? ?? '',
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'publishedUrl': publishedUrl,
        'projectName': projectName,
        'projectId': projectId,
        'deploymentId': deploymentId,
        'accountId': accountId,
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };

  WebsiteDeploymentInfo copyWith({
    String? publishedUrl,
    String? projectName,
    String? projectId,
    String? deploymentId,
    String? accountId,
    DateTime? updatedAt,
  }) {
    return WebsiteDeploymentInfo(
      publishedUrl: publishedUrl ?? this.publishedUrl,
      projectName: projectName ?? this.projectName,
      projectId: projectId ?? this.projectId,
      deploymentId: deploymentId ?? this.deploymentId,
      accountId: accountId ?? this.accountId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props =>
      [publishedUrl, projectName, projectId, deploymentId, accountId, updatedAt];
}
