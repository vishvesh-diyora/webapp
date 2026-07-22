import 'package:flutter/material.dart';
import 'package:webapp/core/services/image_asset_service.dart';
import 'package:webapp/features/dashboard/models/portfolio_content.dart';

enum ProfileImageShape { circle, square, banner }

/// Profile photo — circle, square, or full-width banner.
class PortfolioProfileImage extends StatelessWidget {
  const PortfolioProfileImage({
    super.key,
    required this.profile,
    this.shape = ProfileImageShape.circle,
    this.size = 100,
    this.bannerHeight = 220,
    this.grayscale = false,
    this.borderRadius = 0,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  final PortfolioProfile profile;
  final ProfileImageShape shape;
  final double size;
  final double bannerHeight;
  final bool grayscale;
  final double borderRadius;
  final BoxFit fit;
  final Alignment alignment;

  static const _grayscaleMatrix = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  @override
  Widget build(BuildContext context) {
    final url = profile.avatarImageUrl;
    if (url == null || url.isEmpty) {
      return PortfolioAvatar(profile: profile, size: size, floating: false);
    }

    Widget image = switch (shape) {
      ProfileImageShape.circle => _circlePhoto(url),
      ProfileImageShape.square => _squarePhoto(url),
      ProfileImageShape.banner => _bannerPhoto(url),
    };

    if (grayscale) {
      image = ColorFiltered(colorFilter: _grayscaleMatrix, child: image);
    }

    return image;
  }

  Widget _circlePhoto(String path) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: size * 0.12,
            offset: Offset(0, size * 0.06),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: ImageAssetService.buildImage(
        path: path,
        width: size,
        height: size,
        fit: fit,
        borderRadius: BorderRadius.circular(size / 2),
      ),
    );
  }

  Widget _squarePhoto(String path) {
    return ImageAssetService.buildImage(
      path: path,
      width: size,
      height: size,
      fit: fit,
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }

  Widget _bannerPhoto(String path) {
    return ImageAssetService.buildImage(
      path: path,
      width: double.infinity,
      height: bannerHeight,
      fit: fit,
    );
  }
}

/// Circular profile photo (or memoji fallback).
class PortfolioAvatar extends StatelessWidget {
  const PortfolioAvatar({
    super.key,
    required this.profile,
    required this.size,
    this.floating = false,
  });

  final PortfolioProfile profile;
  final double size;
  final bool floating;

  @override
  Widget build(BuildContext context) {
    final url = profile.avatarImageUrl;
    if (url != null && url.isNotEmpty) {
      return PortfolioProfileImage(
        profile: profile,
        size: size,
        shape: ProfileImageShape.circle,
      );
    }
    return MemojiAvatar(size: size, floating: floating);
  }
}

/// Memoji fallback when no photo URL is set.
class MemojiAvatar extends StatelessWidget {
  const MemojiAvatar({super.key, required this.size, this.floating = true});

  final double size;
  final bool floating;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFFFDBAC), Color(0xFFE8B88A)],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        'MC',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: size * 0.28,
          color: const Color(0xFF3D2314),
        ),
      ),
    );
  }
}
