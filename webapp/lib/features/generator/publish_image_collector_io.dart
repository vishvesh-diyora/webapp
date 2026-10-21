import 'package:webapp/core/services/image_asset_service.dart';

Future<Map<String, List<int>>> collectPublishImages(
  Map<String, dynamic> publishedJson,
) async {
  final files = <String, List<int>>{};

  await _walkJson(publishedJson, (assetPath) async {
    if (!assetPath.startsWith('assets/images/')) return;
    final local = await ImageAssetService.resolveLocalFile(assetPath);
    if (local != null && local.existsSync()) {
      files[assetPath] = await local.readAsBytes();
    }
  });

  return files;
}

Future<void> _walkJson(
  dynamic node,
  Future<void> Function(String assetPath) onPath,
) async {
  if (node is Map) {
    for (final value in node.values) {
      if (value is String && value.startsWith('assets/images/')) {
        await onPath(value);
      } else {
        await _walkJson(value, onPath);
      }
    }
  } else if (node is List) {
    for (final item in node) {
      await _walkJson(item, onPath);
    }
  }
}
