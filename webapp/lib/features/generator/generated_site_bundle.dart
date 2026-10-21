/// In-memory static site files ready for Cloudflare Pages upload.
class GeneratedSiteBundle {
  const GeneratedSiteBundle({required this.files});

  /// Relative path → file bytes (e.g. `index.html`, `assets/images/logo.png`).
  final Map<String, List<int>> files;
}
