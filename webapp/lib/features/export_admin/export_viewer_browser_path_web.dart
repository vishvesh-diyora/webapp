import 'package:web/web.dart' as web;

String exportViewerBrowserPath() => web.window.location.pathname;

bool exportViewerIsAdminPath([String? path]) {
  final p = path ?? exportViewerBrowserPath();
  return p.contains('/admin');
}

/// Keeps the browser on `/admin` when Flutter path strategy normalizes the URL.
void exportViewerPinAdminPathIfNeeded(bool startOnAdmin) {
  if (!startOnAdmin) return;
  final path = web.window.location.pathname;
  if (!path.contains('/admin')) {
    web.window.history.replaceState(null, '', '/admin');
  }
}
