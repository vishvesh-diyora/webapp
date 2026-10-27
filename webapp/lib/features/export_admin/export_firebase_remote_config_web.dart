import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:web/web.dart' as web;
import 'package:webapp/features/export_admin/export_firebase_web_config.dart';
import 'package:webapp/features/export_admin/export_remote_config_keys.dart';
import 'package:webapp/features/export_admin/export_runtime_config.dart';
import 'package:webapp/features/export_admin/export_viewer_config_load_result.dart';

Future<ExportViewerConfigLoadResult?> tryLoadSecretsFromFirebaseRemote(
  ExportFirebaseWebConfig webConfig, {
  required String siteDataUrlFallback,
}) async {
  if (!webConfig.isConfigured) return null;

  Map<String, dynamic> entries;
  String? fetchError;

  try {
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
      fetchError =
          'Remote Config fetch failed (${response.statusCode}). Check firebase-config.json and enable Remote Config for this web app.';
      entries = {};
    } else {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final entriesRaw = decoded['entries'];
      entries = entriesRaw is Map
          ? Map<String, dynamic>.from(entriesRaw)
          : <String, dynamic>{};
    }
  } catch (e) {
    fetchError = 'Remote Config error: $e';
    entries = {};
  }

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

  final missingLogin = <String>[];
  for (final key in ExportRemoteConfigKeys.loginKeys) {
    if (param(key).isEmpty) missingLogin.add(key);
  }

  final missingGithub = <String>[];
  for (final key in ExportRemoteConfigKeys.githubKeys) {
    if (key == ExportRemoteConfigKeys.githubBranch ||
        key == ExportRemoteConfigKeys.githubSiteJsonPath ||
        key == ExportRemoteConfigKeys.githubMediaFolder) {
      continue;
    }
    if (param(key).isEmpty) missingGithub.add(key);
  }

  final adminUsername = param(ExportRemoteConfigKeys.adminUsername);
  final adminPassword = param(ExportRemoteConfigKeys.adminPassword);
  final siteDataUrl = param(ExportRemoteConfigKeys.siteDataUrl, fallback: siteDataUrlFallback);

  final github = ExportGithubConfig(
    owner: param(ExportRemoteConfigKeys.githubOwner),
    repo: param(ExportRemoteConfigKeys.githubRepo),
    branch: param(ExportRemoteConfigKeys.githubBranch, fallback: 'main'),
    siteJsonPath: param(ExportRemoteConfigKeys.githubSiteJsonPath, fallback: 'site.json'),
    mediaFolder: param(ExportRemoteConfigKeys.githubMediaFolder, fallback: 'media'),
    token: param(ExportRemoteConfigKeys.githubToken),
  );

  final config = ExportRuntimeConfig(
    siteDataUrl: siteDataUrl.isNotEmpty ? siteDataUrl : siteDataUrlFallback,
    adminUsername: adminUsername,
    adminPassword: adminPassword,
    github: github.isConfigured ? github : null,
    secretsFromFirebase: true,
  );

  return ExportViewerConfigLoadResult(
    config: config,
    missingRemoteConfigKeys: missingLogin,
    missingGithubKeys: missingGithub,
    remoteConfigError: fetchError,
    firebaseWebConfigMissing: false,
    usedFirebaseRemoteConfig: true,
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
