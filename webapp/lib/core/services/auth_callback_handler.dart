import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:webapp/core/utils/auth_redirect_urls.dart';
import 'package:webapp/core/utils/web_auth_url_cleaner.dart';

/// Parses Supabase auth callbacks from email links and OAuth redirects.
class AuthCallbackHandler {
  AuthCallbackHandler._();

  /// Call once after [Supabase.initialize] — required for web auth redirects.
  static Future<void> handleInitialCallback() async {
    if (!kIsWeb) return;
    if (!AuthRedirectUrls.hasAuthCallbackInUrl()) return;

    final auth = Supabase.instance.client.auth;
    final existingSession = auth.currentSession;

    // A saved session beats stale #access_token fragments left in the URL.
    if (existingSession != null) {
      clearAuthParamsFromUrl();
      return;
    }

    try {
      await auth.getSessionFromUrl(Uri.base);
    } on AuthException {
      // Invalid or expired link — router will show auth gate.
    } catch (_) {
      // Ignore malformed callback URLs.
    } finally {
      clearAuthParamsFromUrl();
    }
  }

  /// Returns true when the user arrived via a password-reset email link.
  static bool get isPasswordRecoveryLaunch =>
      AuthRedirectUrls.isPasswordRecoveryUrl();

  static bool _recoveryActive = false;

  static void markPasswordRecovery() => _recoveryActive = true;

  static void clearPasswordRecovery() => _recoveryActive = false;

  static bool get isRecoveryActive => _recoveryActive;
}
