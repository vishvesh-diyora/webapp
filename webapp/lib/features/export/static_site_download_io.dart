import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Saves the static site ZIP to the user downloads folder (desktop / mobile).
Future<String> saveStaticSiteZip({
  required List<int> bytes,
  required String fileName,
}) async {
  final downloads = await getDownloadsDirectory();
  final directory = downloads ?? await getApplicationDocumentsDirectory();
  final safeName = fileName.endsWith('.zip') ? fileName : '$fileName.zip';
  final file = File('${directory.path}/$safeName');
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}
