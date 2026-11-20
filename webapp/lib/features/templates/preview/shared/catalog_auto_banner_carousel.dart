import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_avatar.dart';
import 'package:webapp/features/templates/preview/layout_theme.dart';
import 'package:webapp/features/templates/preview/shared/site_image.dart';

/// Horizontally paging banners with auto-advance (ecommerce / restaurant previews).
class CatalogAutoBannerCarousel extends StatefulWidget {
  const CatalogAutoBannerCarousel({
    super.key,
    required this.banners,
    required this.theme,
    required this.compact,
  });

  final List<Map<String, dynamic>> banners;
  final LayoutTheme theme;
  final bool compact;

  @override
  State<CatalogAutoBannerCarousel> createState() => _CatalogAutoBannerCarouselState();
}

class _CatalogAutoBannerCarouselState extends State<CatalogAutoBannerCarousel> {
  late final PageController _pageController;
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoScroll();
  }

  @override
  void didUpdateWidget(covariant CatalogAutoBannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.banners.length != widget.banners.length) {
      _page = 0;
      _pageController.jumpToPage(0);
    }
  }

  void _startAutoScroll() {
    _timer?.cancel();
    if (widget.banners.length <= 1) return;
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || widget.banners.isEmpty) return;
      final next = (_page + 1) % widget.banners.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banners = widget.banners.take(3).toList();
    if (banners.isEmpty) return const SizedBox.shrink();

    final variant = widget.theme.variant;
    final height = switch (variant) {
      2 => widget.compact ? 176.0 : 228.0,
      3 => widget.compact ? 168.0 : 214.0,
      4 => widget.compact ? 190.0 : 248.0,
      5 => widget.compact ? 160.0 : 208.0,
      6 => widget.compact ? 164.0 : 210.0,
      7 => widget.compact ? 210.0 : 268.0,
      8 => widget.compact ? 188.0 : 236.0,
      9 => widget.compact ? 156.0 : 196.0,
      10 => widget.compact ? 176.0 : 224.0,
      11 => widget.compact ? 200.0 : 252.0,
      _ => widget.compact ? 148.0 : 188.0,
    };
    final pad = switch (variant) {
      2 || 4 || 7 || 11 => EdgeInsets.zero,
      5 => EdgeInsets.all(widget.compact ? 18 : 24),
      8 => EdgeInsets.symmetric(horizontal: widget.compact ? 16 : 28, vertical: widget.compact ? 12 : 16),
      9 => EdgeInsets.symmetric(horizontal: widget.compact ? 20 : 40, vertical: widget.compact ? 12 : 18),
      10 => EdgeInsets.all(widget.compact ? 12 : 16),
      _ => widget.theme.pad(widget.compact),
    };

    return Padding(
      padding: pad,
      child: Column(
        children: [
          SizedBox(
            height: height,
            child: PageView.builder(
              controller: _pageController,
              itemCount: banners.length,
              onPageChanged: (index) => setState(() => _page = index),
              itemBuilder: (context, index) => _BannerSlide(
                banner: banners[index],
                theme: widget.theme,
              ),
            ),
          ),
          if (banners.length > 1) ...[
            SizedBox(height: widget.compact ? 8 : 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < banners.length; i++)
                  Container(
                    width: i == _page ? 18 : 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: i == _page
                          ? widget.theme.primary
                          : widget.theme.primary.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _BannerSlide extends StatelessWidget {
  const _BannerSlide({
    required this.banner,
    required this.theme,
  });

  final Map<String, dynamic> banner;
  final LayoutTheme theme;

  @override
  Widget build(BuildContext context) {
    final photo = SiteImage(
      path: banner['image'] as String?,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      shape: ProfileImageShape.square,
    );
    if (theme.variant == 2 || theme.variant == 4) {
      return photo;
    }
    if (theme.variant != 10 && theme.variant != 11 && theme.variant != 7) {
      return Container(
        decoration: theme.cardDecoration(),
        clipBehavior: Clip.antiAlias,
        child: photo,
      );
    }
    return Container(
      decoration: theme.cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          photo,
          if (theme.variant != 7)
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xCC020617)],
                ),
              ),
            ),
          if (theme.variant == 7)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(height: 8, color: theme.accent),
            ),
        ],
      ),
    );
  }
}
