import 'package:webapp/core/config/app_config.dart';

/// Internal Cloudflare Pages credentials (single account for all users).
class CloudflareConfig {
  CloudflareConfig._();

  static const String apiBase = 'https://api.cloudflare.com/client/v4';

  static String get accountId => AppConfig.cloudflareAccountId;

  static String get apiToken => AppConfig.cloudflareApiToken;

  static bool get isConfigured => accountId.isNotEmpty && apiToken.isNotEmpty;

  static void assertConfigured() {
    if (!isConfigured) {
      throw StateError(
        'Cloudflare is not configured. Add CLOUDFLARE_ACCOUNT_ID and '
        'CLOUDFLARE_API_TOKEN to your .env file (copy from .env.example).',
      );
    }
  }

  static String pagesUrlForUsername(String username) =>
      'https://${normalizeUsername(username)}.pages.dev';
}

/// Validates and normalizes publish usernames (Cloudflare Pages project names).
class PublishUsername {
  PublishUsername._();

  static const minLength = 3;
  static const maxLength = 58;

  static const reserved = {
    'www',
    'api',
    'admin',
    'app',
    'mail',
    'ftp',
    'cdn',
    'static',
    'assets',
    'dashboard',
    'login',
    'auth',
    'oauth',
    'help',
    'support',
    'status',
    'blog',
    'dev',
    'staging',
    'test',
    'null',
    'undefined',
  };

  static String normalize(String input) {
    var slug = input.trim().toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9-]+'),
      '-',
    );
    slug = slug.replaceAll(RegExp(r'-+'), '-').replaceAll(RegExp(r'^-|-$'), '');
    if (slug.length > maxLength) {
      slug = slug.substring(0, maxLength).replaceAll(RegExp(r'-+$'), '');
    }
    return slug;
  }

  static String? validate(String raw) {
    final username = normalize(raw);
    if (username.length < minLength) {
      return 'Username must be at least $minLength characters.';
    }
    if (!RegExp(r'^[a-z0-9]([a-z0-9-]*[a-z0-9])?$').hasMatch(username)) {
      return 'Use letters, numbers, and hyphens only (no leading/trailing hyphen).';
    }
    if (reserved.contains(username)) {
      return 'That username is reserved. Choose another.';
    }
    return null;
  }
}

String normalizeUsername(String input) => PublishUsername.normalize(input);
