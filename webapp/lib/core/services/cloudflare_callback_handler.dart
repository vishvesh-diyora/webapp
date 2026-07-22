import 'package:flutter/foundation.dart';
import 'package:webapp/core/config/cloudflare_config.dart';

/// Handles Cloudflare OAuth callback query parameters on web.
class CloudflareCallbackHandler {
  CloudflareCallbackHandler._();

  static bool hasCloudflareCallbackInUrl() {
    if (!kIsWeb) return false;
    final state = Uri.base.queryParameters['state'];
    return state != null && state.startsWith(CloudflareConfig.oauthStatePrefix);
  }
}
