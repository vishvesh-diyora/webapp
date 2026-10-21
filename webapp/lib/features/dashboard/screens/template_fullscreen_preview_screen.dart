import 'package:flutter/material.dart';
import 'package:webapp/features/dashboard/widgets/category_template_preview_content.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_screen_background.dart';
import 'package:webapp/features/website/domain/entities/website_document.dart';

/// Full-viewport template preview (no device chrome).
class TemplateFullscreenPreviewScreen extends StatelessWidget {
  const TemplateFullscreenPreviewScreen({
    super.key,
    required this.document,
    required this.compact,
    required this.mobileProfileLayout,
  });

  final WebsiteDocument document;
  final bool compact;
  final bool mobileProfileLayout;

  @override
  Widget build(BuildContext context) {
    final screenBg = PreviewScreenBackground.forTemplate(
      document,
      mobileProfileLayout: mobileProfileLayout,
    );

    return Scaffold(
      backgroundColor: screenBg.color ?? const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Full screen preview',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        shadowColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE2E8F0)),
        ),
      ),
      body: DecoratedBox(
        decoration: screenBg.decoration ?? BoxDecoration(color: screenBg.color),
        child: CategoryTemplatePreviewContent(
          key: ValueKey(
            'fullscreen_${document.type}_${document.templateType}_${compact}_$mobileProfileLayout',
          ),
          document: document,
          compact: compact,
          mobileProfileLayout: mobileProfileLayout,
        ),
      ),
    );
  }
}
