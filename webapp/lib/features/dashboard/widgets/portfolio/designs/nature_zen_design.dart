import 'package:flutter/material.dart';
import 'package:webapp/features/dashboard/models/category_template.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_avatar.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_helpers.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_motion.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_social_bar.dart';

/// 9 — Nature zen: organic curves, sage greens, timeline projects.
class NatureZenDesign extends StatelessWidget {
  const NatureZenDesign({
    super.key,
    required this.template,
    required this.compact,
    required this.mobileProfileLayout,
  });

  final CategoryTemplate template;
  final bool compact;
  final bool mobileProfileLayout;

  static const _sage = Color(0xFF4A7C59);
  static const _cream = Color(0xFFF7F3EB);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _cream,
      child: buildAnimatedPortfolio(
        template: template,
        compact: compact,
        motion: PortfolioMotion.zenRise,
        profile: _hero,
        testimonials: _reviews,
        projects: _work,
      ),
    );
  }

  Widget _hero(bool c) {
    final p = PortfolioDesignHelpers.profile;
    final pad = c ? 16.0 : 24.0;
    final avatar = Stack(
      clipBehavior: Clip.none,
      children: [
        PortfolioFloatLoop(
          amplitude: 5,
          child: PortfolioAvatar(profile: p, size: c ? 100 : 130),
        ),
        Positioned(
          top: -4,
          right: -4,
          child: Icon(Icons.eco, color: _sage, size: c ? 20 : 26),
        ),
      ],
    );

    final text = Column(
      crossAxisAlignment: mobileProfileLayout ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        PortfolioNameBlock(
          name: p.name,
          accentColor: _sage,
          nameColor: const Color(0xFF2D4A3E),
          nameSize: c ? 26.0 : 34.0,
          align: mobileProfileLayout ? TextAlign.center : TextAlign.start,
        ),
        SizedBox(height: c ? 6 : 8),
        Text(
          p.title,
          textAlign: mobileProfileLayout ? TextAlign.center : TextAlign.start,
          style: TextStyle(color: _sage, fontSize: c ? 13 : 15, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: c ? 10 : 14),
        Text(
          p.bio,
          textAlign: mobileProfileLayout ? TextAlign.center : TextAlign.start,
          style: TextStyle(color: const Color(0xFF64748B), fontSize: c ? 11 : 13, height: 1.55),
        ),
        SizedBox(height: c ? 14 : 18),
        PortfolioSocialBar(links: p.socialLinks, compact: c, variant: SocialBarVariant.minimal, centered: mobileProfileLayout, borderColor: _sage.withValues(alpha: 0.3)),
      ],
    );

    return Container(
      padding: PortfolioDesignHelpers.heroPadding(pad: pad, mobileProfileLayout: mobileProfileLayout),
      decoration: BoxDecoration(
        color: _cream,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(c ? 28 : 36)),
      ),
      child: mobileProfileLayout
          ? Column(children: [avatar, SizedBox(height: c ? 14 : 18), text])
          : Row(crossAxisAlignment: CrossAxisAlignment.center, children: [Expanded(child: text), SizedBox(width: c ? 12 : 20), avatar]),
    );
  }

  Widget _reviews(bool c) {
    return Padding(
      padding: EdgeInsets.all(c ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kind Words', style: TextStyle(color: _sage, fontWeight: FontWeight.w600, fontSize: c ? 13 : 15)),
          SizedBox(height: c ? 10 : 14),
          for (var i = 0; i < PortfolioDesignHelpers.testimonials.length; i++)
            PortfolioListReveal(
              index: i,
              compact: c,
              child: Container(
                margin: EdgeInsets.only(bottom: c ? 10 : 12),
                padding: EdgeInsets.all(c ? 12 : 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(c ? 16 : 20),
                  border: Border.all(color: _sage.withValues(alpha: 0.2)),
                ),
                child: Text(
                  PortfolioDesignHelpers.testimonials[i].quote,
                  style: TextStyle(color: const Color(0xFF475569), fontSize: c ? 11 : 13, height: 1.45, fontStyle: FontStyle.italic),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _work(bool c) {
    return Padding(
      padding: EdgeInsets.fromLTRB(c ? 16 : 24, 0, c ? 16 : 24, c ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Journey', style: TextStyle(color: _sage, fontWeight: FontWeight.w600, fontSize: c ? 13 : 15)),
          SizedBox(height: c ? 10 : 14),
          for (var i = 0; i < PortfolioDesignHelpers.projects.length; i++)
            PortfolioListReveal(
              index: i,
              compact: c,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(width: 10, height: 10, decoration: BoxDecoration(color: _sage, shape: BoxShape.circle)),
                      if (i < PortfolioDesignHelpers.projects.length - 1)
                        Container(width: 2, height: c ? 40 : 48, color: _sage.withValues(alpha: 0.3)),
                    ],
                  ),
                  SizedBox(width: c ? 10 : 14),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: c ? 14 : 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(PortfolioDesignHelpers.projects[i].year, style: TextStyle(color: _sage, fontSize: c ? 10 : 11)),
                          Text(PortfolioDesignHelpers.projects[i].title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: c ? 12 : 14)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
