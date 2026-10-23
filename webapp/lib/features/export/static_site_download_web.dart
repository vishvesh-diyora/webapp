import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Triggers a browser download of the static site ZIP.
Future<String> saveStaticSiteZip({
  required List<int> bytes,
  required String fileName,
}) async {
  final safeName = fileName.endsWith('.zip') ? fileName : '$fileName.zip';
  final data = Uint8List.fromList(bytes);
  final blobParts = [data.toJS].toJS;
  final blob = web.Blob(blobParts);
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement();
  anchor.href = url;
  anchor.download = safeName;
  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
  return safeName;
}
