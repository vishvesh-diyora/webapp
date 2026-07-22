import 'package:flutter/material.dart';
import 'package:webapp/core/domain/category_type.dart';
import 'package:webapp/features/templates/preview/business/business_preview_renderer.dart';
import 'package:webapp/features/templates/preview/ecommerce/ecommerce_preview_renderer.dart';
import 'package:webapp/features/templates/preview/gift/gift_preview_renderer.dart';
import 'package:webapp/features/templates/preview/portfolio/portfolio_preview_renderer.dart';
import 'package:webapp/features/templates/preview/restaurant/restaurant_preview_renderer.dart';
import 'package:webapp/features/website/domain/entities/website_document.dart';

/// Renders any website document for in-app preview — fully JSON-driven.
class WebsitePreviewRenderer extends StatelessWidget {
  const WebsitePreviewRenderer({
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
    return switch (document.type) {
      CategoryType.portfolio => PortfolioPreviewRenderer(
          document: document,
          compact: compact,
          mobileProfileLayout: mobileProfileLayout,
        ),
      CategoryType.businessProfile => BusinessPreviewRenderer(
          document: document,
          compact: compact,
          mobileLayout: mobileProfileLayout,
        ),
      CategoryType.giftReveal => GiftPreviewRenderer(
          document: document,
          compact: compact,
          mobileLayout: mobileProfileLayout,
        ),
      CategoryType.restaurantMenu => RestaurantPreviewRenderer(
          document: document,
          compact: compact,
          mobileLayout: mobileProfileLayout,
        ),
      CategoryType.ecommerce => EcommercePreviewRenderer(
          document: document,
          compact: compact,
          mobileLayout: mobileProfileLayout,
        ),
      _ => Center(
          child: Text(
            'Unsupported category type ${document.type}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: compact ? 12 : 14),
          ),
        ),
    };
  }
}
