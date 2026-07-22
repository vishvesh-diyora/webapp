import 'package:flutter/material.dart';
import 'package:webapp/features/templates/preview/gift/gift_reveal_preview.dart';
import 'package:webapp/features/website/domain/entities/website_document.dart';

class GiftPreviewRenderer extends StatelessWidget {
  const GiftPreviewRenderer({
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
    return GiftRevealPreview(
      document: document,
      compact: compact,
      mobileLayout: mobileLayout,
      layoutVariant: document.templateType.clamp(1, 22),
    );
  }
}
