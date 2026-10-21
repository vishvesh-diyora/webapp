import 'dart:html' as html;

/// Removes Supabase auth tokens from the browser URL after sign-in callbacks.
void clearAuthParamsFromUrl() {
  final location = html.window.location;
  html.window.history.replaceState(null, '', '${location.origin}${location.pathname}');
}
