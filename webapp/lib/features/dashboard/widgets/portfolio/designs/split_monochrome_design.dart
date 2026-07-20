import 'package:flutter/material.dart';
import 'package:webapp/features/dashboard/models/category_template.dart';
import 'package:webapp/features/dashboard/models/portfolio_content.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_avatar.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_helpers.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_motion.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_social_bar.dart';

/// 11 — Split monochrome: square B&W photo + "My Portfolio" editorial hero.
class SplitMonochromeDesign extends StatelessWidget {
  const SplitMonochromeDesign({
    super.key,
    required this.template,
    required this.compact,
    required this.mobileProfileLayout,
  });

  final CategoryTemplate template;
  final bool compact;
  final bool mobileProfileLayout;

  static const _panel = Color(0xFF3D3D3D);
  static const _dark = Color(0xFF2A2A2A);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _dark,
      child: buildAnimatedPortfolio(
        template: template,
        compact: compact,
        motion: PortfolioMotion.slideLeft,
        profile: _hero,
        testimonials: _reviews,
        projects: _work,
      ),
    );
  }

  Widget _hero(bool c) {
    final p = PortfolioDesignHelpers.profile;

    if (mobileProfileLayout) {
      final bannerH = c ? 220.0 : 280.0;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: bannerH,
            width: double.infinity,
            child: PortfolioProfileImage(
              profile: p,
              shape: ProfileImageShape.banner,
              bannerHeight: bannerH,
              grayscale: true,
              alignment: Alignment.topCenter,
            ),
          ),
          _contentPanel(p, c, centered: true),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 45,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final side = constraints.maxWidth;
              if (!side.isFinite || side <= 0) {
                return const SizedBox.shrink();
              }
              return PortfolioProfileImage(
                profile: p,
                shape: ProfileImageShape.square,
                size: side,
                grayscale: true,
                alignment: Alignment.topCenter,
              );
            },
          ),
        ),
        Expanded(
          flex: 55,
          child: _contentPanel(p, c),
        ),
      ],
    );
  }

  Widget _contentPanel(PortfolioProfile p, bool c, {bool centered = false}) {
    final align = centered ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    final textAlign = centered ? TextAlign.center : TextAlign.start;

    return Container(
      width: double.infinity,
      color: _panel,
      padding: EdgeInsets.symmetric(
        horizontal: c ? 16 : 24,
        vertical: c ? 14 : 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: align,
        children: [
          _titleBlock(c, centered: centered),
          SizedBox(height: c ? 8 : 12),
          Text(
            p.bio,
            textAlign: textAlign,
            maxLines: c ? 3 : 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: c ? 10 : 12,
              height: 1.5,
            ),
          ),
          if (centered) ...[
            SizedBox(height: c ? 10 : 14),
            Text(
              p.title,
              textAlign: textAlign,
              style: TextStyle(
                color: Colors.white54,
                fontSize: c ? 10 : 11,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: c ? 10 : 12),
            PortfolioSocialBar(
              links: p.socialLinks,
              compact: c,
              variant: SocialBarVariant.outlined,
              centered: centered,
              borderColor: Colors.white24,
              iconColor: Colors.white,
            ),
          ],
        ],
      ),
    );
  }

  Widget _titleBlock(bool c, {bool centered = false}) {
    final mySize = c ? 28.0 : 36.0;
    final portfolioSize = c ? 26.0 : 36.0;

    final myRow = Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'My',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: mySize,
            height: 1,
          ),
        ),
        Expanded(
          child: Container(
            height: 2,
            margin: EdgeInsets.only(left: c ? 10 : 14, bottom: c ? 6 : 8),
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        SizedBox(width: double.infinity, child: myRow),
        Align(
          alignment: centered ? Alignment.center : Alignment.centerLeft,
          child: Text(
            'Portfolio',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: portfolioSize,
              height: 1.1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _reviews(bool c) {
    return Container(
      color: const Color(0xFF1F1F1F),
      padding: EdgeInsets.all(c ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TESTIMONIALS',
            style: TextStyle(
              color: Colors.white54,
              letterSpacing: 2,
              fontSize: c ? 9 : 10,
            ),
          ),
          SizedBox(height: c ? 10 : 14),
          for (var i = 0; i < PortfolioDesignHelpers.testimonials.length; i++)
            PortfolioListReveal(
              index: i,
              compact: c,
              child: Container(
                margin: EdgeInsets.only(bottom: c ? 10 : 12),
                padding: EdgeInsets.all(c ? 12 : 14),
                decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: Colors.white.withValues(alpha: 0.4), width: 2)),
                ),
                child: Text(
                  PortfolioDesignHelpers.testimonials[i].quote,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: c ? 10 : 12,
                    height: 1.45,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _work(bool c) {
    return Padding(
      padding: EdgeInsets.all(c ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WORK',
            style: TextStyle(
              color: Colors.white54,
              letterSpacing: 2,
              fontSize: c ? 9 : 10,
            ),
          ),
          SizedBox(height: c ? 10 : 14),
          for (var i = 0; i < PortfolioDesignHelpers.projects.length; i++)
            PortfolioListReveal(
              index: i,
              compact: c,
              child: Container(
                margin: EdgeInsets.only(bottom: c ? 8 : 10),
                padding: EdgeInsets.symmetric(vertical: c ? 10 : 12, horizontal: c ? 4 : 8),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.15))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        PortfolioDesignHelpers.projects[i].title,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: c ? 11 : 13,
                        ),
                      ),
                    ),
                    Text(
                      PortfolioDesignHelpers.projects[i].year,
                      style: TextStyle(color: Colors.white38, fontSize: c ? 10 : 11),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
