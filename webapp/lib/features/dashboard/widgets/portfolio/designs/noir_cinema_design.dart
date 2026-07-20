import 'package:flutter/material.dart';
import 'package:webapp/features/dashboard/models/category_template.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_avatar.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_helpers.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_motion.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_social_bar.dart';

/// 3 — Noir cinema: gold frames, widescreen project banners.
class NoirCinemaDesign extends StatelessWidget {
  const NoirCinemaDesign({
    super.key,
    required this.template,
    required this.compact,
    required this.mobileProfileLayout,
  });

  final CategoryTemplate template;
  final bool compact;
  final bool mobileProfileLayout;

  static const _gold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
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
    final pad = c ? 16.0 : 24.0;
    final avatar = Container(
      padding: EdgeInsets.all(c ? 3 : 4),
      decoration: BoxDecoration(
        border: Border.all(color: _gold, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: PortfolioAvatar(profile: p, size: c ? 100 : 130),
    );

    final text = Column(
      crossAxisAlignment: mobileProfileLayout ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text('DIRECTOR', style: TextStyle(color: _gold, fontSize: c ? 9 : 10, letterSpacing: 3)),
        SizedBox(height: c ? 6 : 8),
        PortfolioNameBlock(
          name: p.name,
          accentColor: _gold,
          nameColor: Colors.white,
          nameSize: c ? 26.0 : 34.0,
          align: mobileProfileLayout ? TextAlign.center : TextAlign.start,
        ),
        SizedBox(height: c ? 6 : 8),
        Text(
          p.title,
          textAlign: mobileProfileLayout ? TextAlign.center : TextAlign.start,
          style: TextStyle(color: Colors.white54, fontSize: c ? 12 : 14),
        ),
        SizedBox(height: c ? 12 : 16),
        PortfolioSocialBar(
          links: p.socialLinks,
          compact: c,
          variant: SocialBarVariant.outlined,
          centered: mobileProfileLayout,
          borderColor: _gold.withValues(alpha: 0.5),
          iconColor: _gold,
        ),
      ],
    );

    return Padding(
      padding: PortfolioDesignHelpers.heroPadding(pad: pad, mobileProfileLayout: mobileProfileLayout),
      child: mobileProfileLayout
          ? Column(children: [avatar, SizedBox(height: c ? 14 : 18), text])
          : Row(children: [Expanded(child: text), SizedBox(width: c ? 12 : 20), avatar]),
    );
  }

  Widget _reviews(bool c) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: c ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('▮ CLIENT VOICES', style: TextStyle(color: _gold, fontSize: c ? 10 : 11, letterSpacing: 2)),
          SizedBox(height: c ? 12 : 16),
          for (final t in PortfolioDesignHelpers.testimonials)
            Container(
              margin: EdgeInsets.only(bottom: c ? 10 : 12),
              padding: EdgeInsets.all(c ? 14 : 16),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                border: Border(left: BorderSide(color: _gold, width: 3)),
              ),
              child: Text(
                '\u201C${t.quote}\u201D\n\n— ${t.author}',
                style: TextStyle(color: Colors.white70, fontSize: c ? 10 : 12, height: 1.5, fontStyle: FontStyle.italic),
              ),
            ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final h in PortfolioDesignHelpers.highlights)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: c ? 8 : 10, vertical: 4),
                  decoration: BoxDecoration(border: Border.all(color: _gold.withValues(alpha: 0.4))),
                  child: Text(h.title, style: TextStyle(color: _gold, fontSize: c ? 9 : 10)),
                ),
            ],
          ),
          SizedBox(height: c ? 16 : 20),
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
          Text('▮ FILMOGRAPHY', style: TextStyle(color: _gold, fontSize: c ? 10 : 11, letterSpacing: 2)),
          SizedBox(height: c ? 10 : 14),
          for (final proj in PortfolioDesignHelpers.projects)
            Container(
              margin: EdgeInsets.only(bottom: c ? 8 : 10),
              height: c ? 64 : 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [proj.gradient.first.withValues(alpha: 0.7), Colors.black],
                ),
                border: Border.all(color: _gold.withValues(alpha: 0.3)),
              ),
              padding: EdgeInsets.all(c ? 12 : 14),
              child: Row(
                children: [
                  Icon(proj.icon, color: _gold, size: c ? 24 : 30),
                  SizedBox(width: c ? 10 : 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(proj.title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: c ? 12 : 14)),
                        Text('${proj.category} · ${proj.year}', style: TextStyle(color: Colors.white54, fontSize: c ? 9 : 10)),
                      ],
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
