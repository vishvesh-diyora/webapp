import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:webapp/core/utils/auth_redirect_urls.dart';

/// Parses Supabase auth callbacks from email links and OAuth redirects.
class AuthCallbackHandler {
  AuthCallbackHandler._();

  /// Call once after [Supabase.initialize] — required for web auth redirects.
  static Future<void> handleInitialCallback() async {
    if (!kIsWeb) return;
    if (!AuthRedirectUrls.hasAuthCallbackInUrl()) return;

    try {
      await Supabase.instance.client.auth.getSessionFromUrl(Uri.base);
    } on AuthException {
      // Invalid or expired link — router will show auth gate.
    } catch (_) {
      // Ignore malformed callback URLs.
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
