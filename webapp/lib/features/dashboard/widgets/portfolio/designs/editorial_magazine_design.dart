import 'package:flutter/material.dart';
import 'package:webapp/features/dashboard/models/category_template.dart';
import 'package:webapp/features/dashboard/widgets/device_preview_insets.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_avatar.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_helpers.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_motion.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_social_bar.dart';

/// 4 — Magazine editorial: red/yellow blocks, overlapping memoji.
class EditorialMagazineDesign extends StatelessWidget {
  const EditorialMagazineDesign({
    super.key,
    required this.template,
    required this.compact,
    required this.mobileProfileLayout,
  });

  final CategoryTemplate template;
  final bool compact;
  final bool mobileProfileLayout;

  static const _red = Color(0xFFDC2626);
  static const _yellow = Color(0xFFFBBF24);

  @override
  Widget build(BuildContext context) {
    return buildAnimatedPortfolio(
      template: template,
      compact: compact,
      motion: PortfolioMotion.clipReveal,
      profile: _hero,
      testimonials: _reviews,
      projects: _work,
    );
  }

  Widget _hero(bool c) {
    final p = PortfolioDesignHelpers.profile;
    final parts = p.name.split(' ');
    final first = parts.first;
    final last = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    if (mobileProfileLayout) {
      final topInset = DevicePreviewInsets.iphoneTop;

      // Bleed red into the iPhone top safe area only — rest of screen stays white.
      return Transform.translate(
        offset: Offset(0, -topInset),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: _red,
              padding: EdgeInsets.fromLTRB(
                c ? 16 : 24,
                topInset + (c ? 8 : 12),
                c ? 16 : 24,
                c ? 40 : 52,
              ),
              child: Column(
                children: [
                  PortfolioFloatLoop(
                    amplitude: 4,
                    child: PortfolioAvatar(profile: p, size: c ? 100 : 120),
                  ),
                  SizedBox(height: c ? 12 : 16),
                  Text(first, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: c ? 36 : 44)),
                  if (last.isNotEmpty)
                    Text(last, style: TextStyle(color: _yellow, fontWeight: FontWeight.w900, fontSize: c ? 36 : 44)),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              color: const Color(0xFF0F172A),
              padding: EdgeInsets.all(c ? 16 : 24),
              child: Column(
                children: [
                  Text(p.title.toUpperCase(), style: TextStyle(color: _yellow, letterSpacing: 2, fontSize: c ? 10 : 12)),
                  SizedBox(height: c ? 10 : 14),
                  Text(p.bio, textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: c ? 11 : 13)),
                  SizedBox(height: c ? 14 : 18),
                  PortfolioSocialBar(links: p.socialLinks, compact: c, variant: SocialBarVariant.brutalist, centered: true),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                color: _red,
                padding: EdgeInsets.fromLTRB(c ? 20 : 28, c ? 28 : 40, c ? 12 : 16, c ? 60 : 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(first, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: c ? 32 : 42)),
                    if (last.isNotEmpty)
                      Text(last, style: TextStyle(color: _yellow, fontWeight: FontWeight.w900, fontSize: c ? 32 : 42)),
                    SizedBox(height: c ? 12 : 16),
                    Text(p.title, style: TextStyle(color: Colors.white, fontSize: c ? 13 : 15)),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                color: const Color(0xFF0F172A),
                padding: EdgeInsets.fromLTRB(c ? 12 : 16, c ? 28 : 40, c ? 16 : 24, c ? 24 : 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.bio, style: TextStyle(color: Colors.white70, fontSize: c ? 11 : 13, height: 1.5)),
                    SizedBox(height: c ? 14 : 18),
                    PortfolioSocialBar(links: p.socialLinks, compact: c, variant: SocialBarVariant.brutalist),
                  ],
                ),
              ),
            ),
          ],
        ),
        Positioned(
          right: c ? 20 : 32,
          top: c ? 70 : 90,
          child: PortfolioFloatLoop(
            child: PortfolioAvatar(profile: p, size: c ? 90 : 120),
          ),
        ),
      ],
    );
  }

  Widget _reviews(bool c) {
    final featured = PortfolioDesignHelpers.testimonials.first;
    return Padding(
      padding: EdgeInsets.all(c ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(c ? 14 : 18),
            color: const Color(0xFFFEF3C7),
            child: Text(
              '\u201C${featured.quote}\u201D',
              style: TextStyle(fontSize: c ? 13 : 16, fontWeight: FontWeight.w700, height: 1.4),
            ),
          ),
          SizedBox(height: c ? 12 : 16),
          for (var i = 0; i < PortfolioDesignHelpers.highlights.length; i++)
            PortfolioListReveal(
              index: i,
              compact: c,
              child: Padding(
                padding: EdgeInsets.only(bottom: c ? 8 : 10),
                child: Row(
                  children: [
                    Text('▸', style: TextStyle(color: _red, fontSize: c ? 14 : 16)),
                    SizedBox(width: 8),
                    Expanded(child: Text(PortfolioDesignHelpers.highlights[i].title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: c ? 12 : 14))),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _work(bool c) {
    final projects = PortfolioDesignHelpers.projects;
    return Padding(
      padding: EdgeInsets.fromLTRB(c ? 16 : 24, 0, c ? 16 : 24, c ? 16 : 24),
      child: Column(
        children: [
          Container(
            height: c ? 90 : 120,
            width: double.infinity,
            color: _red,
            padding: EdgeInsets.all(c ? 12 : 16),
            alignment: Alignment.bottomLeft,
            child: Text(projects.first.title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: c ? 18 : 24)),
          ),
          Row(
            children: [
              for (final proj in projects.skip(1).take(2))
                Expanded(
                  child: Container(
                    height: c ? 60 : 72,
                    color: const Color(0xFF0F172A),
                    padding: EdgeInsets.all(c ? 8 : 10),
                    child: Text(proj.title, style: TextStyle(color: _yellow, fontWeight: FontWeight.bold, fontSize: c ? 10 : 12)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
