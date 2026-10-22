import 'package:flutter/material.dart';
import 'package:webapp/features/templates/preview/layout_theme.dart';
import 'package:webapp/features/templates/preview/shared/cart_preview_shell.dart';
import 'package:webapp/features/templates/preview/shared/catalog_product_grid.dart';
import 'package:webapp/features/templates/preview/shared/catalog_product_utils.dart';

/// “You may also like” grid below product detail (same cells as catalog listing).
class CatalogProductSuggestionsSection extends StatelessWidget {
  const CatalogProductSuggestionsSection({
    super.key,
    required this.theme,
    required this.compact,
    required this.isRestaurant,
    required this.currentItem,
    required this.allProducts,
    required this.showAddToCart,
    this.cart,
    required this.onProductTap,
  });

  final LayoutTheme theme;
  final bool compact;
  final bool isRestaurant;
  final Map<String, dynamic> currentItem;
  final List<Map<String, dynamic>> allProducts;
  final bool showAddToCart;
  final CartScope? cart;
  final ValueChanged<Map<String, dynamic>> onProductTap;

  @override
  Widget build(BuildContext context) {
    final suggestions = catalogSuggestionProducts(
      all: allProducts,
      current: currentItem,
    );
    if (suggestions.isEmpty) return const SizedBox.shrink();

    final title = isRestaurant ? 'More from the menu' : 'You may also like';

    return Padding(
      padding: EdgeInsets.only(top: compact ? 28 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Divider(height: 1, color: theme.text.withValues(alpha: 0.1)),
          SizedBox(height: compact ? 20 : 24),
          Text(
            title,
            style: theme.heading(compact, size: compact ? 18 : 20),
          ),
          SizedBox(height: compact ? 14 : 18),
          CatalogProductGrid(
            items: suggestions,
            theme: theme,
            compact: compact,
            showAddToCart: showAddToCart,
            cart: cart,
            onProductTap: onProductTap,
          ),
        ],
      ),
    );
  }
}
