import 'package:webapp/core/config/env_config.dart';

/// Central application configuration (loaded from `.env` or `--dart-define`).
class AppConfig {
  AppConfig._();

  static const String _defineSupabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String _defineSupabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static const String _defineWebRedirectUrl = String.fromEnvironment(
    'WEB_REDIRECT_URL',
    defaultValue: '',
  );

  static const String _defineMobileRedirectUrl = String.fromEnvironment(
    'MOBILE_REDIRECT_URL',
    defaultValue: '',
  );

  static const String _defineCloudflareAccountId = String.fromEnvironment(
    'CLOUDFLARE_ACCOUNT_ID',
    defaultValue: '',
  );

  static const String _defineCloudflareApiToken = String.fromEnvironment(
    'CLOUDFLARE_API_TOKEN',
    defaultValue: '',
  );

  // ── Supabase ──────────────────────────────────────────────────────────────
  // Set in `.env`: SUPABASE_URL, SUPABASE_ANON_KEY

  static String get supabaseUrl => EnvConfig.resolve(
        'SUPABASE_URL',
        compileTimeValue: _defineSupabaseUrl,
      );

  static String get supabaseAnonKey => EnvConfig.resolve(
        'SUPABASE_ANON_KEY',
        compileTimeValue: _defineSupabaseAnonKey,
      );

  /// Production web callback URL. Leave empty to auto-detect from the browser.
  static String get webRedirectUrl => EnvConfig.resolve(
        'WEB_REDIRECT_URL',
        compileTimeValue: _defineWebRedirectUrl,
      );

  /// Deep link for mobile password-reset and OAuth callbacks.
  static String get mobileRedirectUrl => EnvConfig.resolve(
        'MOBILE_REDIRECT_URL',
        compileTimeValue: _defineMobileRedirectUrl,
        fallback: 'io.supabase.webapp://login-callback',
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

  static const bool isLoginSignupMandatory = false;
}
