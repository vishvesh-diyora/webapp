import 'package:flutter/material.dart';
import 'package:webapp/features/dashboard/models/category_template.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_avatar.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_helpers.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_motion.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_social_bar.dart';

/// 1 — Dark dev hero like reference: black bg, purple accent, memoji beside name.
class DarkDevDesign extends StatelessWidget {
  const DarkDevDesign({
    super.key,
    required this.template,
    required this.compact,
    required this.mobileProfileLayout,
  });

  final CategoryTemplate template;
  final bool compact;
  final bool mobileProfileLayout;

  static const _accent = Color(0xFF8B5CF6);
  static const _bg = Color(0xFF000000);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _bg,
      child: buildAnimatedPortfolio(
        template: template,
        compact: compact,
        motion: PortfolioMotion.scaleBounce,
        profile: _hero,
        testimonials: _reviews,
        projects: _work,
      ),
    );
  }

  Widget _hero(bool c) {
    final p = PortfolioDesignHelpers.profile;
    final pad = c ? 16.0 : 24.0;
    final avatar = PortfolioFloatLoop(
      child: PortfolioAvatar(profile: p, size: c ? 110 : 140),
    );
    final nameSize = c ? 28.0 : 36.0;
    final jobSize = c ? 14.0 : 17.0;

    final textCol = Column(
      crossAxisAlignment: mobileProfileLayout
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        PortfolioNameBlock(
          name: p.name,
          accentColor: _accent,
          nameColor: Colors.white,
          nameSize: nameSize,
          align: mobileProfileLayout ? TextAlign.center : TextAlign.start,
        ),
        SizedBox(height: c ? 8 : 10),
        Text(
          p.title,
          textAlign: mobileProfileLayout ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            color: _accent,
            fontSize: jobSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: c ? 10 : 14),
        Text(
          p.bio,
          textAlign: mobileProfileLayout ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            color: const Color(0xFF94A3B8),
            fontSize: c ? 11 : 13,
            height: 1.5,
          ),
        ),
        SizedBox(height: c ? 14 : 18),
        PortfolioSocialBar(
          links: p.socialLinks,
          compact: c,
          variant: SocialBarVariant.outlined,
          centered: mobileProfileLayout,
          borderColor: Colors.white24,
        ),
      ],
    );

    return Container(
      color: _bg,
      padding: PortfolioDesignHelpers.heroPadding(
        pad: pad,
        mobileProfileLayout: mobileProfileLayout,
      ),
      child: mobileProfileLayout
          ? Column(children: [avatar, SizedBox(height: c ? 16 : 20), textCol])
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: textCol),
                SizedBox(width: c ? 8 : 16),
                avatar,
              ],
            ),
    );
  }

  Widget _reviews(bool c) {
    return Container(
      color: const Color(0xFF0A0A0A),
      padding: EdgeInsets.all(c ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Reviews', c),
          SizedBox(height: c ? 10 : 14),
          SizedBox(
            height: c ? 120 : 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: PortfolioDesignHelpers.testimonials.length,
              separatorBuilder: (_, _) => SizedBox(width: c ? 10 : 12),
              itemBuilder: (_, i) {
                final t = PortfolioDesignHelpers.testimonials[i];
                return PortfolioListReveal(
                  index: i,
                  compact: c,
                  child: Container(
                  width: c ? 210 : 250,
                  padding: EdgeInsets.all(c ? 12 : 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141414),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _accent.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PortfolioDesignHelpers.starRating(t.rating, color: _accent, size: c ? 12 : 14),
                      SizedBox(height: c ? 8 : 10),
                      Expanded(
                        child: Text(
                          '"${t.quote}"',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white70, fontSize: c ? 10 : 12, height: 1.4),
                        ),
                      ),
                      Text(t.author, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: c ? 10 : 11)),
                    ],
                  ),
                ),
                );
              },
            ),
          ),
          SizedBox(height: c ? 14 : 18),
          _label('Skills', c),
          SizedBox(height: c ? 8 : 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final h in PortfolioDesignHelpers.highlights)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: c ? 10 : 12, vertical: c ? 5 : 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: _accent.withValues(alpha: 0.4)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(h.title, style: TextStyle(color: _accent, fontSize: c ? 10 : 11)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _work(bool c) {
    return Padding(
      padding: EdgeInsets.all(c ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Projects', c),
          SizedBox(height: c ? 10 : 14),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: c ? 10 : 12,
            crossAxisSpacing: c ? 10 : 12,
            childAspectRatio: 1.0,
            children: [
              for (final proj in PortfolioDesignHelpers.projects)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: proj.gradient),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: EdgeInsets.all(c ? 10 : 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(proj.icon, color: Colors.white, size: c ? 22 : 26),
                      const Spacer(),
                      Text(proj.title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: c ? 11 : 13)),
                      Text(proj.year, style: TextStyle(color: Colors.white70, fontSize: c ? 9 : 10)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _label(String t, bool c) => Text(
        t.toUpperCase(),
        style: TextStyle(
          color: _accent,
          fontWeight: FontWeight.w700,
          fontSize: c ? 11 : 12,
          letterSpacing: 1.5,
        ),
      );
}
