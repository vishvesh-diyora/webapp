import 'package:webapp/core/domain/category_type.dart';
import 'package:webapp/features/website/domain/entities/website_document.dart';

/// Replaces bundled asset image paths with network URLs for template picker preview only.
abstract final class TemplatePreviewImageResolver {
  static const _unsplash = 'https://images.unsplash.com';

  static const _byAsset = <String, String>{
    'assets/images/profile.jpg':
        '$_unsplash/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=600&h=600&q=80',
    'assets/images/logo.png':
        '$_unsplash/photo-1611224923853-80b023f02d71?auto=format&fit=crop&w=200&h=200&q=80',
    'assets/images/project-1.jpg':
        '$_unsplash/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=900&h=600&q=80',
    'assets/images/project-2.jpg':
        '$_unsplash/photo-1551650975-87deedd944d3?auto=format&fit=crop&w=900&h=600&q=80',
    'assets/images/project-3.jpg':
        '$_unsplash/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=900&h=600&q=80',
    'assets/images/gallery-1.jpg':
        '$_unsplash/photo-1497366216548-37526070297c?auto=format&fit=crop&w=900&h=600&q=80',
    'assets/images/gallery-2.jpg':
        '$_unsplash/photo-1497366754035-f200968a6e72?auto=format&fit=crop&w=900&h=600&q=80',
    'assets/images/team-1.jpg':
        '$_unsplash/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=400&h=400&q=80',
    'assets/images/product-1.jpg':
        '$_unsplash/photo-1555041469-a586c61ea9bc?auto=format&fit=crop&w=900&h=600&q=80',
    'assets/images/product-2.jpg':
        '$_unsplash/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=900&h=600&q=80',
    'assets/images/product-3.jpg':
        '$_unsplash/photo-1505744386214-509ebb5758a5?auto=format&fit=crop&w=900&h=600&q=80',
    'assets/images/reveal-1.jpg':
        '$_unsplash/photo-1527529482836-469687ffb197?auto=format&fit=crop&w=900&h=600&q=80',
    'assets/images/reveal-2.jpg':
        '$_unsplash/photo-1464349095431-e9a21285b5bb?auto=format&fit=crop&w=900&h=600&q=80',
    'assets/images/gift-cover.jpg':
        '$_unsplash/photo-1513885535751-8b9238bd345a?auto=format&fit=crop&w=1200&h=700&q=80',
    'assets/images/banner-1.jpg':
        '$_unsplash/photo-1414235077428-338989a2e8c0?auto=format&fit=crop&w=1200&h=500&q=80',
    'assets/images/banner-2.jpg':
        '$_unsplash/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=1200&h=500&q=80',
    'assets/images/menu-1.jpg':
        '$_unsplash/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=600&h=600&q=80',
    'assets/images/menu-2.jpg':
        '$_unsplash/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=600&h=600&q=80',
    'assets/images/menu-3.jpg':
        '$_unsplash/photo-1565958011703-44f9829ba187?auto=format&fit=crop&w=600&h=600&q=80',
    'assets/images/cat-1.jpg':
        '$_unsplash/photo-1555041469-a586c61ea9bc?auto=format&fit=crop&w=600&h=400&q=80',
    'assets/images/cat-2.jpg':
        '$_unsplash/photo-1493663284031-b7e3aefcae8e?auto=format&fit=crop&w=600&h=400&q=80',
    'assets/images/cat-3.jpg':
        '$_unsplash/photo-1556911220-bff31c812dba?auto=format&fit=crop&w=600&h=400&q=80',
  };

  static WebsiteDocument documentWithPreviewImages(WebsiteDocument document) {
    final blocks = document.data.map((block) {
      final content = _transformContent(
        Map<String, dynamic>.from(block.contentData),
        document.type,
      );
      return block.copyWith(contentData: content);
    }).toList();

    final logo = _resolvePath(document.logo, document.type, 'logo');

    return document.copyWith(
      logo: logo,
      data: blocks,
    );
  }

  static Map<String, dynamic> _transformContent(
    Map<String, dynamic> content,
    int categoryType,
  ) {
    final result = <String, dynamic>{};
    for (final entry in content.entries) {
      final key = entry.key;
      final value = entry.value;

      if (key == 'revealImages' && value is List) {
        result[key] = value
            .map((item) => item is String ? _resolvePath(item, categoryType, key) : item)
            .toList();
        continue;
      }

      if (_isImageField(key) && value is String) {
        result[key] = _resolvePath(value, categoryType, key);
        continue;
      }

      if (value is Map<String, dynamic>) {
        result[key] = _transformContent(value, categoryType);
      } else if (value is Map) {
        result[key] = _transformContent(Map<String, dynamic>.from(value), categoryType);
      } else if (value is List) {
        result[key] = value.map((item) {
          if (item is Map<String, dynamic>) {
            return _transformContent(item, categoryType);
          }
          if (item is Map) {
            return _transformContent(Map<String, dynamic>.from(item), categoryType);
          }
          return item;
        }).toList();
      } else {
        result[key] = value;
      }
    }
    return result;
  }

  static bool _isImageField(String key) {
    const keys = {
      'image',
      'profileImage',
      'coverImage',
      'logo',
      'photo',
      'avatar',
      'thumbnail',
      'banner',
    };
    return keys.contains(key) || key.toLowerCase().endsWith('image');
  }

  static String _resolvePath(String path, int categoryType, String field) {
    final trimmed = path.trim();
    if (trimmed.isEmpty) {
      return _categoryFallback(categoryType, field, 0);
    }
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (_byAsset.containsKey(trimmed)) {
      return _byAsset[trimmed]!;
    }
    if (trimmed.startsWith('assets/images/')) {
      final index = trimmed.hashCode.abs();
      return _categoryFallback(categoryType, field, index);
    }
    return trimmed;
  }

  static String _categoryFallback(int categoryType, String field, int seed) {
    final pool = switch (categoryType) {
      CategoryType.ecommerce => _ecommerce,
      CategoryType.restaurantMenu => _restaurant,
      CategoryType.businessProfile => _business,
      CategoryType.portfolio => _portfolio,
      CategoryType.giftReveal => _gift,
      _ => _business,
    };
    if (field == 'profileImage' || field == 'avatar') {
      return pool.first;
    }
    return pool[seed % pool.length];
  }

  static final _ecommerce = [
    '$_unsplash/photo-1555041469-a586c61ea9bc?auto=format&fit=crop&w=900&h=600&q=80',
    '$_unsplash/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=900&h=600&q=80',
    '$_unsplash/photo-1505744386214-509ebb5758a5?auto=format&fit=crop&w=900&h=600&q=80',
    '$_unsplash/photo-1586023492125-27b2c045efd7?auto=format&fit=crop&w=900&h=600&q=80',
  ];

  static final _restaurant = [
    '$_unsplash/photo-1414235077428-338989a2e8c0?auto=format&fit=crop&w=1200&h=600&q=80',
    '$_unsplash/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=800&h=600&q=80',
    '$_unsplash/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=800&h=600&q=80',
    '$_unsplash/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=1200&h=600&q=80',
  ];

  static final _business = [
    '$_unsplash/photo-1497366216548-37526070297c?auto=format&fit=crop&w=900&h=600&q=80',
    '$_unsplash/photo-1497366754035-f200968a6e72?auto=format&fit=crop&w=900&h=600&q=80',
    '$_unsplash/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=600&h=600&q=80',
    '$_unsplash/photo-1521737711862-e3b97375f902?auto=format&fit=crop&w=900&h=600&q=80',
  ];

  static final _portfolio = [
    '$_unsplash/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=900&h=600&q=80',
    '$_unsplash/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=900&h=600&q=80',
    '$_unsplash/photo-1551650975-87deedd944d3?auto=format&fit=crop&w=900&h=600&q=80',
    '$_unsplash/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=600&h=600&q=80',
  ];

  static final _gift = [
    '$_unsplash/photo-1513885535751-8b9238bd345a?auto=format&fit=crop&w=1200&h=700&q=80',
    '$_unsplash/photo-1464349095431-e9a21285b5bb?auto=format&fit=crop&w=900&h=600&q=80',
    '$_unsplash/photo-1527529482836-469687ffb197?auto=format&fit=crop&w=900&h=600&q=80',
    '$_unsplash/photo-1527529482836-469687ffb197?auto=format&fit=crop&w=900&h=600&q=80',
  ];
}
