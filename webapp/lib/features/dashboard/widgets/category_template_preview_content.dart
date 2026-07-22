import 'package:flutter/material.dart';
import 'package:webapp/features/templates/preview/website_preview_renderer.dart';
import 'package:webapp/features/website/domain/entities/website_document.dart';

/// Template preview shown inside device frames or detail panels.
class CategoryTemplatePreviewContent extends StatelessWidget {
  const CategoryTemplatePreviewContent({
    super.key,
    required this.document,
    this.compact = false,
    this.mobileProfileLayout = true,
  });

  final WebsiteDocument document;
  final bool compact;
  final bool mobileProfileLayout;

  @override
  Widget build(BuildContext context) {
    return WebsitePreviewRenderer(
      document: document,
      compact: compact,
      mobileProfileLayout: mobileProfileLayout,
    );
  }
}
