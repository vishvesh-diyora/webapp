import 'dart:convert';

import 'package:blake3_dart/blake3_dart.dart';
import 'package:path/path.dart' as p;

/// Cloudflare Pages Direct Upload asset hash (BLAKE3, first 32 hex chars).
class PagesAssetHasher {
  PagesAssetHasher._();

  static String hash(List<int> bytes, String relativePath) {
    final ext = p.extension(relativePath).replaceFirst('.', '').toLowerCase();
    final input = utf8.encode('${base64Encode(bytes)}$ext');
    return blake3Hex(input).substring(0, 32);
  }
}
