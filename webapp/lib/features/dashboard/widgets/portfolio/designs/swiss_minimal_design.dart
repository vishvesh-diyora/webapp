import 'package:flutter/material.dart';
import 'package:webapp/features/dashboard/models/category_template.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_avatar.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_helpers.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_motion.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_social_bar.dart';

/// 2 — Swiss minimal: white space, thin rules, numbered testimonials.
class SwissMinimalDesign extends StatelessWidget {
  const SwissMinimalDesign({
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
      color: Colors.white,
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
    final avatar = PortfolioAvatar(profile: p, size: c ? 100 : 130, floating: false);

    final content = Column(
      crossAxisAlignment: mobileProfileLayout ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        if (mobileProfileLayout) ...[avatar, SizedBox(height: c ? 16 : 20)],
        Text(
          p.name.toUpperCase(),
          textAlign: mobileProfileLayout ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            fontWeight: FontWeight.w200,
            fontSize: c ? 32 : 42,
            letterSpacing: 4,
            color: const Color(0xFF0F172A),
            height: 1.0,
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: c ? 10 : 14),
          height: 1,
          width: mobileProfileLayout ? 60 : 80,
          color: const Color(0xFF0F172A),
        ),
        Text(
          p.title,
          textAlign: mobileProfileLayout ? TextAlign.center : TextAlign.start,
          style: TextStyle(fontSize: c ? 13 : 15, color: const Color(0xFF64748B), letterSpacing: 1),
        ),
        SizedBox(height: c ? 12 : 16),
        Text(
          p.bio,
          textAlign: mobileProfileLayout ? TextAlign.center : TextAlign.start,
          style: TextStyle(fontSize: c ? 11 : 13, color: const Color(0xFF94A3B8), height: 1.6),
        ),
        SizedBox(height: c ? 16 : 20),
        PortfolioSocialBar(
          links: p.socialLinks,
          compact: c,
          variant: SocialBarVariant.minimal,
          centered: mobileProfileLayout,
        ),
      ],
    );

    return Padding(
      padding: PortfolioDesignHelpers.heroPadding(pad: pad, mobileProfileLayout: mobileProfileLayout),
      child: mobileProfileLayout
          ? content
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: content),
                SizedBox(width: c ? 12 : 24),
                Padding(padding: EdgeInsets.only(top: c ? 8 : 12), child: avatar),
              ],
            ),
    );
  }

  Widget _reviews(bool c) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0)), bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      padding: EdgeInsets.symmetric(vertical: c ? 20 : 28, horizontal: c ? 18 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < PortfolioDesignHelpers.testimonials.length; i++) ...[
            if (i > 0) SizedBox(height: c ? 16 : 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('0${i + 1}', style: TextStyle(fontSize: c ? 28 : 36, fontWeight: FontWeight.w100, color: const Color(0xFFE2E8F0))),
                SizedBox(width: c ? 12 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '"${PortfolioDesignHelpers.testimonials[i].quote}"',
                        style: TextStyle(fontSize: c ? 11 : 13, fontStyle: FontStyle.italic, height: 1.5, color: const Color(0xFF334155)),
                      ),
                      SizedBox(height: c ? 6 : 8),
                      Text(
                        PortfolioDesignHelpers.testimonials[i].author,
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: c ? 10 : 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: c ? 20 : 28),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              for (final h in PortfolioDesignHelpers.highlights)
                Text('${h.title}  ·', style: TextStyle(fontSize: c ? 10 : 12, color: const Color(0xFF64748B))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _work(bool c) {
    return Padding(
      padding: EdgeInsets.all(c ? 18 : 28),
      child: Column(
        children: [
          for (final proj in PortfolioDesignHelpers.projects)
            Container(
              margin: EdgeInsets.only(bottom: c ? 1 : 2),
              padding: EdgeInsets.symmetric(vertical: c ? 14 : 18, horizontal: c ? 4 : 8),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: c ? 36 : 44,
                    child: Text(proj.year, style: TextStyle(fontSize: c ? 11 : 13, color: const Color(0xFF94A3B8))),
                  ),
                  Expanded(child: Text(proj.title, style: TextStyle(fontWeight: FontWeight.w500, fontSize: c ? 12 : 14))),
                  Icon(Icons.arrow_outward, size: c ? 16 : 18, color: const Color(0xFFCBD5E1)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
