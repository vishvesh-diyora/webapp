import 'package:flutter/material.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_avatar.dart';
import 'package:webapp/features/templates/preview/layout_theme.dart';
import 'package:webapp/features/templates/preview/shared/cart_preview_shell.dart';
import 'package:webapp/features/templates/preview/shared/catalog_item_pricing.dart';
import 'package:webapp/features/templates/preview/shared/catalog_product_utils.dart';
import 'package:webapp/features/templates/preview/shared/site_image.dart';

/// Listing chrome for catalog templates 2–6.
/// Template 1 keeps the original grid and round category tiles.
abstract final class CatalogListingSkins {
  static bool isCustom(int variant) => variant >= 2 && variant <= 6;

  static Widget sectionHeader(String title, LayoutTheme theme, bool compact) {
    final heading = theme.heading(compact, size: compact ? 20 : 24);
    return switch (theme.variant) {
      2 => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: heading.copyWith(fontWeight: FontWeight.w500, letterSpacing: -0.4)),
            SizedBox(height: compact ? 8 : 10),
            Container(height: 1, color: theme.text.withValues(alpha: 0.16)),
          ],
        ),
      3 => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'COLLECTION',
              style: theme.body(compact, size: 10).copyWith(
                    color: theme.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.4,
                  ),
            ),
            SizedBox(height: compact ? 4 : 6),
            Text(title, style: heading.copyWith(height: 1)),
          ],
        ),
      4 => Column(
          children: [
            Text(title, textAlign: TextAlign.center, style: heading.copyWith(fontWeight: FontWeight.w600)),
            SizedBox(height: compact ? 6 : 8),
            Container(
              width: 36,
              height: 3,
              decoration: BoxDecoration(color: theme.accent, borderRadius: BorderRadius.circular(99)),
            ),
          ],
        ),
      5 => Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 16, vertical: compact ? 10 : 12),
          decoration: BoxDecoration(
            color: theme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(theme.radius),
          ),
          child: Text(title, style: heading.copyWith(color: theme.secondary, fontSize: compact ? 18 : 20)),
        ),
      _ => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 28, height: 3, color: theme.primary),
            SizedBox(height: compact ? 8 : 10),
            Text(
              title.toUpperCase(),
              style: heading.copyWith(fontSize: compact ? 16 : 18, letterSpacing: 1.6),
            ),
          ],
        ),
    };
  }

  static Widget categoryBlock({
    required String title,
    required List<Map<String, dynamic>> categories,
    required int selectedIndex,
    required LayoutTheme theme,
    required bool compact,
    required ValueChanged<int> onSelect,
    required String Function(Map<String, dynamic> category) labelOf,
  }) {
    return Padding(
      padding: theme.pad(compact),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          sectionHeader(title, theme, compact),
          SizedBox(height: compact ? 12 : 16),
          _categoryRail(
            categories: categories,
            selectedIndex: selectedIndex,
            theme: theme,
            compact: compact,
            onSelect: onSelect,
            labelOf: labelOf,
          ),
        ],
      ),
    );
  }

  static Widget products({
    required List<Map<String, dynamic>> items,
    required LayoutTheme theme,
    required bool compact,
    required bool showAddToCart,
    required CartScope? cart,
    required ValueChanged<Map<String, dynamic>>? onProductTap,
  }) {
    return switch (theme.variant) {
      2 => _EditorialList(
          items: items,
          theme: theme,
          compact: compact,
          showAddToCart: showAddToCart,
          cart: cart,
          onProductTap: onProductTap,
        ),
      3 => _FeatureMosaic(
          items: items,
          theme: theme,
          compact: compact,
          showAddToCart: showAddToCart,
          cart: cart,
          onProductTap: onProductTap,
        ),
      4 => _OverlayGallery(
          items: items,
          theme: theme,
          compact: compact,
          showAddToCart: showAddToCart,
          cart: cart,
          onProductTap: onProductTap,
        ),
      5 => _LookbookStack(
          items: items,
          theme: theme,
          compact: compact,
          showAddToCart: showAddToCart,
          cart: cart,
          onProductTap: onProductTap,
        ),
      _ => _BleedCatalog(
          items: items,
          theme: theme,
          compact: compact,
          showAddToCart: showAddToCart,
          cart: cart,
          onProductTap: onProductTap,
        ),
    };
  }

  static Widget _categoryRail({
    required List<Map<String, dynamic>> categories,
    required int selectedIndex,
    required LayoutTheme theme,
    required bool compact,
    required ValueChanged<int> onSelect,
    required String Function(Map<String, dynamic> category) labelOf,
  }) {
    if (theme.variant == 5) {
      return Wrap(
        alignment: WrapAlignment.start,
        spacing: compact ? 8 : 10,
        runSpacing: compact ? 8 : 10,
        children: [
          for (var i = 0; i < categories.length; i++)
            _SoftChip(
              label: labelOf(categories[i]),
              image: categories[i]['image'] as String?,
              selected: i == selectedIndex,
              theme: theme,
              compact: compact,
              onTap: () => onSelect(i),
            ),
        ],
      );
    }

    final height = switch (theme.variant) {
      2 => compact ? 40.0 : 44.0,
      3 => compact ? 118.0 : 132.0,
      4 => compact ? 108.0 : 122.0,
      _ => compact ? 64.0 : 72.0,
    };

    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => SizedBox(width: compact ? 10 : 14),
        itemBuilder: (context, index) {
          final category = categories[index];
          final selected = index == selectedIndex;
          final name = labelOf(category);
          final image = category['image'] as String?;
          return switch (theme.variant) {
            2 => _TextTab(
                label: name,
                selected: selected,
                theme: theme,
                compact: compact,
                onTap: () => onSelect(index),
              ),
            3 => _PosterCard(
                label: name,
                image: image,
                index: index,
                selected: selected,
                theme: theme,
                compact: compact,
                onTap: () => onSelect(index),
              ),
            4 => _SquircleTile(
                label: name,
                image: image,
                selected: selected,
                theme: theme,
                compact: compact,
                onTap: () => onSelect(index),
              ),
            _ => _TicketTab(
                label: name,
                image: image,
                selected: selected,
                theme: theme,
                compact: compact,
                onTap: () => onSelect(index),
              ),
          };
        },
      ),
    );
  }
}

class _TextTab extends StatelessWidget {
  const _TextTab({
    required this.label,
    required this.selected,
    required this.theme,
    required this.compact,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final LayoutTheme theme;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.body(compact, size: compact ? 13 : 14).copyWith(
                  color: selected ? theme.text : theme.text.withValues(alpha: 0.45),
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0.2,
                ),
          ),
          SizedBox(height: compact ? 8 : 10),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 2,
            width: selected ? (compact ? 36 : 44) : 0,
            color: theme.primary,
          ),
        ],
      ),
    );
  }
}

class _PosterCard extends StatelessWidget {
  const _PosterCard({
    required this.label,
    required this.image,
    required this.index,
    required this.selected,
    required this.theme,
    required this.compact,
    required this.onTap,
  });

  final String label;
  final String? image;
  final int index;
  final bool selected;
  final LayoutTheme theme;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final width = compact ? 92.0 : 104.0;
    return SizedBox(
      width: width,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(theme.radius),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(theme.radius),
                    border: Border.all(
                      color: selected ? theme.primary : theme.text.withValues(alpha: 0.08),
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(theme.radius),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _fillImage(image, theme),
                        Positioned(
                          left: 6,
                          top: 6,
                          child: Text(
                            (index + 1).toString().padLeft(2, '0'),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: compact ? 10 : 11,
                              fontWeight: FontWeight.w800,
                              shadows: const [Shadow(color: Colors.black54, blurRadius: 6)],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: compact ? 6 : 8),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.body(compact, size: 11).copyWith(
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      color: selected ? theme.primary : theme.text,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SquircleTile extends StatelessWidget {
  const _SquircleTile({
    required this.label,
    required this.image,
    required this.selected,
    required this.theme,
    required this.compact,
    required this.onTap,
  });

  final String label;
  final String? image;
  final bool selected;
  final LayoutTheme theme;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 68.0 : 76.0;
    return SizedBox(
      width: compact ? 76 : 86,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: selected ? theme.primary : Colors.transparent,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  width: size,
                  height: size,
                  child: _fillImage(image, theme),
                ),
              ),
            ),
            SizedBox(height: compact ? 6 : 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.body(compact, size: 11).copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? theme.primary : theme.text.withValues(alpha: 0.7),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoftChip extends StatelessWidget {
  const _SoftChip({
    required this.label,
    required this.image,
    required this.selected,
    required this.theme,
    required this.compact,
    required this.onTap,
  });

  final String label;
  final String? image;
  final bool selected;
  final LayoutTheme theme;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : theme.text;
    return Material(
      color: selected ? theme.primary : theme.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: EdgeInsets.fromLTRB(compact ? 6 : 8, compact ? 6 : 7, compact ? 12 : 14, compact ? 6 : 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? theme.primary : theme.primary.withValues(alpha: 0.18)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipOval(
                child: SizedBox(
                  width: compact ? 26 : 30,
                  height: compact ? 26 : 30,
                  child: _fillImage(image, theme),
                ),
              ),
              SizedBox(width: compact ? 8 : 10),
              Text(
                label,
                style: theme.body(compact, size: 12).copyWith(color: fg, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TicketTab extends StatelessWidget {
  const _TicketTab({
    required this.label,
    required this.image,
    required this.selected,
    required this.theme,
    required this.compact,
    required this.onTap,
  });

  final String label;
  final String? image;
  final bool selected;
  final LayoutTheme theme;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? theme.primary.withValues(alpha: 0.1) : theme.surface,
      borderRadius: BorderRadius.circular(theme.radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(theme.radius),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: compact ? 6 : 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(theme.radius),
            border: Border.all(color: selected ? theme.primary : theme.text.withValues(alpha: 0.12)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  width: compact ? 36 : 42,
                  height: compact ? 36 : 42,
                  child: _fillImage(image, theme),
                ),
              ),
              SizedBox(width: compact ? 8 : 10),
              Text(
                label,
                style: theme.body(compact, size: 12).copyWith(
                      fontWeight: FontWeight.w700,
                      color: selected ? theme.primary : theme.text,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditorialList extends StatelessWidget {
  const _EditorialList({
    required this.items,
    required this.theme,
    required this.compact,
    required this.showAddToCart,
    required this.cart,
    required this.onProductTap,
  });

  final List<Map<String, dynamic>> items;
  final LayoutTheme theme;
  final bool compact;
  final bool showAddToCart;
  final CartScope? cart;
  final ValueChanged<Map<String, dynamic>>? onProductTap;

  @override
  Widget build(BuildContext context) {
    final thumb = compact ? 84.0 : 104.0;
    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          _ProductTap(
            onTap: onProductTap == null ? null : () => onProductTap!(items[i]),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: compact ? 12 : 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _thumb(items[i], theme, thumb, radius: 0),
                  SizedBox(width: compact ? 12 : 16),
                  Expanded(child: _copy(items[i], theme, compact, showAddToCart, cart, stacked: true)),
                ],
              ),
            ),
          ),
          if (i != items.length - 1) Container(height: 1, color: theme.text.withValues(alpha: 0.1)),
        ],
      ],
    );
  }
}

class _FeatureMosaic extends StatelessWidget {
  const _FeatureMosaic({
    required this.items,
    required this.theme,
    required this.compact,
    required this.showAddToCart,
    required this.cart,
    required this.onProductTap,
  });

  final List<Map<String, dynamic>> items;
  final LayoutTheme theme;
  final bool compact;
  final bool showAddToCart;
  final CartScope? cart;
  final ValueChanged<Map<String, dynamic>>? onProductTap;

  @override
  Widget build(BuildContext context) {
    final feature = items.first;
    final rest = items.skip(1).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ProductTap(
          onTap: onProductTap == null ? null : () => onProductTap!(feature),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(theme.radius),
            child: AspectRatio(
              aspectRatio: compact ? 1.35 : 1.7,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _fillImage(_leadImage(feature), theme),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                      ),
                    ),
                  ),
                  Positioned(
                    left: compact ? 12 : 16,
                    right: compact ? 12 : 16,
                    bottom: compact ? 12 : 16,
                    child: _overlayCopy(feature, theme, compact, showAddToCart, cart, light: true),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (rest.isNotEmpty) ...[
          SizedBox(height: compact ? 12 : 16),
          _MeasuredGrid(
            items: rest,
            theme: theme,
            compact: compact,
            showAddToCart: showAddToCart,
            cart: cart,
            onProductTap: onProductTap,
      imageAspect: 1,
      textBlock: compact ? 156 : 172,
          ),
        ],
      ],
    );
  }
}

class _OverlayGallery extends StatelessWidget {
  const _OverlayGallery({
    required this.items,
    required this.theme,
    required this.compact,
    required this.showAddToCart,
    required this.cart,
    required this.onProductTap,
  });

  final List<Map<String, dynamic>> items;
  final LayoutTheme theme;
  final bool compact;
  final bool showAddToCart;
  final CartScope? cart;
  final ValueChanged<Map<String, dynamic>>? onProductTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 840 ? 3 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: compact ? 10 : 14,
            mainAxisSpacing: compact ? 10 : 14,
            childAspectRatio: compact ? 0.78 : 0.82,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _ProductTap(
              onTap: onProductTap == null ? null : () => onProductTap!(item),
              borderRadius: theme.radius,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(theme.radius),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _fillImage(_leadImage(item), theme),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0xCC111827)],
                          stops: [0.45, 1],
                        ),
                      ),
                    ),
                    if (catalogIsBestSeller(item))
                      Positioned(top: 8, left: 8, child: _Badge(label: 'Best seller', theme: theme, compact: compact)),
                    Positioned(
                      left: 10,
                      right: 10,
                      bottom: 10,
                      child: _overlayCopy(item, theme, compact, showAddToCart, cart, light: true),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _LookbookStack extends StatelessWidget {
  const _LookbookStack({
    required this.items,
    required this.theme,
    required this.compact,
    required this.showAddToCart,
    required this.cart,
    required this.onProductTap,
  });

  final List<Map<String, dynamic>> items;
  final LayoutTheme theme;
  final bool compact;
  final bool showAddToCart;
  final CartScope? cart;
  final ValueChanged<Map<String, dynamic>>? onProductTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) SizedBox(height: compact ? 14 : 18),
          _ProductTap(
            onTap: onProductTap == null ? null : () => onProductTap!(items[i]),
            borderRadius: theme.radius,
            child: DecoratedBox(
              decoration: theme.cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(theme.radius)),
                    child: AspectRatio(
                      aspectRatio: compact ? 1.25 : 1.45,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _fillImage(_leadImage(items[i]), theme),
                          if (catalogIsBestSeller(items[i]))
                            Positioned(top: 12, left: 12, child: _Badge(label: 'Best seller', theme: theme, compact: compact)),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(compact ? 14 : 18),
                    child: _copy(items[i], theme, compact, showAddToCart, cart, stacked: false, titleSize: compact ? 16 : 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _BleedCatalog extends StatelessWidget {
  const _BleedCatalog({
    required this.items,
    required this.theme,
    required this.compact,
    required this.showAddToCart,
    required this.cart,
    required this.onProductTap,
  });

  final List<Map<String, dynamic>> items;
  final LayoutTheme theme;
  final bool compact;
  final bool showAddToCart;
  final CartScope? cart;
  final ValueChanged<Map<String, dynamic>>? onProductTap;

  @override
  Widget build(BuildContext context) {
    return _MeasuredGrid(
      items: items,
      theme: theme,
      compact: compact,
      showAddToCart: showAddToCart,
      cart: cart,
      onProductTap: onProductTap,
      imageAspect: 1,
      textBlock: compact ? 156 : 172,
    );
  }
}

class _MeasuredGrid extends StatelessWidget {
  const _MeasuredGrid({
    required this.items,
    required this.theme,
    required this.compact,
    required this.showAddToCart,
    required this.cart,
    required this.onProductTap,
    required this.imageAspect,
    required this.textBlock,
  });

  final List<Map<String, dynamic>> items;
  final LayoutTheme theme;
  final bool compact;
  final bool showAddToCart;
  final CartScope? cart;
  final ValueChanged<Map<String, dynamic>>? onProductTap;
  final double imageAspect;
  final double textBlock;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = compact ? 10.0 : 14.0;
        final columns = constraints.maxWidth >= 980
            ? 4
            : constraints.maxWidth >= 680
                ? 3
                : 2;
        final cellWidth = (constraints.maxWidth - gap * (columns - 1)) / columns;
        final imageHeight = cellWidth / imageAspect;
        final cellHeight = imageHeight + textBlock;
        final aspect = cellWidth / cellHeight;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: gap,
            mainAxisSpacing: gap,
            childAspectRatio: aspect,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _ProductTap(
              onTap: onProductTap == null ? null : () => onProductTap!(item),
              borderRadius: theme.radius,
              child: DecoratedBox(
                decoration: theme.cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(theme.radius)),
                      child: AspectRatio(
                        aspectRatio: imageAspect,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _fillImage(_leadImage(item), theme),
                            if (catalogIsBestSeller(item))
                              Positioned(
                                top: 8,
                                left: 8,
                                child: _Badge(label: 'Best seller', theme: theme, compact: compact),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(compact ? 8 : 10, compact ? 8 : 10, compact ? 8 : 10, compact ? 8 : 10),
                      child: _copy(item, theme, compact, showAddToCart, cart, stacked: false),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ProductTap extends StatelessWidget {
  const _ProductTap({
    required this.child,
    required this.onTap,
    this.borderRadius = 0,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: child,
      ),
    );
  }
}

Widget _copy(
  Map<String, dynamic> item,
  LayoutTheme theme,
  bool compact,
  bool showAddToCart,
  CartScope? cart, {
  required bool stacked,
  double? titleSize,
}) {
  final name = catalogItemLabel(item);
  final subtitle = catalogProductSubtitle(item);
  final sale = catalogSalePrice(item);
  final compareAt = catalogCompareAtPrice(item);
  final title = Text(
    name,
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
    style: theme.heading(compact, size: titleSize ?? (compact ? 14 : 15)),
  );
  final sub = subtitle.isEmpty
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.body(compact, size: 11),
          ),
        );
  final price = _priceLine(sale, compareAt, theme, compact, light: false);
  final add = _addButton(
    show: showAddToCart,
    cart: cart,
    name: name,
    sale: sale,
    theme: theme,
    compact: compact,
  );

  if (stacked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title,
        sub,
        SizedBox(height: compact ? 8 : 10),
        Row(
          children: [
            Expanded(child: price),
            add,
          ],
        ),
      ],
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      title,
      sub,
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(child: price),
          add,
        ],
      ),
    ],
  );
}

Widget _overlayCopy(
  Map<String, dynamic> item,
  LayoutTheme theme,
  bool compact,
  bool showAddToCart,
  CartScope? cart, {
  required bool light,
}) {
  final name = catalogItemLabel(item);
  final sale = catalogSalePrice(item);
  final compareAt = catalogCompareAtPrice(item);
  return Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.heading(compact, size: compact ? 14 : 16).copyWith(color: light ? Colors.white : theme.text),
            ),
            const SizedBox(height: 4),
            _priceLine(sale, compareAt, theme, compact, light: light),
          ],
        ),
      ),
      _addButton(
        show: showAddToCart,
        cart: cart,
        name: name,
        sale: sale,
        theme: theme,
        compact: compact,
        iconColor: theme.secondary,
        background: Colors.white,
      ),
    ],
  );
}

Widget _priceLine(double sale, double? compareAt, LayoutTheme theme, bool compact, {required bool light}) {
  return Wrap(
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: 6,
    children: [
      Text(
        catalogFormatMoney(sale),
        style: theme.body(compact, size: compact ? 12 : 13).copyWith(
              color: light ? Colors.white : theme.primary,
              fontWeight: FontWeight.w800,
            ),
      ),
      if (compareAt != null)
        Text(
          catalogFormatMoney(compareAt),
          style: theme.body(compact, size: 10).copyWith(
                decoration: TextDecoration.lineThrough,
                color: light ? Colors.white70 : theme.text.withValues(alpha: 0.45),
              ),
        ),
    ],
  );
}

Widget _addButton({
  required bool show,
  required CartScope? cart,
  required String name,
  required double sale,
  required LayoutTheme theme,
  required bool compact,
  Color? iconColor,
  Color? background,
}) {
  if (!show || cart == null) return const SizedBox.shrink();
  final size = compact ? 32.0 : 36.0;
  return Material(
    color: background ?? theme.primary.withValues(alpha: 0.1),
    shape: const CircleBorder(),
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: () => cart.addToCart(name, sale),
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(Icons.add_rounded, size: compact ? 18 : 20, color: iconColor ?? theme.primary),
      ),
    ),
  );
}

Widget _thumb(Map<String, dynamic> item, LayoutTheme theme, double size, {required double radius}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: SizedBox(
      width: size,
      height: size,
      child: _fillImage(_leadImage(item), theme),
    ),
  );
}

String? _leadImage(Map<String, dynamic> item) {
  final images = catalogProductImages(item);
  if (images.isEmpty) return null;
  return images.first;
}

Widget _fillImage(String? path, LayoutTheme theme) {
  if (path != null && path.isNotEmpty) {
    return SiteImage(
      path: path,
      width: double.infinity,
      height: double.infinity,
      shape: ProfileImageShape.square,
      fit: BoxFit.cover,
    );
  }
  return ColoredBox(
    color: theme.primary.withValues(alpha: 0.08),
    child: Icon(Icons.image_outlined, color: theme.primary),
  );
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.theme, required this.compact});

  final String label;
  final LayoutTheme theme;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.primary,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: compact ? 7 : 8, vertical: compact ? 3 : 4),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: compact ? 9 : 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
