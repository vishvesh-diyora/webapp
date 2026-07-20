import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:webapp/features/dashboard/models/category_template.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_avatar.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_helpers.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_motion.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_social_bar.dart';

/// 5 — Aurora glass: gradient orbs + frosted cards.
class AuroraGlassDesign extends StatelessWidget {
  const AuroraGlassDesign({
    super.key,
    required this.template,
    required this.compact,
    required this.mobileProfileLayout,
  });

  final CategoryTemplate template;
  final bool compact;
  final bool mobileProfileLayout;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF312E81)],
              ),
            ),
          ),
        ),
        ..._orbs(compact),
        buildAnimatedPortfolio(
          template: template,
          compact: compact,
          motion: PortfolioMotion.blurFloat,
          profile: _hero,
          testimonials: _reviews,
          projects: _work,
        ),
      ],
    );
  }

  List<Widget> _orbs(bool c) => [
        Positioned(top: c ? -20 : -40, right: c ? -30 : -60, child: _orb(c ? 120 : 180, const Color(0xFF06B6D4))),
        Positioned(bottom: c ? 40 : 80, left: c ? -20 : -40, child: _orb(c ? 100 : 160, const Color(0xFFEC4899))),
      ];

  Widget _orb(double s, Color c) => Container(
        width: s,
        height: s,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [c.withValues(alpha: 0.45), Colors.transparent]),
        ),
      );

  Widget _glass({required Widget child, required bool c}) => ClipRRect(
        borderRadius: BorderRadius.circular(c ? 16 : 20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(c ? 16 : 20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: child,
          ),
        ),
      );

  Widget _hero(bool c) {
    final p = PortfolioDesignHelpers.profile;
    final pad = c ? 16.0 : 24.0;
    final avatar = PortfolioFloatLoop(
      amplitude: 8,
      child: PortfolioAvatar(profile: p, size: c ? 100 : 130),
    );

    final inner = Column(
      crossAxisAlignment: mobileProfileLayout ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        if (mobileProfileLayout) ...[avatar, SizedBox(height: c ? 14 : 18)],
        PortfolioNameBlock(
          name: p.name,
          accentColor: const Color(0xFF06B6D4),
          nameColor: Colors.white,
          nameSize: c ? 26.0 : 34.0,
          align: mobileProfileLayout ? TextAlign.center : TextAlign.start,
        ),
        SizedBox(height: c ? 6 : 8),
        Text(
          p.title,
          textAlign: mobileProfileLayout ? TextAlign.center : TextAlign.start,
          style: TextStyle(color: const Color(0xFF06B6D4), fontSize: c ? 13 : 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: c ? 10 : 14),
        Text(
          p.bio,
          textAlign: mobileProfileLayout ? TextAlign.center : TextAlign.start,
          style: TextStyle(color: Colors.white70, fontSize: c ? 11 : 13, height: 1.45),
        ),
        SizedBox(height: c ? 14 : 18),
        PortfolioSocialBar(
          links: p.socialLinks,
          compact: c,
          variant: SocialBarVariant.glass,
          centered: mobileProfileLayout,
        ),
      ],
    );

    return Padding(
      padding: PortfolioDesignHelpers.heroPadding(pad: pad, mobileProfileLayout: mobileProfileLayout),
      child: _glass(
        c: c,
        child: Padding(
          padding: EdgeInsets.all(c ? 14 : 18),
          child: mobileProfileLayout
              ? inner
              : Row(
                  children: [
                    Expanded(child: inner),
                    SizedBox(width: c ? 10 : 16),
                    avatar,
                  ],
                ),
        ),
      ),
    );
  }

  Widget _reviews(bool c) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: c ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reviews', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: c ? 14 : 16)),
          SizedBox(height: c ? 10 : 12),
          for (var i = 0; i < 2; i++)
            Padding(
              padding: EdgeInsets.only(bottom: c ? 8 : 10),
              child: PortfolioListReveal(
                index: i,
                compact: c,
                child: _glass(
                  c: c,
                  child: Padding(
                    padding: EdgeInsets.all(c ? 10 : 12),
                    child: Text(
                      PortfolioDesignHelpers.testimonials[i].quote,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white70, fontSize: c ? 10 : 12),
                    ),
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
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: c ? 10 : 12,
        crossAxisSpacing: c ? 10 : 12,
        childAspectRatio: 1.05,
        children: [
          for (var i = 0; i < PortfolioDesignHelpers.projects.length; i++)
            PortfolioListReveal(
              index: i,
              compact: c,
              child: _glass(
                c: c,
                child: Padding(
                  padding: EdgeInsets.all(c ? 10 : 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(PortfolioDesignHelpers.projects[i].icon, color: const Color(0xFF06B6D4), size: c ? 20 : 24),
                      const Spacer(),
                      Text(
                        PortfolioDesignHelpers.projects[i].title,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: c ? 10 : 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
