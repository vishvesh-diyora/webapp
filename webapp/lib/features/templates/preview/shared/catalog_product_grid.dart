import 'package:flutter/material.dart';
import 'package:webapp/features/templates/preview/layout_theme.dart';
import 'package:webapp/features/templates/preview/shared/cart_preview_shell.dart';
import 'package:webapp/features/templates/preview/shared/catalog_item_pricing.dart';
import 'package:webapp/features/templates/preview/shared/catalog_product_utils.dart';
import 'package:webapp/features/templates/preview/shared/site_image.dart';

/// Responsive catalog product grid (ecommerce & restaurant listings).
class CatalogProductGrid extends StatelessWidget {
  const CatalogProductGrid({
    super.key,
    required this.items,
    required this.theme,
    required this.compact,
    required this.showAddToCart,
    this.cart,
    this.onProductTap,
  });

  final List<Map<String, dynamic>> items;
  final LayoutTheme theme;
  final bool compact;
  final bool showAddToCart;
  final CartScope? cart;
  final ValueChanged<Map<String, dynamic>>? onProductTap;

  static const double cardRadius = 8;
  static const double imageRadius = 10;
  static const double imageAspect = 1 / 1.2;

  /// Largest listing-ratio box that fits inside [maxWidth] × [maxHeight].
  static Size fitImageBox({
    required double maxWidth,
    required double maxHeight,
  }) {
    var width = maxWidth;
    var height = width / imageAspect;
    if (height > maxHeight) {
      height = maxHeight;
      width = height * imageAspect;
    }
    return Size(width, height);
  }

  int _columns(double width) {
    const minColumns = 2;
    const maxColumns = 6;
    final gap = compact ? 8.0 : 12.0;
    final targetCell = compact ? 152.0 : 176.0;
    final columns = ((width + gap) / (targetCell + gap)).floor();
    return columns.clamp(minColumns, maxColumns);
  }

  double _cellAspectRatio(double gridWidth, int columns) {
    final gap = compact ? 8.0 : 12.0;
    final cellWidth = (gridWidth - gap * (columns - 1)) / columns;
    final pad = compact ? 8.0 : 10.0;
    final innerWidth = cellWidth - 2 * pad;
    final imageHeight = innerWidth / imageAspect;
    final titleBlock = compact ? 32.0 : 36.0;
    final subtitleBlock = compact ? 14.0 : 16.0;
    final priceBlock = compact ? 28.0 : 32.0;
    final verticalGaps = compact ? 12.0 : 14.0;
    final cellHeight = 2 * pad + imageHeight + titleBlock + subtitleBlock + priceBlock + verticalGaps;
    return cellWidth / cellHeight;
  }

  BoxDecoration _cardDecoration() {
    final base = theme.cardDecoration();
    return BoxDecoration(
      color: base.color,
      border: base.border,
      boxShadow: base.boxShadow,
      borderRadius: BorderRadius.circular(cardRadius),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _columns(constraints.maxWidth);
        final aspect = _cellAspectRatio(constraints.maxWidth, columns);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: compact ? 8 : 12,
            mainAxisSpacing: compact ? 8 : 12,
            childAspectRatio: aspect,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) => _CatalogProductCell(
            item: items[index],
            theme: theme,
            compact: compact,
            showAddToCart: showAddToCart,
            cart: cart,
            cardDecoration: _cardDecoration(),
            onTap: onProductTap == null ? null : () => onProductTap!(items[index]),
          ),
        );
      },
    );
  }
}

class _CatalogProductCell extends StatelessWidget {
  const _CatalogProductCell({
    required this.item,
    required this.theme,
    required this.compact,
    required this.showAddToCart,
    required this.cart,
    required this.cardDecoration,
    this.onTap,
  });

  final Map<String, dynamic> item;
  final LayoutTheme theme;
  final bool compact;
  final bool showAddToCart;
  final CartScope? cart;
  final BoxDecoration cardDecoration;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final name = catalogItemLabel(item);
    final subtitle = catalogProductSubtitle(item);
    final sale = catalogSalePrice(item);
    final compareAt = catalogCompareAtPrice(item);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(CatalogProductGrid.cardRadius),
        child: Ink(
          decoration: cardDecoration,
          child: Padding(
            padding: EdgeInsets.all(compact ? 8 : 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ProductImage(item: item, theme: theme, compact: compact),
                SizedBox(height: compact ? 6 : 8),
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.heading(compact, size: compact ? 12 : 13),
                ),
                if (subtitle.isNotEmpty) ...[
                  SizedBox(height: compact ? 2 : 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.body(compact, size: 10),
                  ),
                ],
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: _PriceRow(
                        sale: sale,
                        compareAt: compareAt,
                        theme: theme,
                        compact: compact,
                      ),
                    ),
                    if (showAddToCart && cart != null)
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        icon: const Icon(Icons.add_circle_outline, size: 20),
                        onPressed: () => cart!.addToCart(name, sale),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({
    required this.item,
    required this.theme,
    required this.compact,
  });

  final Map<String, dynamic> item;
  final LayoutTheme theme;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final images = catalogProductImages(item);
    final path = images.isNotEmpty ? images.first : null;
    final bestSeller = catalogIsBestSeller(item);

    return AspectRatio(
      aspectRatio: CatalogProductGrid.imageAspect,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(CatalogProductGrid.imageRadius),
            child: path != null && path.isNotEmpty
                ? SiteImage(
                    path: path,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    borderRadius: CatalogProductGrid.imageRadius,
                  )
                : Container(
                    color: theme.primary.withValues(alpha: 0.1),
                    alignment: Alignment.center,
                    child: Icon(Icons.image_outlined, color: theme.primary, size: compact ? 24 : 28),
                  ),
          ),
          if (bestSeller) _BestSellerBadge(theme: theme, compact: compact),
        ],
      ),
    );
  }
}

class _BestSellerBadge extends StatelessWidget {
  const _BestSellerBadge({required this.theme, required this.compact});

  final LayoutTheme theme;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: compact ? 6 : 8,
      left: compact ? 6 : 8,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.primary,
              Color.lerp(theme.primary, theme.accent, 0.65) ?? theme.accent,
            ],
          ),
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: theme.primary.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: compact ? 7 : 8, vertical: compact ? 3 : 4),
          child: Text(
            'Best seller',
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 9 : 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.sale,
    required this.compareAt,
    required this.theme,
    required this.compact,
  });

  final double sale;
  final double? compareAt;
  final LayoutTheme theme;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: compact ? 5 : 6,
      children: [
        Text(
          catalogFormatMoney(sale),
          style: theme.body(compact, size: 11).copyWith(
            color: theme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (compareAt != null)
          Text(
            catalogFormatMoney(compareAt!),
            style: theme.body(compact, size: 9).copyWith(
              decoration: TextDecoration.lineThrough,
              color: theme.text.withValues(alpha: 0.45),
            ),
          ),
      ],
    );
  }
}
