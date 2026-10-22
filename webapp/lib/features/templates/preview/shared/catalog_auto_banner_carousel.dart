import 'dart:async';

import 'package:flutter/material.dart';
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

    final height = widget.compact ? 148.0 : 188.0;
    final pad = widget.theme.pad(widget.compact);

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
    return Container(
      decoration: theme.cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: SiteImage(
        path: banner['image'] as String?,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}
