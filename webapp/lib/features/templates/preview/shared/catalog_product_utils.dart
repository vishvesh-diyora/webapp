String catalogItemLabel(Map<String, dynamic> item) =>
    item['title'] as String? ?? item['name'] as String? ?? 'Item';

String catalogProductSubtitle(Map<String, dynamic> item) =>
    item['description'] as String? ?? item['category'] as String? ?? '';

bool catalogIsBestSeller(Map<String, dynamic> item) {
  final value = item['bestSeller'] ?? item['bestseller'] ?? item['isBestSeller'];
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.toLowerCase();
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }
  return false;
}

/// Other catalog rows for the detail-page suggestions block (same category first).
List<Map<String, dynamic>> catalogSuggestionProducts({
  required List<Map<String, dynamic>> all,
  required Map<String, dynamic> current,
  int maxItems = 12,
}) {
  final currentName = catalogItemLabel(current);
  final category = current['category'] as String?;
  final others = all
      .where((item) => catalogItemLabel(item) != currentName)
      .toList();

  if (category != null && category.trim().isNotEmpty) {
    others.sort((a, b) {
      final aSame = (a['category'] as String? ?? '') == category ? 0 : 1;
      final bSame = (b['category'] as String? ?? '') == category ? 0 : 1;
      return aSame.compareTo(bSame);
    });
  }

  if (others.length <= maxItems) return others;
  return others.sublist(0, maxItems);
}

/// How many full 9:16 reel cells fit across the catalog width (e.g. 3 on phone).
int catalogReelsVisibleCount(double width) {
  if (width >= 1200) return 6;
  if (width >= 900) return 5;
  if (width >= 600) return 4;
  return 3;
}

const _catalogStaticReelDriveFileIds = [
  '1-l6Duhu-4b0nbbLCZfg0wE_75FExPbwr',
  '1LQZz6pS85VcKItHBr0Euobq5mxqAJltw',
  '1K3-B5BEwXrxh4-brDQPs8QoRnrE--sGD',
  '1UMuafNfOqAqB65xYg8HCCQQyUypek1sO',
];

/// Direct MP4 URLs (no redirect) — required for Flutter web playback.
List<String> get catalogStaticReelPreviewVideos => _catalogStaticReelDriveFileIds
    .map(catalogDriveDirectVideoUrl)
    .toList(growable: false);

String catalogDriveDirectVideoUrl(String fileId) =>
    'https://drive.usercontent.google.com/download?id=$fileId&export=download';

/// In-browser embed (works on Flutter web when raw MP4 `src` is blocked).
String catalogDrivePreviewEmbedUrl(String fileId) =>
    'https://drive.google.com/file/d/$fileId/preview';

String? catalogDriveFileIdFromUrl(String url) {
  final pathId = RegExp(r'drive\.google\.com/file/d/([^/?#]+)').firstMatch(url);
  if (pathId != null) return pathId.group(1);
  final queryId = RegExp(r'[?&]id=([^&]+)').firstMatch(url);
  if (queryId != null && url.contains('google.com')) return queryId.group(1);
  return null;
}

/// URLs to try when fetching reel video bytes on web (first success wins).
List<String> catalogReelVideoFetchCandidates(String normalizedUrl) {
  final fileId = catalogDriveFileIdFromUrl(normalizedUrl);
  if (fileId == null) return [normalizedUrl];
  return [
    catalogDriveDirectVideoUrl(fileId),
    'https://drive.google.com/uc?export=download&confirm=t&id=$fileId',
  ];
}

/// Normalizes Google Drive share / `uc` links to a direct `usercontent` stream URL.
String catalogNormalizeReelVideoUrl(String url) {
  final trimmed = url.trim();
  final pathId = RegExp(r'drive\.google\.com/file/d/([^/?#]+)').firstMatch(trimmed);
  if (pathId != null) {
    return catalogDriveDirectVideoUrl(pathId.group(1)!);
  }
  final queryId = RegExp(r'[?&]id=([^&]+)').firstMatch(trimmed);
  if (queryId != null && trimmed.contains('google.com')) {
    return catalogDriveDirectVideoUrl(queryId.group(1)!);
  }
  return trimmed;
}

String catalogStaticReelVideoUrl(int index) {
  final i = index.abs() % _catalogStaticReelDriveFileIds.length;
  return catalogDriveDirectVideoUrl(_catalogStaticReelDriveFileIds[i]);
}

String? catalogProductVideoUrl(Map<String, dynamic> product) {
  final url = product['videoUrl'] as String? ?? product['video'] as String?;
  if (url == null || url.trim().isEmpty) return null;
  return catalogNormalizeReelVideoUrl(url.trim());
}

String catalogReelVideoUrl(Map<String, dynamic> reel, {int fallbackIndex = 0}) {
  final url = reel['videoUrl'] as String? ?? reel['video'] as String?;
  if (url == null || url.trim().isEmpty) {
    return catalogStaticReelVideoUrl(fallbackIndex);
  }
  return catalogNormalizeReelVideoUrl(url.trim());
}

/// Primary image plus optional `images` list for product / menu detail galleries.
List<String> catalogProductImages(Map<String, dynamic> item) {
  final list = <String>[];
  final extra = item['images'];
  if (extra is List) {
    for (final entry in extra) {
      if (entry is String && entry.trim().isNotEmpty) {
        list.add(entry.trim());
      }
    }
  }
  final primary = item['image'] as String?;
  if (primary != null && primary.trim().isNotEmpty) {
    if (!list.contains(primary.trim())) {
      list.insert(0, primary.trim());
    } else {
      list.remove(primary.trim());
      list.insert(0, primary.trim());
    }
  }
  return list;
}

Map<String, dynamic>? findCatalogProductByName(
  List<Map<String, dynamic>> products,
  String? name,
) {
  final target = name?.trim();
  if (target == null || target.isEmpty) return null;
  for (final product in products) {
    if (catalogItemLabel(product) == target) return product;
  }
  return null;
}

/// One reel per catalog row that defines `videoUrl` / `video` (ecommerce + restaurant).
List<Map<String, dynamic>> resolveCatalogReels({
  required List<dynamic>? rawReels,
  required List<Map<String, dynamic>> products,
}) {
  final resolved = <Map<String, dynamic>>[];
  for (final product in products) {
    final video = catalogProductVideoUrl(product);
    if (video == null) continue;
    resolved.add({
      'videoUrl': video,
      'product': product,
    });
  }
  if (resolved.isNotEmpty) return resolved;

  // Legacy: primary `reels` list linked by product name.
  if (rawReels != null) {
    for (final entry in rawReels) {
      if (entry is! Map) continue;
      final reel = Map<String, dynamic>.from(entry);
      final productName = reel['productName'] as String? ?? reel['product'] as String?;
      final product = findCatalogProductByName(products, productName);
      if (product == null) continue;
      final video = catalogProductVideoUrl(product) ??
          catalogReelVideoUrl(reel, fallbackIndex: resolved.length);
      reel['product'] = product;
      reel['videoUrl'] = video;
      resolved.add(reel);
    }
  }
  return resolved;
}
