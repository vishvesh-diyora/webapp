import 'dart:convert';

/// Runtime settings for the exported static site.
/// Secrets (admin password, GitHub token) come from **Firebase Remote Config**, not hosted files.
class ExportRuntimeConfig {
  const ExportRuntimeConfig({
    required this.siteDataUrl,
    required this.adminUsername,
    required this.adminPassword,
    this.github,
    this.secretsFromFirebase = false,
  });

  final String siteDataUrl;
  final String adminUsername;
  final String adminPassword;
  final ExportGithubConfig? github;
  final bool secretsFromFirebase;

  factory ExportRuntimeConfig.fromJson(Map<String, dynamic> json) {
    final githubRaw = json['github'];
    return ExportRuntimeConfig(
      siteDataUrl: json['siteDataUrl'] as String? ?? 'site.json',
      adminUsername: json['adminUsername'] as String? ?? '',
      adminPassword: json['adminPassword'] as String? ?? '',
      github: githubRaw is Map<String, dynamic>
          ? ExportGithubConfig.fromJson(githubRaw)
          : null,
      secretsFromFirebase: false,
    );
  }

  /// Shipped in the ZIP — no passwords or tokens.
  Map<String, dynamic> toDeployJson() => {
        'siteDataUrl': siteDataUrl,
      };

  Map<String, dynamic> toJson() => {
        'siteDataUrl': siteDataUrl,
        'adminUsername': adminUsername,
        'adminPassword': adminPassword,
        if (github != null) 'github': github!.toJson(),
      };

  static ExportRuntimeConfig deployDefaults = const ExportRuntimeConfig(
    siteDataUrl: 'site.json',
    adminUsername: '',
    adminPassword: '',
    github: null,
  );

  static ExportRuntimeConfig parse(String body) =>
      ExportRuntimeConfig.fromJson(jsonDecode(body) as Map<String, dynamic>);
}

class ExportGithubConfig {
  const ExportGithubConfig({
    required this.owner,
    required this.repo,
    required this.branch,
    required this.siteJsonPath,
    required this.mediaFolder,
    required this.token,
  });

  final String owner;
  final String repo;
  final String branch;
  final String siteJsonPath;
  final String mediaFolder;
  final String token;

  bool get isConfigured =>
      owner.isNotEmpty &&
      !owner.startsWith('YOUR_') &&
      repo.isNotEmpty &&
      !repo.startsWith('YOUR_') &&
      token.isNotEmpty &&
      !token.startsWith('ghp_YOUR');

  factory ExportGithubConfig.fromJson(Map<String, dynamic> json) {
    return ExportGithubConfig(
      owner: json['owner'] as String? ?? '',
      repo: json['repo'] as String? ?? '',
      branch: json['branch'] as String? ?? 'main',
      siteJsonPath: json['siteJsonPath'] as String? ?? 'site.json',
      mediaFolder: json['mediaFolder'] as String? ?? 'media',
      token: json['token'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'owner': owner,
        'repo': repo,
        'branch': branch,
        'siteJsonPath': siteJsonPath,
        'mediaFolder': mediaFolder,
        'token': token,
      };
}
