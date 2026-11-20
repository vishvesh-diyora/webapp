import 'package:flutter/material.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_avatar.dart';
import 'package:webapp/features/templates/preview/layout_theme.dart';
import 'package:webapp/features/templates/preview/shared/cart_preview_shell.dart';
import 'package:webapp/features/templates/preview/shared/catalog_item_pricing.dart';
import 'package:webapp/features/templates/preview/shared/catalog_product_utils.dart';
import 'package:webapp/features/templates/preview/shared/site_image.dart';

/// Catalog templates 7–11. Templates 1–6 keep their existing layouts.
abstract final class CatalogNextSkins {
  static Widget header(String title, LayoutTheme theme, bool compact) {
    final heading = theme.heading(compact, size: compact ? 22 : 28);
    return switch (theme.variant) {
      7 => Align(
        alignment: Alignment.centerLeft,
        child: DecoratedBox(
          decoration: BoxDecoration(color: theme.accent),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: compact ? 2 : 4),
            child: Text(title.toUpperCase(), style: heading.copyWith(color: theme.text, height: 1)),
          ),
        ),
      ),
      8 => Row(
        children: [
          Icon(Icons.spa_outlined, color: theme.primary, size: compact ? 18 : 20),
          SizedBox(width: compact ? 8 : 10),
          Expanded(
            child: Text(
              title,
              style: heading.copyWith(fontWeight: FontWeight.w500, color: theme.secondary),
            ),
          ),
        ],
      ),
      9 => Row(
        children: [
          Expanded(child: Container(height: 1, color: theme.primary.withValues(alpha: 0.45))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              title.toUpperCase(),
              style: theme
                  .body(compact, size: compact ? 12 : 13)
                  .copyWith(letterSpacing: 3, fontWeight: FontWeight.w500, color: theme.secondary),
            ),
          ),
          Expanded(child: Container(height: 1, color: theme.primary.withValues(alpha: 0.45))),
        ],
      ),
      10 => Text(
        '// ${title.toUpperCase()}_',
        style: heading.copyWith(
          color: theme.primary,
          fontSize: compact ? 16 : 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
      _ => Text(
        title.toUpperCase(),
        textAlign: TextAlign.center,
        style: heading.copyWith(color: theme.text, letterSpacing: compact ? 3 : 5, fontWeight: FontWeight.w300),
      ),
    };
  }

  static Widget categories({
    required List<Map<String, dynamic>> categories,
    required int selectedIndex,
    required LayoutTheme theme,
    required bool compact,
    required ValueChanged<int> onSelect,
    required String Function(Map<String, dynamic> category) labelOf,
  }) {
    return switch (theme.variant) {
      7 => _BrutalIndex(
        categories: categories,
        selectedIndex: selectedIndex,
        theme: theme,
        compact: compact,
        onSelect: onSelect,
        labelOf: labelOf,
      ),
      8 => _Horizontal(
        height: compact ? 52 : 58,
        itemCount: categories.length,
        separator: compact ? 8 : 10,
        itemBuilder: (index) => _OrganicChip(
          label: labelOf(categories[index]),
          image: categories[index]['image'] as String?,
          selected: index == selectedIndex,
          theme: theme,
          compact: compact,
          onTap: () => onSelect(index),
        ),
      ),
      9 => _Horizontal(
        height: compact ? 44 : 48,
        itemCount: categories.length,
        separator: 0,
        itemBuilder: (index) => _RunwayTab(
          label: labelOf(categories[index]),
          selected: index == selectedIndex,
          theme: theme,
          compact: compact,
          showRule: index != categories.length - 1,
          onTap: () => onSelect(index),
        ),
      ),
      10 => _Horizontal(
        height: compact ? 44 : 48,
        itemCount: categories.length,
        separator: compact ? 8 : 10,
        itemBuilder: (index) => _NeonChip(
          label: labelOf(categories[index]),
          selected: index == selectedIndex,
          theme: theme,
          compact: compact,
          onTap: () => onSelect(index),
        ),
      ),
      _ => _MonoTiles(
        categories: categories,
        selectedIndex: selectedIndex,
        theme: theme,
        compact: compact,
        onSelect: onSelect,
        labelOf: labelOf,
      ),
    };
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
      7 => _BrutalGrid(
        items: items,
        theme: theme,
        compact: compact,
        showAddToCart: showAddToCart,
        cart: cart,
        onProductTap: onProductTap,
      ),
      8 => _JournalList(
        items: items,
        theme: theme,
        compact: compact,
        showAddToCart: showAddToCart,
        cart: cart,
        onProductTap: onProductTap,
      ),
      9 => _RunwayGrid(
        items: items,
        theme: theme,
        compact: compact,
        showAddToCart: showAddToCart,
        cart: cart,
        onProductTap: onProductTap,
      ),
      10 => _NeonGrid(
        items: items,
        theme: theme,
        compact: compact,
        showAddToCart: showAddToCart,
        cart: cart,
        onProductTap: onProductTap,
      ),
      _ => _Filmstrip(
        items: items,
        theme: theme,
        compact: compact,
        showAddToCart: showAddToCart,
        cart: cart,
        onProductTap: onProductTap,
      ),
    };
  }
}

class _Horizontal extends StatelessWidget {
  const _Horizontal({
    required this.height,
    required this.itemCount,
    required this.separator,
    required this.itemBuilder,
  });

  final double height;
  final int itemCount;
  final double separator;
  final Widget Function(int index) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        separatorBuilder: (_, _) => SizedBox(width: separator),
        itemBuilder: (context, index) => itemBuilder(index),
      ),
    );
  }
}

class _BrutalIndex extends StatelessWidget {
  const _BrutalIndex({
    required this.categories,
    required this.selectedIndex,
    required this.theme,
    required this.compact,
    required this.onSelect,
    required this.labelOf,
  });

  final List<Map<String, dynamic>> categories;
  final int selectedIndex;
  final LayoutTheme theme;
  final bool compact;
  final ValueChanged<int> onSelect;
  final String Function(Map<String, dynamic> category) labelOf;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = compact ? 8.0 : 10.0;
        const columns = 2;
        final itemWidth = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (var i = 0; i < categories.length; i++)
              SizedBox(
                width: itemWidth,
                child: Material(
                  color: i == selectedIndex ? theme.accent : theme.surface,
                  child: InkWell(
                    onTap: () => onSelect(i),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: compact ? 10 : 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.text, width: i == selectedIndex ? 2.5 : 1.5),
                      ),
                      child: Row(
                        children: [
                          Text(
                            (i + 1).toString().padLeft(2, '0'),
                            style: theme.heading(compact, size: compact ? 14 : 16).copyWith(color: theme.text),
                          ),
                          SizedBox(width: compact ? 8 : 10),
                          Expanded(
                            child: Text(
                              labelOf(categories[i]).toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme
                                  .body(compact, size: compact ? 11 : 12)
                                  .copyWith(color: theme.text, fontWeight: FontWeight.w800, letterSpacing: 0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _OrganicChip extends StatelessWidget {
  const _OrganicChip({
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
      color: selected ? theme.primary : theme.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: EdgeInsets.fromLTRB(4, 4, compact ? 12 : 14, 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? theme.primary : theme.accent.withValues(alpha: 0.7)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipOval(
                child: SizedBox(width: compact ? 32 : 36, height: compact ? 32 : 36, child: _photo(image, theme)),
              ),
              SizedBox(width: compact ? 8 : 10),
              Text(
                label,
                style: theme
                    .body(compact, size: 12)
                    .copyWith(color: selected ? Colors.white : theme.text, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RunwayTab extends StatelessWidget {
  const _RunwayTab({
    required this.label,
    required this.selected,
    required this.theme,
    required this.compact,
    required this.showRule,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final LayoutTheme theme;
  final bool compact;
  final bool showRule;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label.toUpperCase(),
                style: theme
                    .body(compact, size: compact ? 11 : 12)
                    .copyWith(
                      letterSpacing: 1.8,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                      color: selected ? theme.secondary : theme.text.withValues(alpha: 0.55),
                    ),
              ),
              SizedBox(height: compact ? 6 : 8),
              Container(height: 1, width: selected ? 28 : 0, color: theme.primary),
            ],
          ),
          if (showRule)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 14),
              child: Text(
                '·',
                style: TextStyle(color: theme.primary, fontSize: compact ? 16 : 18),
              ),
            ),
        ],
      ),
    );
  }
}

class _NeonChip extends StatelessWidget {
  const _NeonChip({
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
    return Material(
      color: selected ? theme.primary.withValues(alpha: 0.16) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12),
          decoration: BoxDecoration(
            border: Border.all(color: selected ? theme.primary : theme.accent.withValues(alpha: 0.7)),
          ),
          child: Text(
            '> ${label.toUpperCase()}',
            style: theme
                .body(compact, size: 11)
                .copyWith(
                  color: selected ? theme.primary : theme.text,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
          ),
        ),
      ),
    );
  }
}

class _MonoTiles extends StatelessWidget {
  const _MonoTiles({
    required this.categories,
    required this.selectedIndex,
    required this.theme,
    required this.compact,
    required this.onSelect,
    required this.labelOf,
  });

  final List<Map<String, dynamic>> categories;
  final int selectedIndex;
  final LayoutTheme theme;
  final bool compact;
  final ValueChanged<int> onSelect;
  final String Function(Map<String, dynamic> category) labelOf;

  @override
  Widget build(BuildContext context) {
    final spacing = compact ? 8.0 : 10.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final target = compact ? 80.0 : 112.0;
        final available = constraints.maxWidth.isFinite ? constraints.maxWidth : target * 4;
        final columns = ((available + spacing) / (target + spacing)).floor().clamp(2, 12);
        final width = (available - spacing * (columns - 1)) / columns - 0.01;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (var i = 0; i < categories.length; i++)
              SizedBox(
                width: width,
                child: InkWell(
                  onTap: () => onSelect(i),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: width * 0.78,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: i == selectedIndex ? Colors.white : Colors.white24,
                            width: i == selectedIndex ? 2 : 1,
                          ),
                        ),
                        child: _photo(categories[i]['image'] as String?, theme),
                      ),
                      SizedBox(height: compact ? 6 : 8),
                      Text(
                        labelOf(categories[i]).toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme
                            .body(compact, size: 10)
                            .copyWith(
                              color: i == selectedIndex ? Colors.white : theme.text.withValues(alpha: 0.7),
                              letterSpacing: 1,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _BrutalGrid extends StatelessWidget {
  const _BrutalGrid({
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
    return _FitGrid(
      items: items,
      onProductTap: onProductTap,
      columnsFor: (width) => width < 280 ? 1 : (width < 980 ? 2 : 3),
      imageAspect: 1.35,
      textBlock: (compact ? 14 : 16) * theme.fontScale.clamp(1.0, 1.3) * 2.7 + (compact ? 70 : 76),
      builder: (item, onTap) {
        final name = catalogItemLabel(item);
        final sale = catalogSalePrice(item);
        return _Tap(
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.surface,
              border: Border.all(color: theme.text, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(aspectRatio: 1.35, child: _photo(_lead(item), theme)),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(compact ? 10 : 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name.toUpperCase(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.heading(compact, size: compact ? 14 : 16).copyWith(letterSpacing: 0.4),
                        ),
                        const SizedBox(height: 8),
                        const Spacer(),
                        Row(
                          children: [
                            Flexible(
                              child: Container(
                                color: theme.secondary,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: Text(
                                  catalogFormatMoney(sale),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme
                                      .body(compact, size: 12)
                                      .copyWith(color: theme.text, fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _add(showAddToCart, cart, name, sale, theme, compact, icon: theme.text, fill: theme.accent),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _JournalList extends StatelessWidget {
  const _JournalList({
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
        final sideBySide = constraints.maxWidth >= 680;
        return Column(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) SizedBox(height: compact ? 16 : 22),
              _JournalRow(
                item: items[i],
                flip: i.isOdd,
                sideBySide: sideBySide,
                theme: theme,
                compact: compact,
                showAddToCart: showAddToCart,
                cart: cart,
                onTap: onProductTap == null ? null : () => onProductTap!(items[i]),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _JournalRow extends StatelessWidget {
  const _JournalRow({
    required this.item,
    required this.flip,
    required this.sideBySide,
    required this.theme,
    required this.compact,
    required this.showAddToCart,
    required this.cart,
    required this.onTap,
  });

  final Map<String, dynamic> item;
  final bool flip;
  final bool sideBySide;
  final LayoutTheme theme;
  final bool compact;
  final bool showAddToCart;
  final CartScope? cart;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final photo = ClipRRect(
      borderRadius: BorderRadius.circular(theme.radius),
      child: AspectRatio(aspectRatio: sideBySide ? 1.6 : 1.55, child: _photo(_lead(item), theme)),
    );
    final copy = _story(item, theme, compact, showAddToCart, cart);
    final sideCopy = Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: copy);
    return _Tap(
      onTap: onTap,
      borderRadius: theme.radius,
      child: sideBySide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: flip
                  ? [Expanded(flex: 4, child: sideCopy), Expanded(flex: 5, child: photo)]
                  : [Expanded(flex: 5, child: photo), Expanded(flex: 4, child: sideCopy)],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                photo,
                SizedBox(height: compact ? 10 : 12),
                copy,
              ],
            ),
    );
  }
}

class _RunwayGrid extends StatelessWidget {
  const _RunwayGrid({
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
    return _FitGrid(
      items: items,
      onProductTap: onProductTap,
      columnsFor: (width) => width < 280 ? 1 : (width < 1100 ? 2 : 3),
      imageAspect: 0.92,
      textBlock: (compact ? 148 : 162) * theme.fontScale.clamp(1.0, 1.3),
      builder: (item, onTap) {
        final name = catalogItemLabel(item);
        final sale = catalogSalePrice(item);
        final compareAt = catalogCompareAtPrice(item);
        return _Tap(
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.surface,
              border: Border.all(color: theme.primary.withValues(alpha: 0.55)),
            ),
            child: Column(
              children: [
                AspectRatio(aspectRatio: 0.92, child: _photo(_lead(item), theme)),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(12, compact ? 12 : 16, 12, compact ? 12 : 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: theme.heading(compact, size: compact ? 15 : 17).copyWith(fontWeight: FontWeight.w400),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          catalogFormatMoney(sale),
                          style: theme
                              .body(compact, size: 13)
                              .copyWith(color: theme.primary, fontWeight: FontWeight.w700, letterSpacing: 1),
                        ),
                        if (compareAt != null)
                          Text(
                            catalogFormatMoney(compareAt),
                            style: theme
                                .body(compact, size: 10)
                                .copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  color: theme.text.withValues(alpha: 0.4),
                                ),
                          ),
                        const SizedBox(height: 8),
                        _add(
                          showAddToCart,
                          cart,
                          name,
                          sale,
                          theme,
                          compact,
                          icon: theme.secondary,
                          fill: theme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NeonGrid extends StatelessWidget {
  const _NeonGrid({
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
    return _FitGrid(
      items: items,
      onProductTap: onProductTap,
      columnsFor: (width) => width < 280 ? 1 : (width < 1020 ? 2 : 3),
      imageAspect: 1.25,
      textBlock: (compact ? 128 : 134) * theme.fontScale.clamp(1.0, 1.3),
      builder: (item, onTap) {
        final name = catalogItemLabel(item);
        final subtitle = catalogProductSubtitle(item);
        final sale = catalogSalePrice(item);
        return _Tap(
          onTap: onTap,
          child: DecoratedBox(
            decoration: theme.cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 1.25,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _photo(_lead(item), theme),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(height: 3, color: theme.primary),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(compact ? 10 : 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.heading(compact, size: 14),
                        ),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.body(compact, size: 11),
                          ),
                        ],
                        const SizedBox(height: 8),
                        const Spacer(),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                catalogFormatMoney(sale),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme
                                    .body(compact, size: 13)
                                    .copyWith(color: theme.primary, fontWeight: FontWeight.w800),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _add(
                              showAddToCart,
                              cart,
                              name,
                              sale,
                              theme,
                              compact,
                              icon: theme.secondary,
                              fill: theme.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Filmstrip extends StatelessWidget {
  const _Filmstrip({
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
    final cardWidth = compact ? 200.0 : 236.0;
    return SizedBox(
      height: (compact ? 168 : 186) + (compact ? 104 : 112) * theme.fontScale.clamp(1.0, 1.3),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => SizedBox(width: compact ? 12 : 16),
        itemBuilder: (context, index) {
          final item = items[index];
          final name = catalogItemLabel(item);
          final sale = catalogSalePrice(item);
          return SizedBox(
            width: cardWidth,
            child: _Tap(
              onTap: onProductTap == null ? null : () => onProductTap!(item),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.surface,
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: compact ? 168 : 186, child: _photo(_lead(item), theme)),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(compact ? 10 : 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.heading(compact, size: 14).copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            const Spacer(),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    catalogFormatMoney(sale),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme
                                        .body(compact, size: 12)
                                        .copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _add(
                                  showAddToCart,
                                  cart,
                                  name,
                                  sale,
                                  theme,
                                  compact,
                                  icon: theme.secondary,
                                  fill: Colors.white,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FitGrid extends StatelessWidget {
  const _FitGrid({
    required this.items,
    required this.onProductTap,
    required this.columnsFor,
    required this.imageAspect,
    required this.textBlock,
    required this.builder,
  });

  final List<Map<String, dynamic>> items;
  final ValueChanged<Map<String, dynamic>>? onProductTap;
  final int Function(double width) columnsFor;
  final double imageAspect;
  final double textBlock;
  final Widget Function(Map<String, dynamic> item, VoidCallback? onTap) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = 12.0;
        final columns = columnsFor(constraints.maxWidth);
        final cellWidth = (constraints.maxWidth - gap * (columns - 1)) / columns;
        final imageHeight = cellWidth / imageAspect;
        final aspect = cellWidth / (imageHeight + textBlock);
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
            return builder(item, onProductTap == null ? null : () => onProductTap!(item));
          },
        );
      },
    );
  }
}

class _Tap extends StatelessWidget {
  const _Tap({required this.child, required this.onTap, this.borderRadius = 0});

  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(borderRadius), child: child),
    );
  }
}

Widget _story(Map<String, dynamic> item, LayoutTheme theme, bool compact, bool showAddToCart, CartScope? cart) {
  final name = catalogItemLabel(item);
  final subtitle = catalogProductSubtitle(item);
  final sale = catalogSalePrice(item);
  final compareAt = catalogCompareAtPrice(item);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: theme.heading(compact, size: compact ? 18 : 22),
      ),
      if (subtitle.isNotEmpty) ...[
        SizedBox(height: compact ? 6 : 8),
        Text(subtitle, maxLines: 3, overflow: TextOverflow.ellipsis, style: theme.body(compact, size: 12)),
      ],
      SizedBox(height: compact ? 10 : 12),
      Row(
        children: [
          Flexible(
            child: Text(
              catalogFormatMoney(sale),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.body(compact, size: 14).copyWith(color: theme.primary, fontWeight: FontWeight.w800),
            ),
          ),
          if (compareAt != null) ...[
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                catalogFormatMoney(compareAt),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme
                    .body(compact, size: 11)
                    .copyWith(decoration: TextDecoration.lineThrough, color: theme.text.withValues(alpha: 0.45)),
              ),
            ),
          ],
          const SizedBox(width: 8),
          _add(showAddToCart, cart, name, sale, theme, compact, icon: Colors.white, fill: theme.primary),
        ],
      ),
    ],
  );
}

Widget _add(
  bool show,
  CartScope? cart,
  String name,
  double sale,
  LayoutTheme theme,
  bool compact, {
  required Color icon,
  required Color fill,
}) {
  if (!show || cart == null) return const SizedBox.shrink();
  final size = compact ? 32.0 : 36.0;
  return Material(
    color: fill,
    shape: const CircleBorder(),
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: () => cart.addToCart(name, sale),
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(Icons.add_rounded, size: compact ? 18 : 20, color: icon),
      ),
    ),
  );
}

String? _lead(Map<String, dynamic> item) {
  final images = catalogProductImages(item);
  if (images.isEmpty) return null;
  return images.first;
}

Widget _photo(String? path, LayoutTheme theme) {
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
    color: theme.primary.withValues(alpha: 0.12),
    child: Icon(Icons.image_outlined, color: theme.primary),
  );
}
