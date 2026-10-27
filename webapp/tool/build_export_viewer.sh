#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
rm -rf assets/export_viewer
flutter build web -t lib/export_viewer_main.dart --base-href / -o assets/export_viewer
rm -f assets/export_viewer/assets/assets/export_viewer_bundle.zip
# Avoid stale admin UI from flutter_service_worker cache during local testing.
node -e "
const fs = require('fs');
const p = 'assets/export_viewer/index.html';
let html = fs.readFileSync(p, 'utf8');
const inject = \`<script>
  if ('serviceWorker' in navigator) {
    navigator.serviceWorker.getRegistrations().then((regs) => regs.forEach((r) => r.unregister()));
  }
</script>\`;
if (!html.includes('serviceWorker')) {
  html = html.replace('<script src=\"flutter_bootstrap.js\"', inject + '\\n  <script src=\"flutter_bootstrap.js\"');
  fs.writeFileSync(p, html);
}
"
(
  cd assets/export_viewer
  zip -r ../export_viewer_bundle.zip . -x "*.DS_Store"
)
echo "Built assets/export_viewer/ and assets/export_viewer_bundle.zip"
