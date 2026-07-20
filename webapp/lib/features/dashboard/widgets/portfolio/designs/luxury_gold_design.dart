import 'package:flutter/material.dart';
import 'package:webapp/features/dashboard/models/category_template.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_avatar.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_helpers.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_motion.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_social_bar.dart';

/// 10 — Luxury gold: marble tones, gold accents, premium spacing.
class LuxuryGoldDesign extends StatelessWidget {
  const LuxuryGoldDesign({
    super.key,
    required this.template,
    required this.compact,
    required this.mobileProfileLayout,
  });

  final CategoryTemplate template;
  final bool compact;
  final bool mobileProfileLayout;

  static const _gold = Color(0xFFD4AF37);
  static const _marble = Color(0xFFFAF8F5);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFAF8F5), Color(0xFFF0EBE3)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: buildAnimatedPortfolio(
        template: template,
        compact: compact,
        motion: PortfolioMotion.luxuryFade,
        profile: _hero,
        testimonials: _reviews,
        projects: _work,
      ),
    );
  }

  Widget _hero(bool c) {
    final p = PortfolioDesignHelpers.profile;
    final pad = c ? 18.0 : 28.0;
    final avatar = Container(
      padding: EdgeInsets.all(c ? 3 : 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _gold, width: 2),
      ),
      child: PortfolioFloatLoop(
        amplitude: 4,
        child: PortfolioAvatar(profile: p, size: c ? 100 : 130),
      ),
    );

    final text = Column(
      crossAxisAlignment: mobileProfileLayout ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          '— PORTFOLIO',
          style: TextStyle(color: _gold, letterSpacing: 3, fontSize: c ? 9 : 10),
        ),
        SizedBox(height: c ? 8 : 10),
        PortfolioNameBlock(
          name: p.name,
          accentColor: _gold,
          nameColor: const Color(0xFF1C1917),
          nameSize: c ? 26.0 : 36.0,
          align: mobileProfileLayout ? TextAlign.center : TextAlign.start,
        ),
        SizedBox(height: c ? 6 : 8),
        Text(
          p.title,
          textAlign: mobileProfileLayout ? TextAlign.center : TextAlign.start,
          style: TextStyle(color: const Color(0xFF78716C), fontSize: c ? 13 : 16, fontStyle: FontStyle.italic),
        ),
        SizedBox(height: c ? 12 : 16),
        PortfolioSocialBar(links: p.socialLinks, compact: c, variant: SocialBarVariant.luxury, centered: mobileProfileLayout),
      ],
    );

    return Padding(
      padding: PortfolioDesignHelpers.heroPadding(pad: pad, mobileProfileLayout: mobileProfileLayout),
      child: mobileProfileLayout
          ? Column(children: [avatar, SizedBox(height: c ? 16 : 22), text])
          : Row(crossAxisAlignment: CrossAxisAlignment.center, children: [Expanded(child: text), SizedBox(width: c ? 16 : 24), avatar]),
    );
  }

  Widget _reviews(bool c) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: c ? 18 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Testimonials', style: TextStyle(color: _gold, fontWeight: FontWeight.w600, fontSize: c ? 12 : 14, letterSpacing: 1)),
          SizedBox(height: c ? 12 : 16),
          for (var i = 0; i < PortfolioDesignHelpers.testimonials.length; i++)
            PortfolioListReveal(
              index: i,
              compact: c,
              child: Container(
                margin: EdgeInsets.only(bottom: c ? 10 : 14),
                padding: EdgeInsets.all(c ? 14 : 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: _gold.withValues(alpha: 0.4)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\u201C${PortfolioDesignHelpers.testimonials[i].quote}\u201D',
                      style: TextStyle(color: const Color(0xFF44403C), fontSize: c ? 11 : 13, height: 1.5, fontStyle: FontStyle.italic),
                    ),
                    SizedBox(height: c ? 8 : 10),
                    Text(
                      PortfolioDesignHelpers.testimonials[i].author,
                      style: TextStyle(color: _gold, fontWeight: FontWeight.w600, fontSize: c ? 10 : 12),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _work(bool c) {
    return Padding(
      padding: EdgeInsets.all(c ? 18 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Selected Works', style: TextStyle(color: _gold, fontWeight: FontWeight.w600, fontSize: c ? 12 : 14, letterSpacing: 1)),
          SizedBox(height: c ? 12 : 16),
          for (var i = 0; i < PortfolioDesignHelpers.projects.length; i++)
            PortfolioListReveal(
              index: i,
              compact: c,
              child: Container(
                margin: EdgeInsets.only(bottom: c ? 10 : 12),
                padding: EdgeInsets.all(c ? 14 : 16),
                decoration: BoxDecoration(
                  color: _marble,
                  border: Border(left: BorderSide(color: _gold, width: 3)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(PortfolioDesignHelpers.projects[i].title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: c ? 12 : 14)),
                          Text(PortfolioDesignHelpers.projects[i].category, style: TextStyle(color: const Color(0xFF78716C), fontSize: c ? 10 : 11)),
                        ],
                      ),
                    ),
                    Text(PortfolioDesignHelpers.projects[i].year, style: TextStyle(color: _gold, fontWeight: FontWeight.w600, fontSize: c ? 11 : 12)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
