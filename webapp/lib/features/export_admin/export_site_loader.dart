import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:webapp/export_site_data.dart';
import 'package:webapp/features/export_admin/export_firebase_remote_config.dart';
import 'package:webapp/features/export_admin/export_firebase_web_config.dart';
import 'package:webapp/features/export_admin/export_runtime_config.dart';
import 'package:webapp/features/templates/preview/template_preview_image_resolver.dart';
import 'package:webapp/features/website/domain/entities/website_document.dart';

Future<ExportRuntimeConfig> loadRuntimeConfig() async {
  var siteDataUrlFallback = 'site.json';

  try {
    final runtimeUri = Uri.base.resolve('runtime-config.json');
    final runtimeRes = await http.get(runtimeUri);
    if (runtimeRes.statusCode == 200) {
      final local = ExportRuntimeConfig.parse(runtimeRes.body);
      if (local.siteDataUrl.isNotEmpty) {
        siteDataUrlFallback = local.siteDataUrl;
      }
    }
  } catch (_) {
    // optional file
  }

  try {
    final fbUri = Uri.base.resolve('firebase-config.json');
    final fbRes = await http.get(fbUri);
    if (fbRes.statusCode == 200) {
      final webConfig = ExportFirebaseWebConfig.parse(fbRes.body);
      if (webConfig.isConfigured) {
        final fromFirebase = await tryLoadConfigFromFirebaseRemote(
          webConfig,
          siteDataUrlFallback: siteDataUrlFallback,
        );
        if (fromFirebase != null) return fromFirebase;
      }
    }
  } catch (_) {
    // Public site can still load; fix Remote Config for /admin.
  }

  try {
    final runtimeUri = Uri.base.resolve('runtime-config.json');
    final runtimeRes = await http.get(runtimeUri);
    if (runtimeRes.statusCode == 200) {
      final legacy = ExportRuntimeConfig.parse(runtimeRes.body);
      if (legacy.adminUsername.isNotEmpty && legacy.adminPassword.isNotEmpty) {
        return legacy;
      }
    }
  } catch (_) {}

  return ExportRuntimeConfig.deployDefaults.copyWith(siteDataUrl: siteDataUrlFallback);
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
  } catch (_) {
    // fall back to inline bootstrap in index.html
  }
  json ??= readInlineExportSiteData();
  if (json == null) {
    throw StateError('Could not load site data from $url or inline bootstrap');
  }
  final doc = WebsiteDocument.fromJson(json);
  return TemplatePreviewImageResolver.documentWithPreviewImages(doc);
}
