import 'package:web/web.dart' as web;

/// Removes OAuth query parameters from the browser URL after Cloudflare callback.
void stripCloudflareOAuthParams() {
  final href = web.window.location.href;
  final uri = Uri.parse(href);
  final state = uri.queryParameters['state'];
  if (state == null || !state.startsWith('cf_oauth_')) return;

  final cleaned = uri.replace(queryParameters: {});
  web.window.history.replaceState(null, '', cleaned.toString());
}
