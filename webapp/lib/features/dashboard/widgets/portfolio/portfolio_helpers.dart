import 'package:flutter/material.dart';
import 'package:webapp/features/dashboard/data/portfolio_mock_data.dart';
import 'package:webapp/features/dashboard/models/category_template.dart';

/// Shared helpers for all portfolio designs.
abstract final class PortfolioDesignHelpers {
  static const profile = PortfolioMockData.profile;
  static const testimonials = PortfolioMockData.testimonials;
  static const highlights = PortfolioMockData.highlights;
  static const projects = PortfolioMockData.projects;

  static List<CategoryContentBlock> sortedBlocks(CategoryTemplate template) {
    final blocks = List<CategoryContentBlock>.from(template.data);
    blocks.sort((a, b) => a.seqId.compareTo(b.seqId));
    return blocks;
  }

  static Widget buildSections({
    required CategoryTemplate template,
    required bool compact,
    required Widget Function(bool compact) profileSection,
    required Widget Function(bool compact) testimonialsSection,
    required Widget Function(bool compact) projectsSection,
  }) {
    final blocks = sortedBlocks(template);
    return ListView(
      padding: EdgeInsets.zero,
      physics: const ClampingScrollPhysics(),
      children: [
        for (final block in blocks)
          switch (block.contentType) {
            ContentType.banners => profileSection(compact),
            ContentType.categories => testimonialsSection(compact),
            ContentType.products => projectsSection(compact),
            _ => const SizedBox.shrink(),
          },
      ],
    );
  }

  static Widget starRating(double rating, {required Color color, double size = 12}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final filled = rating >= index + 1;
        final half = !filled && rating > index;
        return Icon(
          filled
              ? Icons.star_rounded
              : half
                  ? Icons.star_half_rounded
                  : Icons.star_outline_rounded,
          size: size,
          color: color,
        );
      }),
    );
  }

  /// Hero section padding — on mobile, top inset comes from [DevicePreviewInsets].
  static EdgeInsets heroPadding({
    required double pad,
    required bool mobileProfileLayout,
    double? bottom,
  }) {
    return EdgeInsets.fromLTRB(
      pad,
      mobileProfileLayout ? pad : pad + 12,
      pad,
      bottom ?? pad,
    );
  }
}
