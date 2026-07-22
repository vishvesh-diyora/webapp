import 'package:webapp/core/utils/auth_redirect_urls.dart';

/// Cloudflare OAuth + Pages configuration.
///
/// Create an OAuth client in Cloudflare Dashboard → Manage Account → OAuth clients.
/// Grant type: Authorization Code with PKCE (public client, no secret in app).
/// Required scopes: include Cloudflare Pages **Edit** (and Account **Read**).
class CloudflareConfig {
  CloudflareConfig._();

  /// Public OAuth client ID from Cloudflare OAuth clients dashboard.
  static const String clientId = String.fromEnvironment(
    'CLOUDFLARE_OAUTH_CLIENT_ID',
    defaultValue: '',
  );

  static const String authorizationEndpoint = 'https://dash.cloudflare.com/oauth2/auth';
  static const String tokenEndpoint = 'https://dash.cloudflare.com/oauth2/token';
  static const String revokeEndpoint = 'https://dash.cloudflare.com/oauth2/revoke';
  static const String apiBase = 'https://api.cloudflare.com/client/v4';

  /// Space-separated OAuth scopes configured on your Cloudflare OAuth client.
  static const String scopes = String.fromEnvironment(
    'CLOUDFLARE_OAUTH_SCOPES',
    defaultValue: 'account:read cloudflare-pages:edit',
  );

  static const String oauthStatePrefix = 'cf_oauth_';

  static String redirectUri() => AuthRedirectUrls.callback();

  static bool get isConfigured => clientId.isNotEmpty;

  static void assertConfigured() {
    if (!isConfigured) {
      throw StateError(
        'Cloudflare OAuth is not configured. Set CLOUDFLARE_OAUTH_CLIENT_ID at build time '
        'and register redirect URI: ${redirectUri()}',
      );
    }
  }
}
