import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:webapp/features/cloudflare/domain/entities/cloudflare_tokens.dart';

/// Persists Cloudflare OAuth tokens securely on device.
class CloudflareTokenStorage {
  CloudflareTokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  static const _key = 'cloudflare_tokens';

  final FlutterSecureStorage _storage;

  Future<CloudflareTokens?> read() async {
    final raw = await _storage.read(key: _key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return CloudflareTokens.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> write(CloudflareTokens tokens) async {
    await _storage.write(key: _key, value: jsonEncode(tokens.toJson()));
  }

  Future<void> clear() async {
    await _storage.delete(key: _key);
  }

  Future<bool> hasTokens() async {
    final tokens = await read();
    return tokens != null && tokens.accessToken.isNotEmpty;
  }
}
