import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:webapp/features/export_admin/export_firebase_web_config.dart';
import 'package:webapp/features/export_admin/export_runtime_config.dart';
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

    final runtimeConfig = utf8.encode(
      const JsonEncoder.withIndent('  ').convert(ExportRuntimeConfig.deployDefaults.toDeployJson()),
    );
    output.addFile(ArchiveFile('runtime-config.json', runtimeConfig.length, runtimeConfig));

    final firebaseConfig = utf8.encode(
      const JsonEncoder.withIndent('  ').convert(ExportFirebaseWebConfig.deployTemplate()),
    );
    output.addFile(ArchiveFile('firebase-config.json', firebaseConfig.length, firebaseConfig));

    final adminDoc = utf8.encode(_adminSetupMd());
    output.addFile(ArchiveFile('ADMIN_SETUP.md', adminDoc.length, adminDoc));

    final redirects = utf8.encode('/*    /index.html   200\n');
    output.addFile(ArchiveFile('_redirects', redirects.length, redirects));

    final serveScript = await rootBundle.load('tool/serve_export_site.py');
    final serveBytes = serveScript.buffer.asUint8List(
      serveScript.offsetInBytes,
      serveScript.lengthInBytes,
    );
    output.addFile(ArchiveFile('serve_local.py', serveBytes.length, serveBytes));

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
  <script>
    if ('serviceWorker' in navigator) {
      navigator.serviceWorker.getRegistrations().then(function (regs) {
        regs.forEach(function (r) { r.unregister(); });
      });
    }
  </script>
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
  3. Run:  python3 serve_local.py
     (Do NOT use "python3 -m http.server" — /admin will 404 without SPA fallback.)
  4. Visit:  http://localhost:8080
     Admin:  http://localhost:8080/admin

HOSTING:
  Upload ALL files and folders (index.html, main.dart.js, canvaskit/, assets/, icons/, site.json, …).

Opening index.html by double-click may not work in some browsers (browser security).
Use a local server as above, or upload to Netlify / Vercel / GitHub Pages / cPanel.

ADMIN: https://YOUR-DOMAIN/admin  (Firebase Remote Config — see ADMIN_SETUP.md)

Developers — refresh export bundle after UI changes:
  ./tool/build_export_viewer.sh
''';
  }

  static String _adminSetupMd() => '''
# Admin, Firebase Remote Config & GitHub

Admin username, password, and GitHub token are **not** stored in files you upload to Cloudflare.
They are loaded from **Firebase Remote Config** when someone opens `/admin`.

## 1. Create a Firebase project

1. Go to https://console.firebase.google.com/
2. **Add project** (any name).
3. Open **Build → Remote Config** and click **Create configuration** (if prompted).

## 2. Add a Web app (for public Firebase keys only)

1. Project **Settings** (gear) → **Your apps** → **Web** (`</>`).
2. Register the app (nickname e.g. `website-export`).
3. Copy the `firebaseConfig` object fields into **`firebase-config.json`** on your site (same folder as `index.html`):

```json
{
  "apiKey": "...",
  "authDomain": "YOUR_PROJECT_ID.firebaseapp.com",
  "projectId": "YOUR_PROJECT_ID",
  "storageBucket": "YOUR_PROJECT_ID.appspot.com",
  "messagingSenderId": "...",
  "appId": "..."
}
```

These values are **public** (like any Firebase web app). They are **not** your admin password or GitHub token.

## 3. Remote Config parameters (secrets live here)

In **Remote Config**, add these parameters (String), then **Publish**:

| Parameter key | Example / notes |
|---------------|-----------------|
| `admin_username` | `mywebsite` |
| `admin_password` | `myweb123` (change to your own) |
| `site_data_url` | `https://raw.githubusercontent.com/USER/REPO/main/site.json` |
| `github_owner` | GitHub username or org |
| `github_repo` | Repo that holds `site.json` and `media/` |
| `github_branch` | `main` |
| `github_token` | Fine-grained PAT with **Contents: Read and write** on that repo only |
| `github_site_json_path` | `site.json` |
| `github_media_folder` | `media` |

**To change admin login or GitHub later:** edit values in Firebase Console → Remote Config → Publish. No redeploy to Cloudflare required.

## 4. Optional: `runtime-config.json` on Cloudflare

Only non-secret hosting hints (included in export):

```json
{
  "siteDataUrl": "site.json"
}
```

Use a GitHub **raw** URL here if you prefer; Remote Config `site_data_url` overrides when Firebase is configured.

## 5. GitHub repo for live content

1. Create a repo with `site.json` (copy from export) and empty `media/` folder (or let admin create files on first upload).
2. Create a fine-grained token limited to that repository.
3. Put token in Remote Config as `github_token` (not in Cloudflare files).

When you click **Save** in `/admin`, the site updates `site.json` and uploads images to `media/` via the GitHub API.

## 6. Deploy to Cloudflare Pages

1. Unzip the export and fill in **`firebase-config.json`** with your Firebase web app keys.
2. Upload the **entire** folder to Cloudflare Pages.
3. `_redirects` is included so `/admin` works.
4. Open `https://your-domain.com/admin` and sign in with Remote Config credentials.

## 7. Local test

```bash
python3 serve_local.py
```

(`serve_local.py` is in the export ZIP — it enables `/admin` routes. Plain `python3 -m http.server` returns 404 for `/admin`.)

- Site: http://localhost:8080  
- Admin: http://localhost:8080/admin (needs valid `firebase-config.json` + published Remote Config)

**Local-only shortcut (not for production):** you may put `adminUsername` / `adminPassword` / `github` in `runtime-config.json` for testing without Firebase. Do **not** use that on Cloudflare.

## Security notes

- Visitors browsing the shop **do not** download admin password or GitHub token from your Cloudflare site files.
- `/admin` still loads those values into the browser to talk to GitHub — a very advanced attacker could target an admin session. Use a strong password, repo-scoped token, and enable **Firebase App Check** when you are ready.
- Never commit real `github_token` or passwords to a public git repo.
''';

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
