import 'package:flutter/material.dart';
import 'package:webapp/core/domain/category_type.dart';
import 'package:webapp/features/templates/preview/layout_theme.dart';
import 'package:webapp/features/templates/preview/layouts/site_layout_blocks.dart';
import 'package:webapp/features/templates/preview/shared/cart_preview_shell.dart';
import 'package:webapp/features/templates/preview/shared/catalog_auto_banner_carousel.dart';
import 'package:webapp/features/templates/preview/shared/catalog_item_pricing.dart';
import 'package:webapp/features/templates/preview/shared/catalog_search_icon.dart';
import 'package:webapp/features/templates/preview/shared/catalog_sort_controls.dart';
import 'package:webapp/features/templates/preview/shared/catalog_product_detail_page.dart';
import 'package:webapp/features/templates/preview/shared/catalog_product_grid.dart';
import 'package:webapp/features/templates/preview/shared/catalog_product_reels_carousel.dart';
import 'package:webapp/features/templates/preview/shared/catalog_product_utils.dart';
import 'package:webapp/features/templates/preview/shared/catalog_store_footer.dart';
import 'package:webapp/features/templates/preview/shared/site_image.dart';
import 'package:webapp/features/website/domain/entities/website_document.dart';

/// JSON-driven preview for business, restaurant, and ecommerce — 22 layouts via theme.
class VariantCategoryPreview extends StatefulWidget {
  const VariantCategoryPreview({
    super.key,
    required this.document,
    required this.compact,
    required this.mobileLayout,
    required this.primaryTitleKey,
    required this.secondaryTitle,
    required this.tertiaryTitle,
    this.showAddToCart = false,
  });

  final WebsiteDocument document;
  final bool compact;
  final bool mobileLayout;
  final String primaryTitleKey;
  final String secondaryTitle;
  final String tertiaryTitle;
  final bool showAddToCart;

  @override
  State<VariantCategoryPreview> createState() => _VariantCategoryPreviewState();
}

class _VariantCategoryPreviewState extends State<VariantCategoryPreview> {
  static const _productDetailRoute = '/product';

  final GlobalKey<NavigatorState> _catalogNavigatorKey = GlobalKey<NavigatorState>();

  int _selectedCategoryIndex = 0;
  CatalogItemSort _catalogSort = CatalogItemSort.popularity;
  bool _catalogSearchOpen = false;
  String _searchQuery = '';

  bool get compact => widget.compact;

  bool get mobileLayout => widget.mobileLayout;

  @override
  void didUpdateWidget(covariant VariantCategoryPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.document != widget.document) {
      _selectedCategoryIndex = 0;
      _catalogSort = CatalogItemSort.popularity;
      _catalogSearchOpen = false;
      _searchQuery = '';
    }
  }

  void _openCatalogSearch() {
    setState(() {
      _catalogSearchOpen = true;
      _searchQuery = '';
    });
  }

  void _closeCatalogSearch() {
    setState(() {
      _catalogSearchOpen = false;
      _searchQuery = '';
    });
  }

  List<Map<String, dynamic>> _filterCatalogItemsByQuery(List<Map<String, dynamic>> items) {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return items;
    return items.where((item) {
      final name = (item['name'] as String? ?? item['title'] as String? ?? '').toLowerCase();
      return name.contains(q);
    }).toList();
  }

  String _catalogSearchNavTitle() {
    return widget.document.type == CategoryType.restaurantMenu ? 'Search menu' : 'Search products';
  }

  bool get _isRestaurantCatalog => widget.document.type == CategoryType.restaurantMenu;

  void _openProductDetail(Map<String, dynamic> item) {
    _catalogNavigatorKey.currentState?.pushNamed(
      _productDetailRoute,
      arguments: item,
    );
  }

  String _catalogProductNavTitle() {
    return _isRestaurantCatalog ? 'Menu item' : 'Product';
  }

  Widget _catalogProductsBlock({
    required String title,
    required List<Map<String, dynamic>> items,
    required LayoutTheme theme,
    required CartScope? cart,
    required ValueChanged<Map<String, dynamic>> onProductTap,
  }) {
    final sorted = sortCatalogItems(items, _catalogSort);
    return _block(
      title,
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CatalogSortDropdown(
            value: _catalogSort,
            theme: theme,
            compact: compact,
            onChanged: (value) => setState(() => _catalogSort = value),
          ),
          SizedBox(height: compact ? 10 : 12),
          sorted.isEmpty
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: compact ? 8 : 12),
                  child: Text(
                    _catalogSearchOpen
                        ? (_searchQuery.trim().isEmpty
                            ? 'No items to show.'
                            : 'No matches found.')
                        : 'No items in this category yet.',
                    style: theme.body(compact, size: 12),
                  ),
                )
              : _tertiaryItems(sorted, theme, theme.tertiaryLayout, cart, onProductTap: onProductTap),
        ],
      ),
      theme,
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = widget.document.blockByContentType(ContentType.primary)?.contentData ?? const {};
    final secondary = widget.document.blockByContentType(ContentType.secondary)?.contentData ?? const {};
    final tertiary = widget.document.blockByContentType(ContentType.tertiary)?.contentData ?? const {};
    final theme = LayoutTheme.fromContent(primary);
    final cart = CartScope.maybeOf(context);
    final logo = widget.document.logo.isNotEmpty ? widget.document.logo : primary['logo'] as String?;
    final title = primary[widget.primaryTitleKey] as String? ?? widget.document.name;
    final tagline = primary['tagline'] as String? ?? widget.document.subname;
    final phone = primary['phone'] as String? ?? primary['whatsapp'] as String? ?? '';
    final email = primary['email'] as String? ?? '';

    final isCatalogType = widget.document.type == CategoryType.ecommerce ||
        widget.document.type == CategoryType.restaurantMenu;
    final catalogItems = isCatalogType
        ? _list(tertiary, keys: const ['products', 'menuItems'])
        : const <Map<String, dynamic>>[];

    if (isCatalogType) {
      return ColoredBox(
        color: theme.background,
        child: Navigator(
          key: _catalogNavigatorKey,
          onGenerateRoute: (settings) {
            final name = settings.name ?? '/';
            if (name == _productDetailRoute) {
              final item = settings.arguments! as Map<String, dynamic>;
              return MaterialPageRoute<void>(
                settings: settings,
                builder: (navContext) => _buildCatalogProductDetailScreen(
                  navContext: navContext,
                  item: item,
                  theme: theme,
                  cart: cart,
                  catalogItems: catalogItems,
                ),
              );
            }
            return MaterialPageRoute<void>(
              builder: (_) => _buildCatalogMainScreen(
                primary: primary,
                secondary: secondary,
                tertiary: tertiary,
                theme: theme,
                cart: cart,
                logo: logo,
                title: title,
                tagline: tagline,
                phone: phone,
                email: email,
                catalogItems: catalogItems,
              ),
            );
          },
        ),
      );
    }

    final content = _buildContent(
      primary: primary,
      secondary: secondary,
      tertiary: tertiary,
      theme: theme,
      cart: cart,
      logo: logo,
      title: title,
      tagline: tagline,
      phone: phone,
      email: email,
      isCatalogType: isCatalogType,
      catalogItems: catalogItems,
    );

    if (theme.navStyle == 'sidebar' && !widget.mobileLayout) {
      return ColoredBox(
        color: theme.background,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SiteNavBar(
              theme: theme,
              title: title,
              subtitle: tagline,
              compact: widget.compact,
              mobileLayout: widget.mobileLayout,
              logo: logo,
            ),
            Expanded(child: content),
          ],
        ),
      );
    }

    return ColoredBox(color: theme.background, child: content);
  }

  Widget _buildCatalogMainScreen({
    required Map<String, dynamic> primary,
    required Map<String, dynamic> secondary,
    required Map<String, dynamic> tertiary,
    required LayoutTheme theme,
    required CartScope? cart,
    required String? logo,
    required String title,
    required String tagline,
    required String phone,
    required String email,
    required List<Map<String, dynamic>> catalogItems,
  }) {
    final content = _catalogSearchOpen
        ? _buildCatalogSearchContent(
            primary: primary,
            theme: theme,
            cart: cart,
            catalogItems: catalogItems,
          )
        : _buildContent(
            primary: primary,
            secondary: secondary,
            tertiary: tertiary,
            theme: theme,
            cart: cart,
            logo: logo,
            title: title,
            tagline: tagline,
            phone: phone,
            email: email,
            isCatalogType: true,
            catalogItems: catalogItems,
          );

    if (theme.navStyle == 'sidebar' && !widget.mobileLayout) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_catalogSearchOpen)
            SiteNavBar(
              theme: theme,
              title: title,
              subtitle: tagline,
              compact: widget.compact,
              mobileLayout: widget.mobileLayout,
              logo: logo,
              onSearchTap: _openCatalogSearch,
            ),
          Expanded(child: content),
        ],
      );
    }

    return content;
  }

  Widget _buildCatalogProductDetailScreen({
    required BuildContext navContext,
    required Map<String, dynamic> item,
    required LayoutTheme theme,
    required CartScope? cart,
    required List<Map<String, dynamic>> catalogItems,
  }) {
    final detail = CatalogProductDetailView(
      item: item,
      theme: theme,
      compact: compact,
      showAddToCart: widget.showAddToCart,
      isRestaurant: _isRestaurantCatalog,
      allProducts: catalogItems,
      onProductTap: (next) {
        _catalogNavigatorKey.currentState?.pushReplacementNamed(
          _productDetailRoute,
          arguments: next,
        );
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (theme.navStyle != 'sidebar' || widget.mobileLayout)
          SiteNavBar(
            theme: theme,
            title: _catalogProductNavTitle(),
            compact: widget.compact,
            mobileLayout: widget.mobileLayout,
            onBackTap: () => Navigator.pop(navContext),
          ),
        Expanded(child: detail),
      ],
    );
  }

  Widget _buildCatalogSearchContent({
    required Map<String, dynamic> primary,
    required LayoutTheme theme,
    required CartScope? cart,
    required List<Map<String, dynamic>> catalogItems,
  }) {
    final filtered = _filterCatalogItemsByQuery(catalogItems);
    final sections = <Widget>[
      if (theme.navStyle != 'sidebar' || widget.mobileLayout)
        SiteNavBar(
          theme: theme,
          title: _catalogSearchNavTitle(),
          compact: widget.compact,
          mobileLayout: widget.mobileLayout,
          onBackTap: _closeCatalogSearch,
        ),
      Padding(
        padding: theme.pad(compact),
        child: TextField(
          autofocus: true,
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: 'Search by name…',
            prefixIcon: CatalogSearchIcon.fieldPrefix(theme, compact: widget.compact),
            filled: true,
            fillColor: theme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(theme.radius),
              borderSide: BorderSide(color: theme.text.withValues(alpha: 0.12)),
            ),
          ),
          style: theme.body(compact, size: 14),
        ),
      ),
      _catalogProductsBlock(
        title: widget.tertiaryTitle,
        items: filtered,
        theme: theme,
        cart: cart,
        onProductTap: _openProductDetail,
      ),
      CatalogStoreFooter(primary: primary, theme: theme, compact: widget.compact),
      if (theme.navStyle == 'bottom')
        SiteNavBar(
          theme: theme,
          title: _catalogSearchNavTitle(),
          compact: widget.compact,
          mobileLayout: widget.mobileLayout,
          onBackTap: _closeCatalogSearch,
        ),
    ];

    return ListView(padding: EdgeInsets.zero, children: sections);
  }

  Widget _buildContent({
    required Map<String, dynamic> primary,
    required Map<String, dynamic> secondary,
    required Map<String, dynamic> tertiary,
    required LayoutTheme theme,
    required CartScope? cart,
    required String? logo,
    required String title,
    required String tagline,
    required String phone,
    required String email,
    required bool isCatalogType,
    required List<Map<String, dynamic>> catalogItems,
  }) {
    final usesStoreFooter = isCatalogType ||
        widget.document.type == CategoryType.businessProfile;
    final sections = <Widget>[
      if (theme.navStyle != 'sidebar' || widget.mobileLayout)
        SiteNavBar(
          theme: theme,
          title: title,
          subtitle: isCatalogType ? tagline : null,
          compact: widget.compact,
          mobileLayout: widget.mobileLayout,
          logo: logo,
          onSearchTap: isCatalogType ? _openCatalogSearch : null,
        ),
      if (isCatalogType) _catalogBanners(primary, theme),
      if (!isCatalogType)
        SiteHero(
          theme: theme,
          title: title,
          subtitle: tagline,
          compact: widget.compact,
          mobileLayout: widget.mobileLayout,
          logo: logo,
          description: widget.document.description,
        ),
      if (primary['mapEmbed'] != null && (primary['mapEmbed'] as String).isNotEmpty) _mapBlock(primary, theme),
      if (isCatalogType)
        _catalogSection(
          primary: primary,
          secondary: secondary,
          tertiary: tertiary,
          theme: theme,
          cart: cart,
        )
      else ...[
        _block(widget.secondaryTitle, _secondary(secondary, theme, theme.secondaryLayout), theme),
        if (widget.document.type == CategoryType.businessProfile && _list(secondary, keys: ['team']).isNotEmpty)
          _block('Team', _team(secondary, theme), theme),
        if (widget.document.type == CategoryType.businessProfile && _achievements(secondary).isNotEmpty)
          _block('Achievements', _achievementRow(secondary, theme), theme),
        _block(widget.tertiaryTitle, _tertiary(tertiary, theme, theme.tertiaryLayout, cart), theme),
      ],
      if (usesStoreFooter)
        CatalogStoreFooter(primary: primary, theme: theme, compact: widget.compact)
      else
        SiteFooter(theme: theme, compact: widget.compact, phone: phone, email: email, title: title),
      if (theme.navStyle == 'bottom')
        SiteNavBar(
          theme: theme,
          title: title,
          subtitle: isCatalogType ? tagline : null,
          compact: widget.compact,
          mobileLayout: widget.mobileLayout,
          logo: logo,
          onSearchTap: isCatalogType ? _openCatalogSearch : null,
        ),
    ];

    if (theme.layout == 'magazine') {
      sections.insert(sections.length - 2, sections.removeAt(sections.length - 3));
    }

    return ListView(padding: EdgeInsets.zero, children: sections);
  }

  Widget _catalogBanners(Map<String, dynamic> primary, LayoutTheme theme) {
    final banners = (primary['banners'] as List?)?.whereType<Map<String, dynamic>>().toList() ?? const [];
    return CatalogAutoBannerCarousel(
      banners: banners,
      theme: theme,
      compact: compact,
    );
  }

  Widget _catalogSection({
    required Map<String, dynamic> primary,
    required Map<String, dynamic> secondary,
    required Map<String, dynamic> tertiary,
    required LayoutTheme theme,
    required CartScope? cart,
  }) {
    final categories = _list(secondary, keys: const ['categories']);
    final allItems = _list(tertiary, keys: const ['products', 'menuItems']);
    final onProductTap = _openProductDetail;
    final reels = resolveCatalogReels(
      rawReels: primary['reels'] as List?,
      products: allItems,
    );
    final reelsStrip = CatalogProductReelsCarousel(
      reels: reels,
      theme: theme,
      compact: compact,
      onReelTap: onProductTap,
    );

    if (categories.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          reelsStrip,
          _block(widget.secondaryTitle, _secondary(secondary, theme, theme.secondaryLayout), theme),
          _catalogProductsBlock(
            title: widget.tertiaryTitle,
            items: allItems,
            theme: theme,
            cart: cart,
            onProductTap: onProductTap,
          ),
        ],
      );
    }

    final selectedIndex = _selectedCategoryIndex.clamp(0, categories.length - 1);
    final selectedName = _label(categories[selectedIndex]);
    final filtered = allItems
        .where((item) => (item['category'] as String? ?? '').trim() == selectedName)
        .toList();

    final categoryTitle = widget.document.type == CategoryType.restaurantMenu
        ? 'Categories'
        : widget.secondaryTitle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        reelsStrip,
        Padding(
          padding: theme.pad(compact),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                categoryTitle.toUpperCase(),
                style: theme.body(compact, size: 10).copyWith(letterSpacing: 2),
              ),
              SizedBox(height: compact ? 10 : 12),
              SizedBox(
                height: compact ? 96 : 108,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => SizedBox(width: compact ? 12 : 16),
                  itemBuilder: (context, index) {
                    final selected = index == selectedIndex;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategoryIndex = index),
                      child: _categoryRoundTile(
                        categories[index],
                        theme: theme,
                        selected: selected,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        _catalogProductsBlock(
          title: widget.tertiaryTitle,
          items: filtered,
          theme: theme,
          cart: cart,
          onProductTap: onProductTap,
        ),
      ],
    );
  }

  Widget _categoryRoundTile(
    Map<String, dynamic> category, {
    required LayoutTheme theme,
    required bool selected,
  }) {
    final name = _label(category);
    final imagePath = category['image'] as String?;
    final diameter = compact ? 56.0 : 64.0;

    Widget avatarChild;
    if (imagePath != null && imagePath.isNotEmpty) {
      avatarChild = ClipOval(
        child: SiteImage(path: imagePath, width: diameter, height: diameter),
      );
    } else {
      avatarChild = Icon(
        _categoryIcon(category['icon'] as String?),
        color: selected ? theme.primary : theme.primary.withValues(alpha: 0.7),
        size: compact ? 26 : 30,
      );
    }

    return SizedBox(
      width: compact ? 72 : 80,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? theme.primary : const Color(0xFFE2E8F0),
                width: selected ? 2.5 : 1,
              ),
            ),
            child: CircleAvatar(
              radius: diameter / 2,
              backgroundColor: theme.primary.withValues(alpha: selected ? 0.14 : 0.08),
              child: avatarChild,
            ),
          ),
          SizedBox(height: compact ? 6 : 8),
          Text(
            name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.body(compact, size: 11).copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? theme.primary : const Color(0xFF64748B),
                ),
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String? key) {
    switch (key) {
      case 'starters':
        return Icons.restaurant_rounded;
      case 'mains':
        return Icons.dinner_dining_rounded;
      case 'desserts':
        return Icons.cake_rounded;
      case 'drinks':
        return Icons.local_bar_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Widget _mapBlock(Map<String, dynamic> primary, LayoutTheme theme) {
    return Padding(
      padding: theme.pad(compact),
      child: Container(
        height: compact ? 120 : 160,
        alignment: Alignment.center,
        decoration: theme.cardDecoration(),
        child: Text('Map', style: theme.body(compact, size: 11)),
      ),
    );
  }

  Widget _team(Map<String, dynamic> data, LayoutTheme theme) {
    final team = _list(data, keys: ['team']);
    return Wrap(
      spacing: compact ? 10 : 12,
      runSpacing: compact ? 10 : 12,
      children: [
        for (final member in team)
          SizedBox(
            width: compact ? 120 : 140,
            child: Column(
              children: [
                SiteImage(path: member['image'] as String?, width: compact ? 64 : 72, height: compact ? 64 : 72),
                SizedBox(height: compact ? 6 : 8),
                Text(_label(member), style: theme.heading(compact, size: 13), textAlign: TextAlign.center),
                Text(_subtitle(member), style: theme.body(compact, size: 10), textAlign: TextAlign.center),
              ],
            ),
          ),
      ],
    );
  }

  List<Map<String, dynamic>> _achievements(Map<String, dynamic> data) {
    final raw = data['achievements'];
    if (raw is List) return raw.whereType<Map<String, dynamic>>().toList();
    return const [];
  }

  Widget _achievementRow(Map<String, dynamic> data, LayoutTheme theme) {
    final items = _achievements(data);
    return Row(
      children: [
        for (final item in items)
          Expanded(
            child: Container(
              margin: EdgeInsets.only(right: compact ? 8 : 10),
              padding: EdgeInsets.all(compact ? 12 : 14),
              decoration: theme.cardDecoration(),
              child: Column(
                children: [
                  Text(item['title']?.toString() ?? '', style: theme.heading(compact, size: 14), textAlign: TextAlign.center),
                  Text(item['value']?.toString() ?? '', style: theme.body(compact, size: 11), textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _secondary(Map<String, dynamic> data, LayoutTheme theme, String mode) {
    final items = _list(data);
    if (items.isEmpty) return Text(data['about'] as String? ?? widget.document.description, style: theme.body(compact));

    return switch (mode) {
      'chips' || 'tags' || 'wrap' => Wrap(
          spacing: compact ? 8 : 10,
          runSpacing: compact ? 8 : 10,
          children: [for (final item in items) _chip(item, theme)],
        ),
      'grid2' => _grid(items, theme, 2, 2.5),
      'timeline' => Column(
          children: [
            for (final item in items)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 8, height: 8, margin: EdgeInsets.only(top: compact ? 6 : 8, right: 10), decoration: BoxDecoration(color: theme.primary, shape: BoxShape.circle)),
                  Expanded(child: Padding(padding: EdgeInsets.only(bottom: compact ? 10 : 12), child: Text(_label(item), style: theme.body(compact)))),
                ],
              ),
          ],
        ),
      'quote' => Column(
          children: [
            for (final item in items)
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: compact ? 8 : 10),
                padding: EdgeInsets.all(compact ? 14 : 16),
                decoration: BoxDecoration(border: Border(left: BorderSide(color: theme.primary, width: 3)), color: theme.primary.withValues(alpha: 0.06)),
                child: Text(_label(item), style: theme.body(compact).copyWith(fontStyle: FontStyle.italic)),
              ),
          ],
        ),
      _ => Column(
          children: [
            for (final item in items)
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: compact ? 8 : 10),
                padding: EdgeInsets.all(compact ? 12 : 14),
                decoration: theme.cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_label(item), style: theme.heading(compact, size: 14)),
                    if (_subtitle(item).isNotEmpty) Text(_subtitle(item), style: theme.body(compact, size: 11)),
                  ],
                ),
              ),
          ],
        ),
    };
  }

  Widget _tertiary(Map<String, dynamic> data, LayoutTheme theme, String mode, CartScope? cart) {
    return _tertiaryItems(_list(data), theme, mode, cart);
  }

  bool get _isCatalogDocument =>
      widget.document.type == CategoryType.ecommerce ||
      widget.document.type == CategoryType.restaurantMenu;

  Widget _tertiaryItems(
    List<Map<String, dynamic>> items,
    LayoutTheme theme,
    String mode,
    CartScope? cart, {
    ValueChanged<Map<String, dynamic>>? onProductTap,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    if (_isCatalogDocument) {
      return CatalogProductGrid(
        items: items,
        theme: theme,
        compact: compact,
        showAddToCart: widget.showAddToCart,
        cart: cart,
        onProductTap: onProductTap,
      );
    }

    if (mode == 'list' || mode == 'rows' || mode == 'price' || mode == 'catalog') {
      return Column(
        children: [
          for (final item in items)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: _itemImage(item, theme, compact ? 40 : 48),
              title: Text(_label(item), style: theme.heading(compact, size: 15)),
              subtitle: Text(_subtitle(item), style: theme.body(compact, size: 11)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_price(item), style: theme.body(compact).copyWith(color: theme.primary)),
                  if (widget.showAddToCart && cart != null)
                    IconButton(icon: const Icon(Icons.add_shopping_cart_outlined, size: 20), onPressed: () => cart.addToCart(_label(item), _priceNum(item))),
                ],
              ),
            ),
        ],
      );
    }

    if (mode == 'gallery' || mode == 'mosaic') {
      return _grid(items, theme, mobileLayout ? 2 : 3, 1);
    }

    return _grid(items, theme, mobileLayout ? 1 : 2, mobileLayout ? 2.2 : 1.1, cart: cart);
  }

  Widget _grid(List<Map<String, dynamic>> items, LayoutTheme theme, int columns, double aspect, {CartScope? cart}) {
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
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: EdgeInsets.all(compact ? 8 : 10),
          decoration: theme.cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (aspect <= 1.5)
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(theme.radius * 0.5),
                    child: _itemImage(item, theme, 80),
                  ),
                ),
              SizedBox(height: compact ? 6 : 8),
              Text(
                _label(item),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.heading(compact, size: compact ? 12 : 13),
              ),
              if (_subtitle(item).isNotEmpty && _isCatalogDocument) ...[
                SizedBox(height: compact ? 2 : 4),
                Text(
                  _subtitle(item),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.body(compact, size: 10),
                ),
              ],
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _price(item),
                      style: theme.body(compact, size: 11).copyWith(
                        color: theme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (widget.showAddToCart && cart != null)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      onPressed: () => cart.addToCart(_label(item), _priceNum(item)),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _itemImage(Map<String, dynamic> item, LayoutTheme theme, double size) {
    final path = item['image'] as String?;
    if (path != null && path.isNotEmpty) return SiteImage(path: path, width: double.infinity, height: size);
    return Container(
      width: double.infinity,
      height: size,
      decoration: BoxDecoration(color: theme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(theme.radius * 0.6)),
      alignment: Alignment.center,
      child: Icon(Icons.image_outlined, color: theme.primary, size: compact ? 24 : 28),
    );
  }

  Widget _block(String title, Widget child, LayoutTheme theme) {
    return Padding(
      padding: theme.pad(compact),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: theme.body(compact, size: 10).copyWith(letterSpacing: 2)),
          SizedBox(height: compact ? 8 : 12),
          child,
        ],
      ),
    );
  }

  Widget _chip(Map<String, dynamic> item, LayoutTheme theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12, vertical: compact ? 8 : 10),
      decoration: theme.cardDecoration(),
      child: Text(_label(item), style: theme.body(compact, size: 12)),
    );
  }

  List<Map<String, dynamic>> _list(Map<String, dynamic> data, {List<String>? keys}) {
    for (final key in keys ?? ['services', 'categories', 'menuItems', 'products', 'messages', 'gallery', 'branches', 'offers', 'banners', 'team']) {
      final raw = data[key];
      if (raw is List) return raw.whereType<Map<String, dynamic>>().toList();
    }
    return const [];
  }

  String _label(Map<String, dynamic> item) =>
      item['title'] as String? ?? item['name'] as String? ?? item['text'] as String? ?? 'Item';

  String _subtitle(Map<String, dynamic> item) =>
      item['description'] as String? ?? item['category'] as String? ?? item['role'] as String? ?? '';

  String _price(Map<String, dynamic> item) => catalogFormatMoney(catalogSalePrice(item));

  num _priceNum(Map<String, dynamic> item) => catalogSalePrice(item);
}
