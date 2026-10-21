import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Manages user images: pick, store locally, resolve for preview, copy on publish.
abstract final class ImageAssetService {
  static const _uuid = Uuid();
  static final _picker = ImagePicker();

  static Future<String?> pickAndStore({ImageSource source = ImageSource.gallery}) async {
    final file = await _picker.pickImage(source: source, imageQuality: 85);
    if (file == null) return null;
    return storeFile(File(file.path));
  }

  static Future<String> storeFile(File file) async {
    final dir = await _workspaceImagesDir();
    final ext = p.extension(file.path);
    final name = '${_uuid.v4()}${ext.isEmpty ? '.jpg' : ext}';
    final dest = File(p.join(dir.path, name));
    await file.copy(dest.path);
    return 'assets/images/$name';
  }

  static Future<Directory> _workspaceImagesDir() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(root.path, 'website_assets', 'images'));
    if (!dir.existsSync()) await dir.create(recursive: true);
    return dir;
  }

  static Future<File?> resolveLocalFile(String assetPath) async {
    if (assetPath.isEmpty || assetPath.startsWith('http')) return null;
    final relative = assetPath.replaceFirst('assets/images/', '');
    final dir = await _workspaceImagesDir();
    final file = File(p.join(dir.path, relative));
    return file.existsSync() ? file : null;
  }

  static bool _needsLayoutResolve(double width, double height) =>
      !width.isFinite || width <= 0 || !height.isFinite || height <= 0;

  static ({double width, double height}) _resolveSize(
    double width,
    double height,
    BoxConstraints constraints,
  ) {
    var w = width;
    var h = height;

    if (!w.isFinite || w <= 0) {
      if (constraints.maxWidth.isFinite && constraints.maxWidth > 0) {
        w = constraints.maxWidth;
      } else if (h.isFinite && h > 0) {
        w = h;
      } else {
        w = 200;
      }
    }

    if (!h.isFinite || h <= 0) {
      if (constraints.maxHeight.isFinite && constraints.maxHeight > 0) {
        h = constraints.maxHeight;
      } else if (w.isFinite && w > 0) {
        h = w * 0.75;
      } else {
        h = 200;
      }
    }

    return (width: w, height: h);
  }

  static double _placeholderIconSize(double width, double height) {
    final shortest = math.min(
      width.isFinite && width > 0 ? width : 120,
      height.isFinite && height > 0 ? height : 120,
    );
    return (shortest * 0.28).clamp(16.0, 56.0);
  }

  static Widget buildImage({
    required String? path,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    Color? placeholderColor,
  }) {
    if (_needsLayoutResolve(width, height)) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final resolved = _resolveSize(width, height, constraints);
          return buildImage(
            path: path,
            width: resolved.width,
            height: resolved.height,
            fit: fit,
            borderRadius: borderRadius,
            placeholderColor: placeholderColor,
          );
        },
      );
    }

    Widget child;
    if (path == null || path.isEmpty) {
      child = _placeholder(width, height, placeholderColor);
    } else if (path.startsWith('assets/images/')) {
      child = FutureBuilder<File?>(
        future: resolveLocalFile(path),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            return Image.file(snapshot.data!, width: width, height: height, fit: fit);
          }
          return _placeholder(width, height, placeholderColor);
        },
      );
    } else if (path.startsWith('http')) {
      child = Image.network(path, width: width, height: height, fit: fit);
    } else {
      child = Image.file(File(path), width: width, height: height, fit: fit);
    }

    if (borderRadius != null) {
      child = ClipRRect(borderRadius: borderRadius, child: child);
    }
    return SizedBox(width: width, height: height, child: child);
  }

  static Widget _placeholder(double width, double height, Color? color) {
    final iconSize = _placeholderIconSize(width, height);
    return Container(
      width: width,
      height: height,
      color: color ?? const Color(0xFFE2E8F0),
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        color: Colors.grey.shade500,
        size: iconSize,
      ),
    );
  }

  static Future<void> copyDocumentImagesToPublishDir(
    Map<String, dynamic> publishedJson,
    String publishImagesDir,
  ) async {
    final dir = Directory(publishImagesDir);
    if (!dir.existsSync()) await dir.create(recursive: true);
    await _walkJson(publishedJson, (value) async {
      if (value.startsWith('assets/images/')) {
        final local = await resolveLocalFile(value);
        if (local != null) {
          await local.copy(p.join(publishImagesDir, p.basename(local.path)));
        }
      }
    });
  }

  static Future<void> _walkJson(dynamic node, Future<void> Function(String) onPath) async {
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
}
