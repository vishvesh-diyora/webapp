import 'package:flutter/material.dart';
import 'package:webapp/core/services/image_asset_service.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_avatar.dart';

/// Resolves profile/portfolio images from JSON paths (local assets or network).
class SiteImage extends StatelessWidget {
  const SiteImage({
    super.key,
    required this.path,
    required this.width,
    required this.height,
    this.shape = ProfileImageShape.circle,
    this.grayscale = false,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  final String? path;
  final double width;
  final double height;
  final ProfileImageShape shape;
  final bool grayscale;
  final double? borderRadius;
  final BoxFit fit;

  static const _grayscaleMatrix = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  double _effectiveWidth() {
    if (width.isFinite && width > 0) return width;
    if (height.isFinite && height > 0) return height;
    return 48;
  }

  @override
  Widget build(BuildContext context) {
    final resolvedWidth = _effectiveWidth();
    Widget image = ImageAssetService.buildImage(
      path: path,
      width: width,
      height: height,
      fit: fit,
      borderRadius: shape == ProfileImageShape.circle
          ? BorderRadius.circular(resolvedWidth / 2)
          : (borderRadius != null ? BorderRadius.circular(borderRadius!) : null),
    );

    if (grayscale) {
      image = ColorFiltered(colorFilter: _grayscaleMatrix, child: image);
    }
    return image;
  }
}
