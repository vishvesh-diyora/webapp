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
      gradient: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    ),
    _BannerData(
      title: '110 Templates',
      subtitle: '22 unique production layouts for every category',
      gradient: [Color(0xFF0EA5E9), Color(0xFF6366F1)],
    ),
    _BannerData(
      title: 'Edit & Republish',
      subtitle: 'Same JSON powers preview, editor, and generated websites',
      gradient: [Color(0xFF10B981), Color(0xFF0EA5E9)],
    ),
  ];

  static const _categories = [
    _CategoryData(
      type: CategoryType.portfolio,
      title: 'Portfolio',
      price: 'Free',
      gradient: [Color(0xFF6366F1), Color(0xFF818CF8)],
      icon: Icons.work_outline_rounded,
    ),
    _CategoryData(
      type: CategoryType.businessProfile,
      title: 'Business Profile',
      price: 'Free',
      gradient: [Color(0xFF0EA5E9), Color(0xFF38BDF8)],
      icon: Icons.business_center_outlined,
    ),
    _CategoryData(
      type: CategoryType.giftReveal,
      title: 'Gift Reveal',
      price: 'Free',
      gradient: [Color(0xFFEC4899), Color(0xFFF472B6)],
      icon: Icons.card_giftcard_outlined,
    ),
    _CategoryData(
      type: CategoryType.restaurantMenu,
      title: 'Restaurant Menu',
      price: 'Free',
      gradient: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
      icon: Icons.restaurant_menu,
    ),
    _CategoryData(
      type: CategoryType.ecommerce,
      title: 'Ecommerce Catalogue',
      price: 'Free',
      gradient: [Color(0xFF10B981), Color(0xFF34D399)],
      icon: Icons.shopping_bag_outlined,
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Text(
                'Choose a category',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.sizeOf(context).width >= 700 ? 3 : 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.92,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _CategoryGridTile(data: _categories[index]),
                childCount: _categories.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static double _mobileBannerHeight(double screenWidth) {
    final clamped = screenWidth.clamp(320.0, AppConstants.maxDashboardWidth);
    return (clamped * 0.42).clamp(150.0, 220.0);
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
  const _BannerCard({required this.data});
  final _BannerData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: data.gradient),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      alignment: Alignment.bottomLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(data.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 4),
          Text(data.subtitle, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }
}

class _WideBannerRow extends StatelessWidget {
  const _WideBannerRow({required this.banners, required this.maxWidth});
  final List<_BannerData> banners;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          for (var i = 0; i < banners.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(child: SizedBox(height: 140, child: _BannerCard(data: banners[i]))),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                const Spacer(),
                Text(data.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 4),
                Text(CategoryType.description(data.type), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, height: 1.3)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
