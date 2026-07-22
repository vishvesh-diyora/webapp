import 'package:flutter/material.dart';
import 'package:webapp/features/templates/preview/shared/cart_preview_shell.dart';
import 'package:webapp/features/templates/preview/shared/variant_category_preview.dart';
import 'package:webapp/features/website/domain/entities/website_document.dart';

class EcommercePreviewRenderer extends StatelessWidget {
  const EcommercePreviewRenderer({
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
    return CartPreviewShell(
      document: document,
      compact: compact,
      whatsappField: 'whatsapp',
      child: VariantCategoryPreview(
        document: document,
        compact: compact,
        mobileLayout: mobileLayout,
        primaryTitleKey: 'storeName',
        secondaryTitle: 'Categories',
        tertiaryTitle: 'Products',
        showAddToCart: true,
      ),
    );
  }
}
