import 'package:flutter/material.dart';
import 'package:webapp/features/dashboard/models/category_template.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_avatar.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_helpers.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_motion.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_social_bar.dart';

/// 8 — Brutalist: harsh blocks, zero radius, bold contrast.
class BrutalistDesign extends StatelessWidget {
  const BrutalistDesign({
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
    return ColoredBox(
      color: const Color(0xFFF5F5F0),
      child: buildAnimatedPortfolio(
        template: template,
        compact: compact,
        motion: PortfolioMotion.brutalSnap,
        profile: _hero,
        testimonials: _reviews,
        projects: _work,
      ),
    );
  }

  Widget _hero(bool c) {
    final p = PortfolioDesignHelpers.profile;
    final pad = c ? 16.0 : 24.0;
    final avatar = Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 4)),
      child: PortfolioAvatar(profile: p, size: c ? 96 : 120, floating: false),
    );

    final text = Column(
      crossAxisAlignment: mobileProfileLayout ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          p.name.toUpperCase(),
          textAlign: mobileProfileLayout ? TextAlign.center : TextAlign.start,
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: c ? 28 : 36, height: 0.95, color: Colors.black),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: c ? 8 : 12),
          height: 4,
          width: double.infinity,
          color: Colors.black,
        ),
        Text(
          p.title.toUpperCase(),
          textAlign: mobileProfileLayout ? TextAlign.center : TextAlign.start,
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: c ? 11 : 13, letterSpacing: 1.5),
        ),
        SizedBox(height: c ? 12 : 16),
        PortfolioSocialBar(links: p.socialLinks, compact: c, variant: SocialBarVariant.brutalist, centered: mobileProfileLayout),
      ],
    );

    return Padding(
      padding: PortfolioDesignHelpers.heroPadding(pad: pad, mobileProfileLayout: mobileProfileLayout),
      child: mobileProfileLayout
          ? Column(children: [avatar, SizedBox(height: c ? 16 : 20), text])
          : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: text), SizedBox(width: c ? 12 : 20), avatar]),
    );
  }

  Widget _reviews(bool c) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: c ? 16 : 24),
      child: Column(
        children: [
          for (var i = 0; i < PortfolioDesignHelpers.testimonials.length; i++)
            PortfolioListReveal(
              index: i,
              compact: c,
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: c ? 8 : 10),
                padding: EdgeInsets.all(c ? 12 : 14),
                color: Colors.black,
                child: Text(
                  PortfolioDesignHelpers.testimonials[i].quote.toUpperCase(),
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: c ? 9 : 11, height: 1.4),
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
        children: [
          for (var i = 0; i < PortfolioDesignHelpers.projects.length; i++)
            PortfolioListReveal(
              index: i,
              compact: c,
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: c ? 6 : 8),
                padding: EdgeInsets.all(c ? 12 : 14),
                color: i.isEven ? const Color(0xFFFFE500) : Colors.black,
                child: Text(
                  PortfolioDesignHelpers.projects[i].title.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: c ? 12 : 14,
                    color: i.isEven ? Colors.black : Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
