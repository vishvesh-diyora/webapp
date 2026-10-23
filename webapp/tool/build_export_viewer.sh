#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
rm -rf assets/export_viewer
flutter build web -t lib/export_viewer_main.dart --base-href / -o assets/export_viewer
rm -f assets/export_viewer/assets/assets/export_viewer_bundle.zip
(
  cd assets/export_viewer
  zip -r ../export_viewer_bundle.zip . -x "*.DS_Store"
)
echo "Built assets/export_viewer/ and assets/export_viewer_bundle.zip"
