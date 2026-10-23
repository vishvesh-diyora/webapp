import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:web/web.dart' as web;
import 'package:webapp/features/export_admin/export_firebase_web_config.dart';
import 'package:webapp/features/export_admin/export_runtime_config.dart';

/// Remote Config parameter keys (set values in Firebase Console → Remote Config).
abstract final class ExportRemoteConfigKeys {
  static const adminUsername = 'admin_username';
  static const adminPassword = 'admin_password';
  static const siteDataUrl = 'site_data_url';
  static const githubOwner = 'github_owner';
  static const githubRepo = 'github_repo';
  static const githubBranch = 'github_branch';
  static const githubToken = 'github_token';
  static const githubSiteJsonPath = 'github_site_json_path';
  static const githubMediaFolder = 'github_media_folder';
}

Future<ExportRuntimeConfig?> tryLoadConfigFromFirebaseRemote(
  ExportFirebaseWebConfig webConfig, {
  String siteDataUrlFallback = 'site.json',
}) async {
  if (!webConfig.isConfigured) return null;

  final appInstanceId = _stableAppInstanceId();
  final uri = Uri.parse(
    'https://firebaseremoteconfig.googleapis.com/v1/projects/${webConfig.projectId}/namespaces/firebase:fetch',
  ).replace(queryParameters: {'key': webConfig.apiKey});

  final response = await http.post(
    uri,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'appId': webConfig.appId,
      'appInstanceId': appInstanceId,
    }),
  );

  if (response.statusCode != 200) {
    throw StateError(
      'Remote Config fetch failed (${response.statusCode}): ${response.body}',
    );
  }

  final decoded = jsonDecode(response.body) as Map<String, dynamic>;
  final entriesRaw = decoded['entries'];
  final entries = entriesRaw is Map
      ? Map<String, dynamic>.from(entriesRaw)
      : <String, dynamic>{};

  String param(String key, {String fallback = ''}) {
    final raw = entries[key];
    if (raw == null) return fallback;
    if (raw is String) return raw.trim();
    if (raw is Map) {
      final v = raw['value'];
      if (v is String) return v.trim();
    }
    return fallback;
  }

  final adminUsername = param(ExportRemoteConfigKeys.adminUsername);
  final adminPassword = param(ExportRemoteConfigKeys.adminPassword);
  if (adminUsername.isEmpty || adminPassword.isEmpty) {
    throw StateError(
      'Firebase Remote Config: set ${ExportRemoteConfigKeys.adminUsername} and '
      '${ExportRemoteConfigKeys.adminPassword} in the Firebase console.',
    );
  }

  final siteDataUrl = param(ExportRemoteConfigKeys.siteDataUrl, fallback: siteDataUrlFallback);
  final github = ExportGithubConfig(
    owner: param(ExportRemoteConfigKeys.githubOwner),
    repo: param(ExportRemoteConfigKeys.githubRepo),
    branch: param(ExportRemoteConfigKeys.githubBranch, fallback: 'main'),
    siteJsonPath: param(ExportRemoteConfigKeys.githubSiteJsonPath, fallback: 'site.json'),
    mediaFolder: param(ExportRemoteConfigKeys.githubMediaFolder, fallback: 'media'),
    token: param(ExportRemoteConfigKeys.githubToken),
  );

  return ExportRuntimeConfig(
    siteDataUrl: siteDataUrl.isNotEmpty ? siteDataUrl : siteDataUrlFallback,
    adminUsername: adminUsername,
    adminPassword: adminPassword,
    github: github.isConfigured ? github : null,
    secretsFromFirebase: true,
  );
}

String _stableAppInstanceId() {
  const storageKey = 'export_firebase_app_instance_id';
  final storage = web.window.localStorage;
  final existing = storage.getItem(storageKey);
  if (existing != null && existing.length >= 16) return existing;
  final id = const Uuid().v4().replaceAll('-', '');
  storage.setItem(storageKey, id);
  return id;
}
