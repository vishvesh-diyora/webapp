import 'package:flutter/material.dart';
import 'package:webapp/features/dashboard/models/category_template.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_avatar.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_helpers.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_motion.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_social_bar.dart';

/// 7 — Soft pastel: bubble cards, friendly rounded bento grid.
class PastelDreamDesign extends StatelessWidget {
  const PastelDreamDesign({
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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFF1F2), Color(0xFFFDF4FF), Color(0xFFEFF6FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: buildAnimatedPortfolio(
        template: template,
        compact: compact,
        motion: PortfolioMotion.bounceSoft,
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
      amplitude: 10,
      child: Container(
        padding: EdgeInsets.all(c ? 4 : 6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: const Color(0xFFEC4899).withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        child: PortfolioAvatar(profile: p, size: c ? 96 : 120),
      ),
    );

    final text = Column(
      crossAxisAlignment: mobileProfileLayout ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        PortfolioNameBlock(
          name: p.name,
          accentColor: const Color(0xFFEC4899),
          nameColor: const Color(0xFF831843),
          nameSize: c ? 26.0 : 34.0,
          align: mobileProfileLayout ? TextAlign.center : TextAlign.start,
        ),
        SizedBox(height: c ? 6 : 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: c ? 10 : 12, vertical: c ? 4 : 6),
          decoration: BoxDecoration(
            color: const Color(0xFFEC4899).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(p.title, style: TextStyle(color: const Color(0xFFBE185D), fontSize: c ? 12 : 14, fontWeight: FontWeight.w600)),
        ),
        SizedBox(height: c ? 10 : 14),
        Text(
          p.bio,
          textAlign: mobileProfileLayout ? TextAlign.center : TextAlign.start,
          style: TextStyle(color: const Color(0xFF64748B), fontSize: c ? 11 : 13, height: 1.5),
        ),
        SizedBox(height: c ? 14 : 18),
        PortfolioSocialBar(links: p.socialLinks, compact: c, variant: SocialBarVariant.pastel, centered: mobileProfileLayout),
      ],
    );

    return Padding(
      padding: PortfolioDesignHelpers.heroPadding(pad: pad, mobileProfileLayout: mobileProfileLayout),
      child: mobileProfileLayout
          ? Column(children: [avatar, SizedBox(height: c ? 16 : 20), text])
          : Row(crossAxisAlignment: CrossAxisAlignment.center, children: [Expanded(child: text), SizedBox(width: c ? 12 : 20), avatar]),
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
                margin: EdgeInsets.only(bottom: c ? 10 : 12),
                padding: EdgeInsets.all(c ? 14 : 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(c ? 20 : 24),
                  boxShadow: [BoxShadow(color: Colors.pink.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: Text(
                  '"${PortfolioDesignHelpers.testimonials[i].quote}"',
                  style: TextStyle(color: const Color(0xFF475569), fontSize: c ? 11 : 13, height: 1.45),
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
        childAspectRatio: 1.0,
        children: [
          for (var i = 0; i < PortfolioDesignHelpers.projects.length; i++)
            PortfolioListReveal(
              index: i,
              compact: c,
              child: Container(
                decoration: BoxDecoration(
                  color: [const Color(0xFFFCE7F3), const Color(0xFFEDE9FE), const Color(0xFFDBEAFE), const Color(0xFFD1FAE5)][i % 4],
                  borderRadius: BorderRadius.circular(c ? 20 : 24),
                ),
                padding: EdgeInsets.all(c ? 10 : 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(PortfolioDesignHelpers.projects[i].icon, color: const Color(0xFF831843)),
                    const Spacer(),
                    Text(PortfolioDesignHelpers.projects[i].title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: c ? 11 : 13)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
