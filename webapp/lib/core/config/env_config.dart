import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Loads `.env` from project root and exposes credentials to the app.
class EnvConfig {
  EnvConfig._();

  static bool _loaded = false;

  static Future<void> load() async {
    if (_loaded) return;
    try {
      await dotenv.load(fileName: '.env');
      _loaded = true;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('EnvConfig: .env not loaded ($error). Copy .env.example to .env');
      }
    }
  }

  /// Priority: `--dart-define` → `.env` → [fallback].
  static String resolve(
    String envKey, {
    String compileTimeValue = '',
    String fallback = '',
  }) {
    if (compileTimeValue.isNotEmpty) return compileTimeValue;
    final fromFile = dotenv.env[envKey]?.trim();
    if (fromFile != null && fromFile.isNotEmpty) return fromFile;
    return fallback;
  }
}
