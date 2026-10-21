import 'package:webapp/core/config/env_config.dart';

/// Central application configuration (loaded from `.env` or `--dart-define`).
class AppConfig {
  AppConfig._();

  static const String _defineCloudflareAccountId = String.fromEnvironment(
    'CLOUDFLARE_ACCOUNT_ID',
    defaultValue: '',
  );

  static const String _defineCloudflareApiToken = String.fromEnvironment(
    'CLOUDFLARE_API_TOKEN',
    defaultValue: '',
  );

  // ── Cloudflare Pages (single internal account) ─────────────────────────────
  // Set in `.env`: CLOUDFLARE_ACCOUNT_ID, CLOUDFLARE_API_TOKEN

  static String get cloudflareAccountId => EnvConfig.resolve(
        'CLOUDFLARE_ACCOUNT_ID',
        compileTimeValue: _defineCloudflareAccountId,
      );

  static String get cloudflareApiToken => EnvConfig.resolve(
        'CLOUDFLARE_API_TOKEN',
        compileTimeValue: _defineCloudflareApiToken,
      );

  // ── App ───────────────────────────────────────────────────────────────────

  static const String appName = 'WebApp Configurator';
}
