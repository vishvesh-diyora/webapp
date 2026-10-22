import 'package:flutter/material.dart';
import 'package:webapp/features/templates/preview/layout_theme.dart';
import 'package:webapp/features/templates/preview/shared/catalog_product_utils.dart';
import 'package:webapp/features/templates/preview/shared/catalog_reel_video_player.dart';

/// Horizontal reel strip above catalog categories (fixed 9:16 cells, muted autoplay).
class CatalogProductReelsCarousel extends StatelessWidget {
  const CatalogProductReelsCarousel({
    super.key,
    required this.reels,
    required this.theme,
    required this.compact,
    required this.onReelTap,
  });

  final List<Map<String, dynamic>> reels;
  final LayoutTheme theme;
  final bool compact;
  final ValueChanged<Map<String, dynamic>> onReelTap;

  static const double _aspectWidth = 9;
  static const double _aspectHeight = 16;

  @override
  Widget build(BuildContext context) {
    if (reels.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final visible = catalogReelsVisibleCount(maxWidth);
        final horizontalPad = compact ? 16.0 : 20.0;
        final gap = compact ? 8.0 : 10.0;
        final cellWidth =
            (maxWidth - horizontalPad * 2 - gap * (visible - 1)) / visible;
        final cellHeight = cellWidth * _aspectHeight / _aspectWidth;

        return Padding(
          padding: EdgeInsets.only(top: compact ? 4 : 8, bottom: compact ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPad),
                child: Text(
                  'SHOP REELS',
                  style: theme.body(compact, size: 10).copyWith(letterSpacing: 2),
                ),
              ),
              SizedBox(height: compact ? 10 : 12),
              SizedBox(
                height: cellHeight,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPad),
                  scrollDirection: Axis.horizontal,
                  itemCount: reels.length,
                  separatorBuilder: (_, _) => SizedBox(width: gap),
                  itemBuilder: (context, index) {
                    final reel = reels[index];
                    final product = reel['product'] as Map<String, dynamic>;
                    final videoUrl = catalogProductVideoUrl(product) ??
                        catalogReelVideoUrl(reel, fallbackIndex: index);
                    return SizedBox(
                      width: cellWidth,
                      child: _ReelCard(
                        videoUrl: videoUrl,
                        theme: theme,
                        onTap: () => onReelTap(product),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReelCard extends StatelessWidget {
  const _ReelCard({
    required this.videoUrl,
    required this.theme,
    required this.onTap,
  });

  final String videoUrl;
  final LayoutTheme theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: CatalogProductReelsCarousel._aspectWidth /
          CatalogProductReelsCarousel._aspectHeight,
      child: Material(
        color: const Color(0xFF0F172A),
        elevation: 0,
        shadowColor: theme.secondary.withValues(alpha: 0.14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CatalogReelVideoPlayer(
              url: videoUrl,
              placeholder: _loadingIndicator(),
              error: _errorIcon(),
            ),
            // HtmlElementView (web) steals hits unless a layer is above it.
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTap,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loadingIndicator() {
    return Center(
      child: SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: Colors.white.withValues(alpha: 0.85),
        ),
      ),
    );
  }

  Widget _errorIcon() {
    return Center(
      child: Icon(
        Icons.videocam_off_outlined,
        color: Colors.white.withValues(alpha: 0.5),
        size: 32,
      ),
    );
  }
}
