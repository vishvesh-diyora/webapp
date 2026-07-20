import 'package:flutter/foundation.dart';
import 'package:webapp/core/config/app_config.dart';

/// Resolves OAuth and password-reset redirect URLs per platform.
class AuthRedirectUrls {
  AuthRedirectUrls._();

  /// Callback URL for password-reset emails and OAuth sign-in.
  static String callback() {
    if (kIsWeb) {
      return _webCallbackUrl();
    }
    return AppConfig.mobileRedirectUrl;
  }

  static String passwordResetRedirect() => callback();

  static String oauthRedirect() => callback();

  /// Builds the web callback URL from the current browser location.
  ///
  /// Set [AppConfig.webRedirectUrl] when deploying to a fixed production domain.
  static String _webCallbackUrl() {
    if (AppConfig.webRedirectUrl.isNotEmpty) {
      return AppConfig.webRedirectUrl;
    }

    final uri = Uri.base;
    final path = uri.path == '/' ? '' : uri.path.replaceAll(RegExp(r'/+$'), '');
    return '${uri.origin}$path';
  }

  /// Whether the current browser URL contains Supabase auth callback params.
  static bool hasAuthCallbackInUrl() {
    if (!kIsWeb) return false;

    final uri = Uri.base;
    final fragment = uri.fragment;
    final query = uri.query;

    return fragment.contains('access_token') ||
        fragment.contains('type=recovery') ||
        fragment.contains('error=') ||
        query.contains('code=') ||
        query.contains('error=');
  }

  /// Whether the current URL is a password-recovery callback.
  static bool isPasswordRecoveryUrl() {
    if (!kIsWeb) return false;
    return Uri.base.fragment.contains('type=recovery');
  }
}
