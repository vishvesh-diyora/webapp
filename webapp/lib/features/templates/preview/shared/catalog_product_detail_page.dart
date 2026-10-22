import 'package:flutter/material.dart';
import 'package:webapp/features/templates/preview/layout_theme.dart';
import 'package:webapp/features/templates/preview/shared/cart_preview_shell.dart';
import 'package:webapp/features/templates/preview/shared/catalog_item_pricing.dart';
import 'package:webapp/features/templates/preview/shared/catalog_product_grid.dart';
import 'package:webapp/features/templates/preview/shared/catalog_product_suggestions_section.dart';
import 'package:webapp/features/templates/preview/shared/catalog_product_utils.dart';
import 'package:webapp/features/templates/preview/shared/site_image.dart';

/// Details sit beside the gallery when width > 80% of height (template product PDP).
bool catalogProductDetailSideBySide(BoxConstraints constraints, BuildContext context) {
  var width = constraints.maxWidth;
  var height = constraints.maxHeight;
  if (!width.isFinite) width = MediaQuery.sizeOf(context).width;
  if (!height.isFinite) height = MediaQuery.sizeOf(context).height;
  return height > 0 && width > height * 0.8;
}

/// In-template product / menu item detail body (ecommerce & restaurant previews).
class CatalogProductDetailView extends StatelessWidget {
  const CatalogProductDetailView({
    super.key,
    required this.item,
    required this.theme,
    required this.compact,
    required this.showAddToCart,
    required this.isRestaurant,
    required this.allProducts,
    required this.onProductTap,
    this.embedInParentScroll = false,
  });

  final Map<String, dynamic> item;
  final LayoutTheme theme;
  final bool compact;
  final bool showAddToCart;
  final bool isRestaurant;
  final List<Map<String, dynamic>> allProducts;
  final ValueChanged<Map<String, dynamic>> onProductTap;
  final bool embedInParentScroll;

  @override
  Widget build(BuildContext context) {
    final cart = CartScope.maybeOf(context);
    final name = catalogItemLabel(item);
    final description = item['description'] as String? ?? '';
    final category = item['category'] as String? ?? '';
    final images = catalogProductImages(item);
    final sale = catalogSalePrice(item);
    final compareAt = catalogCompareAtPrice(item);

    return LayoutBuilder(
      builder: (context, constraints) {
        final sideBySide = catalogProductDetailSideBySide(constraints, context);

        Widget gallery({
          double? maxWidth,
          double? maxHeight,
          bool alignStart = false,
        }) =>
            _CatalogProductImageGallery(
              images: images,
              theme: theme,
              compact: compact,
              maxWidth: maxWidth,
              maxHeight: maxHeight,
              alignStart: alignStart,
            );

        final details = _ProductDetailBody(
          theme: theme,
          compact: compact,
          isWide: sideBySide,
          name: name,
          description: description.isNotEmpty ? description : category,
          categoryLabel: category,
          showCategory: description.isNotEmpty && category.isNotEmpty,
          isBestSeller: catalogIsBestSeller(item),
          sale: sale,
          compareAt: compareAt,
          showAddToCart: showAddToCart,
          cart: cart,
          onAddToCart: cart == null
              ? null
              : () {
                  cart.addToCart(name, sale);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added $name to cart')),
                  );
                },
        );

        final suggestions = CatalogProductSuggestionsSection(
          theme: theme,
          compact: compact,
          isRestaurant: isRestaurant,
          currentItem: item,
          allProducts: allProducts,
          showAddToCart: showAddToCart,
          cart: cart,
          onProductTap: onProductTap,
        );

        final horizontalPad = compact ? 16.0 : 20.0;

        if (!sideBySide) {
          final stacked = [
            gallery(),
            SizedBox(height: compact ? 18 : 22),
            details,
            suggestions,
          ];
          if (embedInParentScroll) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPad,
                compact ? 8 : 12,
                horizontalPad,
                compact ? 24 : 32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: stacked,
              ),
            );
          }
          return ListView(
            padding: EdgeInsets.fromLTRB(
              horizontalPad,
              compact ? 8 : 12,
              horizontalPad,
              compact ? 24 : 32,
            ),
            children: stacked,
          );
        }

        final widePad = compact ? 12.0 : 16.0;
        final gutter = compact ? 12.0 : 16.0;
        final contentWidth = constraints.maxWidth - widePad * 2;
        final viewportHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : MediaQuery.sizeOf(context).height;
        final heroMaxHeight = viewportHeight * 0.72;
        const detailsMinWidthFraction = 0.4;
        final detailsMinWidth = contentWidth * detailsMinWidthFraction;
        final imageMaxWidth =
            (contentWidth - gutter - detailsMinWidth).clamp(1.0, contentWidth);
        final imageBox = CatalogProductGrid.fitImageBox(
          maxWidth: imageMaxWidth,
          maxHeight: heroMaxHeight,
        );

        final wideChildren = [
          SizedBox(
            height: imageBox.height,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                gallery(
                  maxWidth: imageBox.width,
                  maxHeight: imageBox.height,
                  alignStart: true,
                ),
                SizedBox(width: gutter),
                Expanded(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: detailsMinWidth),
                    child: SizedBox(
                      height: imageBox.height,
                      child: _WideDetailPanel(
                        theme: theme,
                        child: details,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          suggestions,
        ];

        if (embedInParentScroll) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              widePad,
              compact ? 8 : 12,
              widePad,
              compact ? 16 : 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: wideChildren,
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            widePad,
            compact ? 8 : 12,
            widePad,
            compact ? 16 : 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: wideChildren,
          ),
        );
      },
    );
  }
}

class _WideDetailPanel extends StatelessWidget {
  const _WideDetailPanel({
    required this.theme,
    required this.child,
  });

  final LayoutTheme theme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border.all(color: theme.text.withValues(alpha: 0.08)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.secondary.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(-4, 0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
          child: child,
        ),
      ),
    );
  }
}

class _ProductDetailBody extends StatelessWidget {
  const _ProductDetailBody({
    required this.theme,
    required this.compact,
    required this.isWide,
    required this.name,
    required this.description,
    required this.categoryLabel,
    required this.showCategory,
    required this.isBestSeller,
    required this.sale,
    required this.compareAt,
    required this.showAddToCart,
    required this.cart,
    required this.onAddToCart,
  });

  final LayoutTheme theme;
  final bool compact;
  final bool isWide;
  final String name;
  final String description;
  final String categoryLabel;
  final bool showCategory;
  final bool isBestSeller;
  final double sale;
  final double? compareAt;
  final bool showAddToCart;
  final CartScope? cart;
  final VoidCallback? onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isBestSeller) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.primary,
                    Color.lerp(theme.primary, theme.accent, 0.6) ?? theme.accent,
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Best seller',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 11 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(height: compact ? 12 : 14),
        ],
        if (showCategory) ...[
          Text(
            categoryLabel.toUpperCase(),
            style: theme.body(compact, size: 10).copyWith(
              letterSpacing: 1.6,
              color: theme.text.withValues(alpha: 0.5),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: compact ? 6 : 8),
        ],
        Text(
          name,
          style: theme.heading(compact, size: isWide ? (compact ? 26 : 30) : (compact ? 22 : 26)),
        ),
        if (description.isNotEmpty) ...[
          SizedBox(height: compact ? 10 : 14),
          Text(
            description,
            style: theme.body(compact, size: isWide ? 15 : 14).copyWith(
              height: 1.55,
              color: theme.text.withValues(alpha: 0.82),
            ),
          ),
        ],
        SizedBox(height: compact ? 16 : 20),
        Divider(height: 1, color: theme.text.withValues(alpha: 0.1)),
        SizedBox(height: compact ? 16 : 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              catalogFormatMoney(sale),
              style: theme.heading(compact, size: isWide ? 28 : 22).copyWith(color: theme.primary),
            ),
            if (compareAt != null) ...[
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  catalogFormatMoney(compareAt!),
                  style: theme.body(compact, size: 14).copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: theme.text.withValues(alpha: 0.45),
                  ),
                ),
              ),
            ],
          ],
        ),
        if (showAddToCart && cart != null && onAddToCart != null) ...[
          SizedBox(height: compact ? 22 : 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onAddToCart,
              icon: const Icon(Icons.add_shopping_cart_outlined),
              label: const Text('Add to cart'),
              style: FilledButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: compact ? 15 : 17),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _CatalogProductImageGallery extends StatefulWidget {
  const _CatalogProductImageGallery({
    required this.images,
    required this.theme,
    required this.compact,
    this.maxWidth,
    this.maxHeight,
    this.alignStart = false,
  });

  final List<String> images;
  final LayoutTheme theme;
  final bool compact;
  final double? maxWidth;
  final double? maxHeight;
  final bool alignStart;

  static const double _listingAspect = CatalogProductGrid.imageAspect;

  static Size _fitMainImageBox({
    required bool compact,
    double? maxWidth,
    double? maxHeight,
  }) {
    final availW = maxWidth ?? double.infinity;
    final availH = maxHeight ?? double.infinity;

    if (availW.isFinite && availH.isFinite) {
      return CatalogProductGrid.fitImageBox(maxWidth: availW, maxHeight: availH);
    }
    if (availW.isFinite) {
      final w = availW;
      final h = w / _listingAspect;
      return Size(w, h);
    }
    return const Size(280, 336);
  }

  @override
  State<_CatalogProductImageGallery> createState() => _CatalogProductImageGalleryState();
}

class _CatalogProductImageGalleryState extends State<_CatalogProductImageGallery> {
  late final PageController _pageController;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _CatalogProductImageGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.images.length != widget.images.length) {
      _index = 0;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    }
  }

  Widget _buildFramedImage(Size mainBox) {
    final images = widget.images;
    final radius = CatalogProductGrid.imageRadius;
    final multi = images.length > 1;

    return SizedBox(
      width: mainBox.width,
      height: mainBox.height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: widget.theme.text.withValues(alpha: 0.08)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (images.isEmpty)
                ColoredBox(
                  color: widget.theme.primary.withValues(alpha: 0.06),
                  child: Icon(Icons.image_outlined, size: 48, color: widget.theme.primary),
                )
              else if (!multi)
                SiteImage(
                  path: images.first,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                )
              else
                PageView.builder(
                  controller: _pageController,
                  itemCount: images.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) => SiteImage(
                    path: images[i],
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              if (multi)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: widget.compact ? 10 : 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < images.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: _index == i ? 18 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: _index == i
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(99),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.maxWidth != null && widget.maxHeight != null) {
      final box = _CatalogProductImageGallery._fitMainImageBox(
        compact: widget.compact,
        maxWidth: widget.maxWidth,
        maxHeight: widget.maxHeight,
      );
      return Align(
        alignment: widget.alignStart ? Alignment.topLeft : Alignment.topCenter,
        child: _buildFramedImage(box),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final box = _CatalogProductImageGallery._fitMainImageBox(
          compact: widget.compact,
          maxWidth: constraints.maxWidth,
          maxHeight: constraints.maxHeight.isFinite ? constraints.maxHeight : null,
        );
        return Align(
          alignment: widget.alignStart ? Alignment.topLeft : Alignment.topCenter,
          child: _buildFramedImage(box),
        );
      },
    );
  }
}
