String exportViewerBrowserPath() => Uri.base.path;

bool exportViewerIsAdminPath([String? path]) {
  final p = path ?? exportViewerBrowserPath();
  return p.contains('/admin');
}

void exportViewerPinAdminPathIfNeeded(bool startOnAdmin) {}
