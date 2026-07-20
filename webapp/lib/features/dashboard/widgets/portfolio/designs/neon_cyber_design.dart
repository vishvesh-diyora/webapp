import 'package:flutter/material.dart';
import 'package:webapp/features/dashboard/models/category_template.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_avatar.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_helpers.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_motion.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_social_bar.dart';

/// 6 — Neon cyberpunk: grid lines, neon borders, terminal feel.
class NeonCyberDesign extends StatelessWidget {
  const NeonCyberDesign({
    super.key,
    required this.template,
    required this.compact,
    required this.mobileProfileLayout,
  });

  final CategoryTemplate template;
  final bool compact;
  final bool mobileProfileLayout;

  static const _cyan = Color(0xFF00F5FF);
  static const _pink = Color(0xFFFF006E);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF050510),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),
          buildAnimatedPortfolio(
            template: template,
            compact: compact,
            motion: PortfolioMotion.glitchSnap,
            profile: _hero,
            testimonials: _reviews,
            projects: _work,
          ),
        ],
      ),
    );
  }

  Widget _hero(bool c) {
    final p = PortfolioDesignHelpers.profile;
    final pad = c ? 16.0 : 24.0;
    final avatar = Container(
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: _cyan.withValues(alpha: 0.5), blurRadius: 20)],
      ),
      child: PortfolioFloatLoop(
        child: PortfolioAvatar(profile: p, size: c ? 100 : 130),
      ),
    );

    final text = Column(
      crossAxisAlignment: mobileProfileLayout ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text('// PROFILE', style: TextStyle(color: _pink, fontFamily: 'monospace', fontSize: c ? 9 : 10)),
        SizedBox(height: c ? 6 : 8),
        PortfolioNameBlock(
          name: p.name,
          accentColor: _cyan,
          nameColor: Colors.white,
          nameSize: c ? 24.0 : 32.0,
          align: mobileProfileLayout ? TextAlign.center : TextAlign.start,
        ),
        SizedBox(height: c ? 6 : 8),
        Text(
          p.title,
          textAlign: mobileProfileLayout ? TextAlign.center : TextAlign.start,
          style: TextStyle(color: _pink, fontFamily: 'monospace', fontSize: c ? 11 : 13),
        ),
        SizedBox(height: c ? 12 : 16),
        PortfolioSocialBar(links: p.socialLinks, compact: c, variant: SocialBarVariant.neon, centered: mobileProfileLayout),
      ],
    );

    return Container(
      margin: EdgeInsets.all(pad),
      padding: EdgeInsets.all(c ? 14 : 18),
      decoration: BoxDecoration(
        border: Border.all(color: _cyan.withValues(alpha: 0.6)),
        color: Colors.black.withValues(alpha: 0.6),
      ),
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
          Text('> TESTIMONIALS', style: TextStyle(color: _cyan, fontFamily: 'monospace', fontSize: c ? 10 : 11)),
          SizedBox(height: c ? 10 : 12),
          for (var i = 0; i < PortfolioDesignHelpers.testimonials.length; i++)
            PortfolioListReveal(
              index: i,
              compact: c,
              child: Container(
                margin: EdgeInsets.only(bottom: c ? 8 : 10),
                padding: EdgeInsets.all(c ? 10 : 12),
                decoration: BoxDecoration(
                  border: Border.all(color: _pink.withValues(alpha: 0.5)),
                  color: Colors.black54,
                ),
                child: Text(
                  PortfolioDesignHelpers.testimonials[i].quote,
                  style: TextStyle(color: Colors.white70, fontFamily: 'monospace', fontSize: c ? 9 : 11),
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
      child: Wrap(
        spacing: c ? 8 : 10,
        runSpacing: c ? 8 : 10,
        children: [
          for (var i = 0; i < PortfolioDesignHelpers.projects.length; i++)
            PortfolioListReveal(
              index: i,
              compact: c,
              child: Container(
                width: c ? 140 : 160,
                height: c ? 80 : 96,
                padding: EdgeInsets.all(c ? 8 : 10),
                decoration: BoxDecoration(
                  border: Border.all(color: i.isEven ? _cyan : _pink),
                  color: Colors.black45,
                ),
                child: Text(
                  PortfolioDesignHelpers.projects[i].title,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: c ? 10 : 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00F5FF).withValues(alpha: 0.06)
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 24) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
