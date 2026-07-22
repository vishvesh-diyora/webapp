import 'package:flutter/material.dart';
import 'package:webapp/core/domain/category_type.dart';
import 'package:webapp/features/templates/preview/layout_theme.dart';
import 'package:webapp/features/templates/preview/layouts/site_layout_blocks.dart';
import 'package:webapp/features/templates/preview/shared/cart_preview_shell.dart';
import 'package:webapp/features/templates/preview/shared/site_image.dart';
import 'package:webapp/features/website/domain/entities/website_document.dart';

/// JSON-driven preview for business, restaurant, and ecommerce — 22 layouts via theme.
class VariantCategoryPreview extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final primary = document.blockByContentType(ContentType.primary)?.contentData ?? const {};
    final secondary = document.blockByContentType(ContentType.secondary)?.contentData ?? const {};
    final tertiary = document.blockByContentType(ContentType.tertiary)?.contentData ?? const {};
    final theme = LayoutTheme.fromContent(primary);
    final cart = CartScope.maybeOf(context);
    final logo = document.logo.isNotEmpty ? document.logo : primary['logo'] as String?;
    final title = primary[primaryTitleKey] as String? ?? document.name;
    final tagline = primary['tagline'] as String? ?? document.subname;
    final phone = primary['phone'] as String? ?? primary['whatsapp'] as String? ?? '';
    final email = primary['email'] as String? ?? '';

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
    );

    if (theme.navStyle == 'sidebar' && !mobileLayout) {
      return ColoredBox(
        color: theme.background,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SiteNavBar(theme: theme, title: title, compact: compact, mobileLayout: mobileLayout, logo: logo),
            Expanded(child: content),
          ],
        ),
      );
    }

    return ColoredBox(color: theme.background, child: content);
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
  }) {
    final sections = <Widget>[
      if (theme.navStyle != 'sidebar' || mobileLayout)
        SiteNavBar(theme: theme, title: title, compact: compact, mobileLayout: mobileLayout, logo: logo),
      if (document.type == CategoryType.restaurantMenu) _restaurantBanners(primary, theme),
      if (document.type == CategoryType.ecommerce) _ecommerceBanners(primary, theme),
      SiteHero(theme: theme, title: title, subtitle: tagline, compact: compact, mobileLayout: mobileLayout, logo: logo, description: document.description),
      if (primary['mapEmbed'] != null && (primary['mapEmbed'] as String).isNotEmpty) _mapBlock(primary, theme),
      _block(secondaryTitle, _secondary(secondary, theme, theme.secondaryLayout), theme),
      if (document.type == CategoryType.businessProfile && _list(secondary, keys: ['team']).isNotEmpty)
        _block('Team', _team(secondary, theme), theme),
      if (document.type == CategoryType.businessProfile && _achievements(secondary).isNotEmpty)
        _block('Achievements', _achievementRow(secondary, theme), theme),
      _block(tertiaryTitle, _tertiary(tertiary, theme, theme.tertiaryLayout, cart), theme),
      SiteFooter(theme: theme, compact: compact, phone: phone, email: email, title: title),
      if (theme.navStyle == 'bottom') SiteNavBar(theme: theme, title: title, compact: compact, mobileLayout: mobileLayout, logo: logo),
    ];

    if (theme.layout == 'magazine') {
      sections.insert(sections.length - 2, sections.removeAt(sections.length - 3));
    }

    return ListView(padding: EdgeInsets.zero, children: sections);
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

  Widget _restaurantBanners(Map<String, dynamic> primary, LayoutTheme theme) {
    final banners = (primary['banners'] as List?)?.whereType<Map<String, dynamic>>().toList() ?? const [];
    if (banners.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: compact ? 140 : 180,
      child: ListView.separated(
        padding: theme.pad(compact),
        scrollDirection: Axis.horizontal,
        itemCount: banners.length,
        separatorBuilder: (_, __) => SizedBox(width: compact ? 8 : 12),
        itemBuilder: (context, index) => _bannerCard(banners[index], theme),
      ),
    );
  }

  Widget _ecommerceBanners(Map<String, dynamic> primary, LayoutTheme theme) {
    final banners = (primary['banners'] as List?)?.whereType<Map<String, dynamic>>().toList() ?? const [];
    if (banners.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: theme.pad(compact),
      child: Column(
        children: [for (final banner in banners) Padding(padding: EdgeInsets.only(bottom: compact ? 8 : 10), child: _bannerCard(banner, theme, fullWidth: true))],
      ),
    );
  }

  Widget _bannerCard(Map<String, dynamic> banner, LayoutTheme theme, {bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : (compact ? 220 : 280),
      height: fullWidth ? (compact ? 100 : 120) : null,
      decoration: theme.cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          SiteImage(path: banner['image'] as String?, width: double.infinity, height: double.infinity),
          Container(
            color: Colors.black.withValues(alpha: 0.35),
            padding: EdgeInsets.all(compact ? 12 : 14),
            alignment: Alignment.bottomLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(banner['title']?.toString() ?? '', style: theme.heading(compact, size: 16).copyWith(color: Colors.white)),
                Text(banner['subtitle']?.toString() ?? '', style: theme.body(compact, size: 11).copyWith(color: Colors.white70)),
              ],
            ),
          ),
        ],
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
    if (items.isEmpty) return Text(data['about'] as String? ?? document.description, style: theme.body(compact));

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
    final items = _list(data);
    if (items.isEmpty) return const SizedBox.shrink();

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
                  if (showAddToCart && cart != null)
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
          padding: EdgeInsets.all(compact ? 10 : 12),
          decoration: theme.cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (aspect <= 1.5) Expanded(child: _itemImage(item, theme, 80)),
              Text(_label(item), maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.heading(compact, size: 14)),
              Row(
                children: [
                  Expanded(child: Text(_price(item), style: theme.body(compact, size: 11).copyWith(color: theme.primary))),
                  if (showAddToCart && cart != null)
                    IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.add, size: 18), onPressed: () => cart.addToCart(_label(item), _priceNum(item))),
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

  String _price(Map<String, dynamic> item) {
    final price = item['price'];
    if (price == null) return '';
    if (price is num) return '\$$price';
    return price.toString();
  }

  num _priceNum(Map<String, dynamic> item) {
    final price = item['price'];
    if (price is num) return price;
    return num.tryParse(price?.toString() ?? '') ?? 0;
  }
}
