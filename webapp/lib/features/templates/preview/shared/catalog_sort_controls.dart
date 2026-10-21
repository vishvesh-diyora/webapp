import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webapp/features/templates/preview/layout_theme.dart';
import 'package:webapp/features/templates/preview/shared/catalog_item_pricing.dart';

enum CatalogItemSort {
  popularity,
  priceLowToHigh,
  priceHighToLow,
}

extension CatalogItemSortLabels on CatalogItemSort {
  String get label => switch (this) {
        CatalogItemSort.popularity => 'Popularity',
        CatalogItemSort.priceLowToHigh => 'Price: Low to High',
        CatalogItemSort.priceHighToLow => 'Price: High to Low',
      };
}

double catalogItemPrice(Map<String, dynamic> item) => catalogSalePrice(item);

double catalogPopularityScore(Map<String, dynamic> item, int sourceIndex) {
  final popularity = item['popularity'];
  if (popularity is num) return popularity.toDouble();
  return (1000 - sourceIndex).toDouble();
}

List<Map<String, dynamic>> sortCatalogItems(
  List<Map<String, dynamic>> items,
  CatalogItemSort sort,
) {
  if (items.length <= 1) return List<Map<String, dynamic>>.from(items);

  final indexed = items.asMap().entries.toList();
  switch (sort) {
    case CatalogItemSort.popularity:
      indexed.sort((a, b) => catalogPopularityScore(b.value, b.key).compareTo(
            catalogPopularityScore(a.value, a.key),
          ));
    case CatalogItemSort.priceLowToHigh:
      indexed.sort((a, b) => catalogItemPrice(a.value).compareTo(catalogItemPrice(b.value)));
    case CatalogItemSort.priceHighToLow:
      indexed.sort((a, b) => catalogItemPrice(b.value).compareTo(catalogItemPrice(a.value)));
  }
  return indexed.map((e) => e.value).toList();
}

class CatalogSortDropdown extends StatelessWidget {
  const CatalogSortDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    required this.theme,
    required this.compact,
  });

  final CatalogItemSort value;
  final ValueChanged<CatalogItemSort> onChanged;
  final LayoutTheme theme;
  final bool compact;

  TextStyle _sortTextStyle({
    required bool selected,
    double size = 12,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: (compact ? size * 0.95 : size) * theme.fontScale,
      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      color: selected ? theme.primary : theme.text,
      height: 1.25,
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(999);
    final fontSize = compact ? 12.0 : 13.0;

    return Align(
      alignment: Alignment.centerRight,
      child: PopupMenuButton<CatalogItemSort>(
        initialValue: value,
        color: theme.surface,
        elevation: 10,
        shadowColor: theme.secondary.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.text.withValues(alpha: 0.08)),
        ),
        offset: Offset(0, compact ? 44 : 48),
        onSelected: onChanged,
        itemBuilder: (context) {
          return [
            for (final option in CatalogItemSort.values)
              PopupMenuItem<CatalogItemSort>(
                value: option,
                height: compact ? 40 : 44,
                child: Text(
                  option.label,
                  style: _sortTextStyle(selected: option == value, size: fontSize),
                ),
              ),
          ];
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 14 : 16,
            vertical: compact ? 8 : 10,
          ),
          decoration: BoxDecoration(
            borderRadius: radius,
            color: theme.primary.withValues(alpha: 0.08),
            border: Border.all(color: theme.primary.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: theme.primary.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.swap_vert_rounded, size: compact ? 17 : 19, color: theme.primary),
              SizedBox(width: compact ? 6 : 8),
              Text(
                value.label,
                style: _sortTextStyle(selected: true, size: fontSize),
              ),
              SizedBox(width: compact ? 2 : 4),
              Icon(Icons.keyboard_arrow_down_rounded, size: compact ? 20 : 22, color: theme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
