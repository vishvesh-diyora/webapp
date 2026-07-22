import 'package:flutter/material.dart';
import 'package:webapp/features/templates/preview/shared/variant_category_preview.dart';
import 'package:webapp/features/website/domain/entities/website_document.dart';

class BusinessPreviewRenderer extends StatelessWidget {
  const BusinessPreviewRenderer({
    super.key,
    required this.document,
    required this.compact,
    required this.mobileLayout,
  });

  final WebsiteDocument document;
  final bool compact;
  final bool mobileLayout;

  @override
  Widget build(BuildContext context) {
    return VariantCategoryPreview(
      document: document,
      compact: compact,
      mobileLayout: mobileLayout,
      primaryTitleKey: 'businessName',
      secondaryTitle: 'Services & About',
      tertiaryTitle: 'Gallery & Branches',
    );
  }
}
