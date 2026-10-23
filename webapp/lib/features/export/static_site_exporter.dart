import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:webapp/features/export/export_document_resolver.dart';
import 'package:webapp/features/export/static_site_download.dart';
import 'package:webapp/features/website/domain/entities/website_document.dart';

/// Full Flutter web viewer ZIP + patched [index.html] + [site.json].
abstract final class StaticSiteExporter {
  static const _bundleAsset = 'assets/export_viewer_bundle.zip';

  static bool supportsExport(WebsiteDocument document) => true;

  static String zipBaseName(WebsiteDocument document) {
    final slug = _slugify(document.name.isNotEmpty ? document.name : 'my-site');
    return '$slug-website';
  }

  static Future<List<int>> buildZipBytes(WebsiteDocument document) async {
    final resolved = ExportDocumentResolver.ensureFullContent(document);
    final bundle = await rootBundle.load(_bundleAsset);
    final bundleBytes = bundle.buffer.asUint8List(
      bundle.offsetInBytes,
      bundle.lengthInBytes,
    );

    final decoded = ZipDecoder().decodeBytes(bundleBytes);
    final output = Archive();
    final siteJsonBytes = utf8.encode(jsonEncode(resolved.toJson()));
    final patchedIndex = utf8.encode(_patchIndexHtml(resolved));

    for (final entry in decoded.files) {
      if (!entry.isFile) continue;
      final name = entry.name;
      if (name == 'index.html') {
        output.addFile(ArchiveFile('index.html', patchedIndex.length, patchedIndex));
        continue;
      }
      final content = entry.content as List<int>;
      output.addFile(ArchiveFile(name, content.length, content));
    }

    output.addFile(ArchiveFile('site.json', siteJsonBytes.length, siteJsonBytes));
    final readme = utf8.encode(_readmeText(document));
    output.addFile(ArchiveFile('README.txt', readme.length, readme));

    return ZipEncoder().encode(output);
  }

  static Future<String> exportAndDownload(WebsiteDocument document) async {
    final bytes = await buildZipBytes(document);
    return saveStaticSiteZip(bytes: bytes, fileName: zipBaseName(document));
  }

  static String _patchIndexHtml(WebsiteDocument document) {
    final jsonText = jsonEncode(document.toJson()).replaceAll('</', r'<\/');
    final title = _escapeHtml(
      document.name.isNotEmpty ? document.name : 'My website',
    );
    final injection = '''
<script type="application/json" id="export-site-data">$jsonText</script>
<script>window.__EXPORT_SITE_DATA__=JSON.parse(document.getElementById('export-site-data').textContent);</script>
''';

    // Default template from flutter build web (relative paths for local + hosted).
    return '''<!DOCTYPE html>
<html>
<head>
  <base href="./">
  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content="$title">
  <meta name="mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black">
  <meta name="apple-mobile-web-app-title" content="$title">
  <link rel="apple-touch-icon" href="icons/Icon-192.png">
  <link rel="icon" type="image/png" href="favicon.png"/>
  <title>$title</title>
  <link rel="manifest" href="manifest.json">
  $injection
</head>
<body>
  <script src="flutter_bootstrap.js" async></script>
</body>
</html>''';
  }

  static String _readmeText(WebsiteDocument document) {
    return '''
${document.name} — website export
================================

Same Flutter preview as in the app.

LOCAL TEST (recommended before upload):
  1. Unzip this folder.
  2. Open Terminal in this folder.
  3. Run:  python3 -m http.server 8080
  4. Visit:  http://localhost:8080

HOSTING:
  Upload ALL files and folders (index.html, main.dart.js, canvaskit/, assets/, icons/, site.json, …).

Opening index.html by double-click may not work in some browsers (browser security).
Use a local server as above, or upload to Netlify / Vercel / GitHub Pages / cPanel.

Developers — refresh export bundle after UI changes:
  ./tool/build_export_viewer.sh
''';
  }

  static String _slugify(String input) {
    final lower = input.toLowerCase().trim();
    final slug = lower.replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'-+'), '-');
    final trimmed = slug.replaceAll(RegExp(r'^-|-$'), '');
    return trimmed.isEmpty ? 'my-site' : trimmed;
  }

  static String _escapeHtml(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;');
  }
}
