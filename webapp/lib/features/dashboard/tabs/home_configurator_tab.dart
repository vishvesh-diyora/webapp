import 'package:flutter/material.dart';
import 'package:webapp/core/constants/app_constants.dart';
import 'package:webapp/features/dashboard/data/category_templates_data.dart';
import 'package:webapp/features/dashboard/models/category_template.dart';
import 'package:webapp/features/dashboard/screens/category_detail_screen.dart';

/// Home tab with banner carousel and category cards.
class HomeConfiguratorTab extends StatelessWidget {
  const HomeConfiguratorTab({super.key});

  /// Below this width: swipeable single-banner carousel (mobile).
  /// At or above: all banners visible in one row (web/tablet).
  static const double _wideBannerBreakpoint = 600;

  static const _banners = [
    _BannerData(
      title: 'Summer Collection',
      subtitle: 'Fresh templates for your next launch',
      gradient: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    ),
    _BannerData(
      title: 'Pro Templates',
      subtitle: 'Premium layouts crafted by designers',
      gradient: [Color(0xFF0EA5E9), Color(0xFF6366F1)],
    ),
    _BannerData(
      title: 'Launch Faster',
      subtitle: 'Go from idea to live site in minutes',
      gradient: [Color(0xFF10B981), Color(0xFF0EA5E9)],
    ),
  ];

  static const _categories = [
    _CategoryData(
      type: CategoryType.ecommerce,
      title: 'E-commerce',
      price: '\$49',
      gradient: [Color(0xFFEC4899), Color(0xFFF472B6)],
      icon: Icons.shopping_bag_outlined,
    ),
    _CategoryData(
      type: CategoryType.portfolio,
      title: 'Portfolio',
      price: '\$29',
      gradient: [Color(0xFF6366F1), Color(0xFF818CF8)],
      icon: Icons.work_outline_rounded,
    ),
    _CategoryData(
      type: CategoryType.gift,
      title: 'Gift',
      price: '\$39',
      gradient: [Color(0xFF10B981), Color(0xFF34D399)],
      icon: Icons.card_giftcard_outlined,
    ),
    _CategoryData(
      type: CategoryType.custom,
      title: 'Custom',
      price: '\$59',
      gradient: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
      icon: Icons.dashboard_customize_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                'Configurator',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = MediaQuery.sizeOf(context).width;
                  final isWide = screenWidth >= _wideBannerBreakpoint;

                  if (isWide) {
                    return _WideBannerRow(
                      banners: _banners,
                      maxWidth: constraints.maxWidth,
                    );
                  }

                  return SizedBox(
                    height: _mobileBannerHeight(screenWidth),
                    child: PageView.builder(
                      controller: PageController(viewportFraction: 0.88),
                      itemCount: _banners.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: _BannerCard(data: _banners[index]),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Text(
                'What would you like to create?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = MediaQuery.sizeOf(context).width;
                final isWide = screenWidth >= _wideBannerBreakpoint;

                if (isWide) {
                  return _WideCategoryRow(
                    categories: _categories,
                    maxWidth: constraints.maxWidth,
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.92,
                    ),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      return _CategoryGridTile(data: _categories[index]);
                    },
                  ),
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  double _mobileBannerHeight(double screenWidth) {
    final bannerWidth = screenWidth * 0.88 - 12;
    return bannerWidth * (9 / 16);
  }
}

/// All banners side-by-side for web and wide screens.
class _WideBannerRow extends StatelessWidget {
  const _WideBannerRow({
    required this.banners,
    required this.maxWidth,
  });

  final List<_BannerData> banners;
  final double maxWidth;

  static const double _horizontalPadding = 40;
  static const double _gap = 12;

  @override
  Widget build(BuildContext context) {
    final contentWidth = maxWidth.clamp(0.0, AppConstants.maxDashboardWidth);
    final totalGaps = _gap * (banners.length - 1);
    final bannerWidth =
        (contentWidth - _horizontalPadding - totalGaps) / banners.length;
    final bannerHeight = bannerWidth * (9 / 16);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: bannerHeight,
        child: Row(
          children: [
            for (var i = 0; i < banners.length; i++) ...[
              if (i > 0) const SizedBox(width: _gap),
              Expanded(
                child: _BannerCard(
                  data: banners[i],
                  compact: true,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// All category cards in one row for web and wide screens.
class _WideCategoryRow extends StatelessWidget {
  const _WideCategoryRow({
    required this.categories,
    required this.maxWidth,
  });

  final List<_CategoryData> categories;
  final double maxWidth;

  static const double _horizontalPadding = 40;
  static const double _gap = 12;

  @override
  Widget build(BuildContext context) {
    final contentWidth = maxWidth.clamp(0.0, AppConstants.maxDashboardWidth);
    final totalGaps = _gap * (categories.length - 1);
    final cardWidth =
        (contentWidth - _horizontalPadding - totalGaps) / categories.length;
    final cardHeight = cardWidth / 1.05;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: cardHeight,
        child: Row(
          children: [
            for (var i = 0; i < categories.length; i++) ...[
              if (i > 0) const SizedBox(width: _gap),
              Expanded(
                child: _CategoryGridTile(data: categories[i]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BannerData {
  const _BannerData({
    required this.title,
    required this.subtitle,
    required this.gradient,
  });

  final String title;
  final String subtitle;
  final List<Color> gradient;
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.data, this.compact = false});

  final _BannerData data;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: data.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: data.gradient.first.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                Icons.image_outlined,
                size: compact ? 72 : 120,
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(compact ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    data.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: compact ? 16 : 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data.subtitle,
                    maxLines: compact ? 2 : 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: compact ? 12 : 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryData {
  const _CategoryData({
    required this.type,
    required this.title,
    required this.price,
    required this.gradient,
    required this.icon,
  });

  final int type;
  final String title;
  final String price;
  final List<Color> gradient;
  final IconData icon;

  CategoryTemplate? get template => CategoryTemplatesData.byType(type);
}

class _CategoryGridTile extends StatelessWidget {
  const _CategoryGridTile({required this.data});

  final _CategoryData data;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          final template = data.template;
          if (template == null) return;
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CategoryDetailScreen(template: template),
            ),
          );
        },
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: data.gradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(data.icon, color: Colors.white, size: 24),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF94A3B8),
                      size: 22,
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: data.gradient.first.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    data.price,
                    style: TextStyle(
                      color: data.gradient.first,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
