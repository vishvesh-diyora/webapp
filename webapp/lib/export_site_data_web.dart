import 'dart:convert';

import 'package:web/web.dart' as web;

Map<String, dynamic>? readInlineExportSiteData() {
  final el = web.document.getElementById('export-site-data');
  if (el == null) return null;
  final raw = (el.textContent ?? '').trim();
  if (raw.isEmpty) return null;
  try {
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
  } catch (_) {
    return null;
  }
  return null;
}
