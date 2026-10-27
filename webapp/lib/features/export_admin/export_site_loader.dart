import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:webapp/export_site_data.dart';
import 'package:webapp/features/export_admin/export_firebase_remote_config.dart';
import 'package:webapp/features/export_admin/export_firebase_web_config.dart';
import 'package:webapp/features/export_admin/export_runtime_config.dart';
import 'package:webapp/features/export_admin/export_viewer_config_load_result.dart';
import 'package:webapp/features/templates/preview/template_preview_image_resolver.dart';
import 'package:webapp/features/website/domain/entities/website_document.dart';

Future<ExportRuntimeConfig?> _loadLocalRuntimeConfigJson() async {
  try {
    final runtimeUri = Uri.base.resolve('runtime-config.json');
    final runtimeRes = await http.get(runtimeUri);
    if (runtimeRes.statusCode == 200) {
      return ExportRuntimeConfig.parse(runtimeRes.body);
    }
  } catch (_) {}
  return null;
}

/// Config for the **downloaded website** (export viewer). Not used by the Flutter builder app.
Future<ExportViewerConfigLoadResult> loadExportViewerConfig() async {
  final local = await _loadLocalRuntimeConfigJson();
  final siteDataUrlFallback = local?.siteDataUrl.isNotEmpty == true
      ? local!.siteDataUrl
      : 'site.json';

  ExportViewerConfigLoadResult? firebaseResult;
  var firebaseWebMissing = true;

  try {
    final fbUri = Uri.base.resolve('firebase-config.json');
    final fbRes = await http.get(fbUri);
    if (fbRes.statusCode == 200) {
      final webConfig = ExportFirebaseWebConfig.parse(fbRes.body);
      firebaseWebMissing = !webConfig.isConfigured;
      if (webConfig.isConfigured) {
        firebaseResult = await tryLoadSecretsFromFirebaseRemote(
          webConfig,
          siteDataUrlFallback: siteDataUrlFallback,
        );
      }
    }
  } catch (e) {
    firebaseResult = ExportViewerConfigLoadResult(
      config: ExportRuntimeConfig.deployDefaults.copyWith(siteDataUrl: siteDataUrlFallback),
      remoteConfigError: 'Firebase setup error: $e',
      firebaseWebConfigMissing: firebaseWebMissing,
    );
  }

  if (firebaseResult != null) {
    var config = firebaseResult.config;
    if (local != null &&
        local.adminUsername.isNotEmpty &&
        local.adminPassword.isNotEmpty &&
        (config.adminUsername.isEmpty || config.adminPassword.isEmpty)) {
      config = ExportRuntimeConfig(
        siteDataUrl: config.siteDataUrl.isNotEmpty ? config.siteDataUrl : siteDataUrlFallback,
        adminUsername: local.adminUsername,
        adminPassword: local.adminPassword,
        github: config.github ?? local.github,
        secretsFromFirebase: false,
      );
    }
    return ExportViewerConfigLoadResult(
      config: config,
      missingRemoteConfigKeys: firebaseResult.missingRemoteConfigKeys,
      missingGithubKeys: firebaseResult.missingGithubKeys,
      remoteConfigError: firebaseResult.remoteConfigError,
      firebaseWebConfigMissing: firebaseResult.firebaseWebConfigMissing,
      usedFirebaseRemoteConfig: firebaseResult.usedFirebaseRemoteConfig,
    );
  }

  if (local != null &&
      local.adminUsername.isNotEmpty &&
      local.adminPassword.isNotEmpty) {
    return ExportViewerConfigLoadResult(
      config: local,
      firebaseWebConfigMissing: firebaseWebMissing,
      usedFirebaseRemoteConfig: false,
    );
  }

  return ExportViewerConfigLoadResult(
    config: (local ?? ExportRuntimeConfig.deployDefaults)
        .copyWith(siteDataUrl: siteDataUrlFallback),
    firebaseWebConfigMissing: firebaseWebMissing,
    remoteConfigError: firebaseWebMissing
        ? 'Add firebase-config.json (web app keys) and Remote Config parameters, '
            'or adminUsername / adminPassword in runtime-config.json for local testing.'
        : null,
  );
}

@Deprecated('Use loadExportViewerConfig for export viewer')
Future<ExportRuntimeConfig> loadRuntimeConfig() async {
  final r = await loadExportViewerConfig();
  return r.config;
}

extension on ExportRuntimeConfig {
  ExportRuntimeConfig copyWith({String? siteDataUrl}) {
    return ExportRuntimeConfig(
      siteDataUrl: siteDataUrl ?? this.siteDataUrl,
      adminUsername: adminUsername,
      adminPassword: adminPassword,
      github: github,
      secretsFromFirebase: secretsFromFirebase,
    );
  }

}

Future<WebsiteDocument> loadSiteDocument(ExportRuntimeConfig config) async {
  Map<String, dynamic>? json;
  final url = config.siteDataUrl;
  final uri = url.startsWith('http') ? Uri.parse(url) : Uri.base.resolve(url);
  try {
    final response = await http.get(
      uri.replace(
        queryParameters: {
          ...uri.queryParameters,
          't': DateTime.now().millisecondsSinceEpoch.toString(),
        },
      ),
    );
    if (response.statusCode == 200) {
      json = jsonDecode(response.body) as Map<String, dynamic>;
    }
  } catch (_) {}
  json ??= readInlineExportSiteData();
  if (json == null) {
    throw StateError('Could not load site data from $url or inline bootstrap');
  }
  final doc = WebsiteDocument.fromJson(json);
  return TemplatePreviewImageResolver.documentWithPreviewImages(doc);
}
