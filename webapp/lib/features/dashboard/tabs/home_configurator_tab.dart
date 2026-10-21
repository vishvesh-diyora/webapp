import 'package:flutter/material.dart';
import 'package:webapp/core/constants/app_constants.dart';
import 'package:webapp/core/domain/category_type.dart';
import 'package:webapp/features/dashboard/data/category_templates_data.dart';
import 'package:webapp/features/website/domain/entities/website_document.dart';
import 'package:webapp/features/dashboard/screens/category_detail_screen.dart';

class HomeConfiguratorTab extends StatelessWidget {
  const HomeConfiguratorTab({super.key});

  static const double _wideBannerBreakpoint = 600;

  static const _banners = [
    _BannerData(
      title: 'Build in Minutes',
      subtitle: 'Choose a category, pick a template, publish static sites',
      gradient: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFF6366F1)],
      icon: Icons.rocket_launch_rounded,
    ),
    _BannerData(
      title: '5 Templates',
      subtitle: 'One polished starter layout for every category',
      gradient: [Color(0xFF0284C7), Color(0xFF2563EB), Color(0xFF6366F1)],
      icon: Icons.auto_awesome_mosaic_rounded,
    ),
    _BannerData(
      title: 'Edit & Republish',
      subtitle: 'Same JSON powers preview, editor, and generated websites',
      gradient: [Color(0xFF059669), Color(0xFF0D9488), Color(0xFF0EA5E9)],
      icon: Icons.sync_rounded,
    ),
  ];

  static const _categories = [
    _CategoryData(
      type: CategoryType.ecommerce,
      title: 'Ecommerce Catalogue',
      price: 'Free',
      gradient: [Color(0xFF10B981), Color(0xFF34D399)],
      icon: Icons.shopping_bag_outlined,
    ),
    _CategoryData(
      type: CategoryType.restaurantMenu,
      title: 'Restaurant Menu',
      price: 'Free',
      gradient: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
      icon: Icons.restaurant_menu,
    ),
    _CategoryData(
      type: CategoryType.businessProfile,
      title: 'Business Profile',
      price: 'Free',
      gradient: [Color(0xFF0EA5E9), Color(0xFF38BDF8)],
      icon: Icons.business_center_outlined,
    ),
    _CategoryData(
      type: CategoryType.portfolio,
      title: 'Portfolio',
      price: 'Free',
      gradient: [Color(0xFF6366F1), Color(0xFF818CF8)],
      icon: Icons.work_outline_rounded,
    ),
    _CategoryData(
      type: CategoryType.giftReveal,
      title: 'Gift Reveal',
      price: 'Free',
      gradient: [Color(0xFFEC4899), Color(0xFFF472B6)],
      icon: Icons.card_giftcard_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppConstants.dashboardHorizontalGutter,
                20,
                AppConstants.dashboardHorizontalGutter,
                8,
              ),
              child: Text(
                'Create Website',
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
              padding: EdgeInsets.fromLTRB(
                AppConstants.dashboardHorizontalGutter,
                16,
                AppConstants.dashboardHorizontalGutter,
                12,
              ),
              child: Text(
                'Choose a category',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
              ),
            ),
          ),
          _categoryListSliver(context),
        ],
      ),
    );
  }

  static double _mobileBannerHeight(double screenWidth) {
    final clamped = screenWidth.clamp(320.0, AppConstants.maxDashboardWidth);
    return (clamped * 0.42).clamp(150.0, 220.0);
  }

  static Widget _categoryListSliver(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final twoPerRow = size.width > size.height;
    final children = <Widget>[];

    if (twoPerRow) {
      for (var i = 0; i < _categories.length; i += 2) {
        children.add(
          Padding(
            padding: EdgeInsets.only(bottom: i + 2 < _categories.length ? 12 : 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _CategoryListTile(data: _categories[i])),
                if (i + 1 < _categories.length) ...[
                  const SizedBox(width: 12),
                  Expanded(child: _CategoryListTile(data: _categories[i + 1])),
                ],
              ],
            ),
          ),
        );
      }
    } else {
      for (var i = 0; i < _categories.length; i++) {
        children.add(
          Padding(
            padding: EdgeInsets.only(bottom: i < _categories.length - 1 ? 12 : 0),
            child: _CategoryListTile(data: _categories[i]),
          ),
        );
      }
    }

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        AppConstants.dashboardHorizontalGutter,
        0,
        AppConstants.dashboardHorizontalGutter,
        24,
      ),
      sliver: SliverList(delegate: SliverChildListDelegate(children)),
    );
  }
}

class _BannerData {
  const _BannerData({
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final List<Color> gradient;
  final IconData icon;
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.data, this.compact = false});
  final _BannerData data;
  final bool compact;

  Color get _shadowColor => data.gradient.last;

  static double _resolveBannerHeight(BoxConstraints constraints, bool compact) {
    if (constraints.hasBoundedHeight && constraints.maxHeight > 0) {
      return constraints.maxHeight;
    }
    return compact ? 124 : 140;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = _resolveBannerHeight(constraints, compact);

        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _shadowColor.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: height,
              width: double.infinity,
              child: Stack(
                clipBehavior: Clip.antiAlias,
                children: [
                  Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: data.gradient,
                    stops: data.gradient.length == 3 ? const [0.0, 0.55, 1.0] : null,
                  ),
                ),
              ),
            ),
            const Positioned(
              right: -36,
              top: -40,
              child: _BannerGlowOrb(size: 130, opacity: 0.22),
            ),
            Positioned(
              left: -24,
              bottom: -32,
              child: _BannerGlowOrb(
                size: 100,
                opacity: 0.18,
                color: data.gradient.first,
              ),
            ),
            Positioned(
              right: 12,
              top: 12,
              child: SizedBox(
                width: 72,
                height: 72,
                child: CustomPaint(painter: _BannerDotGridPainter()),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.14),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.12),
                    ],
                    stops: const [0.0, 0.42, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 14,
              right: 14,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(data.icon, color: Colors.white, size: 22),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  compact ? 14 : 20,
                  12,
                  compact ? 44 : 52,
                  compact ? 14 : 18,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      maxLines: compact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: compact ? 15 : 18,
                        height: 1.15,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: compact ? 4 : 6),
                    Text(
                      data.subtitle,
                      maxLines: compact ? 2 : 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: compact ? 11 : 12,
                        height: 1.25,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
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
    );
  }
}

class _BannerGlowOrb extends StatelessWidget {
  const _BannerGlowOrb({
    required this.size,
    required this.opacity,
    this.color = Colors.white,
  });

  final double size;
  final double opacity;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

class _BannerDotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.12);
    const step = 7.0;
    for (var x = 0.0; x < size.width; x += step) {
      for (var y = 0.0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1.1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WideBannerRow extends StatelessWidget {
  const _WideBannerRow({required this.banners, required this.maxWidth});
  final List<_BannerData> banners;
  final double maxWidth;

  bool _isCompactCard(double width) {
    final gaps = (banners.length - 1) * 12;
    const horizontalPadding = 40.0;
    final cardWidth = (width - horizontalPadding - gaps) / banners.length;
    return cardWidth < 280;
  }

  @override
  Widget build(BuildContext context) {
    final compact = _isCompactCard(maxWidth);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.dashboardHorizontalGutter),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < banners.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(
              child: _BannerCard(data: banners[i], compact: compact),
            ),
          ],
        ],
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

  WebsiteDocument get template => CategoryTemplatesData.defaultForCategory(type);
}

class _CategoryListTile extends StatelessWidget {
  const _CategoryListTile({required this.data});
  final _CategoryData data;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CategoryDetailScreen(
                categoryType: data.type,
                initialDocument: data.template,
              ),
            ),
          );
        },
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: data.gradient),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(data.icon, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(
                        CategoryType.description(data.type),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, height: 1.3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  data.price,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Color(0xFF10B981),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
