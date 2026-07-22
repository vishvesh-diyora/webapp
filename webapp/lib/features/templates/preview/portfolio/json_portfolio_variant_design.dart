import 'package:flutter/material.dart';
import 'package:webapp/features/dashboard/models/portfolio_content.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_helpers.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_motion.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_social_bar.dart';
import 'package:webapp/features/templates/preview/layout_theme.dart';
import 'package:webapp/features/templates/preview/shared/site_image.dart';
import 'package:webapp/features/website/domain/entities/website_document.dart';

/// JSON-driven portfolio layouts for templateType 12–22 — each structurally unique.
class JsonPortfolioVariantDesign extends StatelessWidget {
  const JsonPortfolioVariantDesign({
    super.key,
    required this.document,
    required this.compact,
    required this.mobileProfileLayout,
    required this.theme,
  });

  final WebsiteDocument document;
  final bool compact;
  final bool mobileProfileLayout;
  final LayoutTheme theme;

  @override
  Widget build(BuildContext context) {
    final variant = document.templateType.clamp(12, 22);
    return ColoredBox(
      color: theme.background,
      child: buildAnimatedPortfolio(
        template: document,
        compact: compact,
        motion: _motion(theme.animation),
        profile: (c) => _layoutForVariant(variant, c),
        testimonials: (c) => _section(c, 'Testimonials', _testimonials(c)),
        projects: (c) => _section(c, 'Projects', _projects(c, variant)),
      ),
    );
  }

  Widget _layoutForVariant(int variant, bool c) {
    return switch (variant) {
      12 => _layoutCenteredAvatar(c),
      13 => _layoutSplitPhoto(c),
      14 => _layoutMinimalType(c),
      15 => _layoutProfileCard(c),
      16 => _layoutExperienceFirst(c),
      17 => _layoutSkillsGrid(c),
      18 => _layoutProjectMasonry(c),
      19 => _layoutGalleryFirst(c),
      20 => _layoutQuoteStack(c),
      21 => _layoutBoldBands(c),
      22 => _layoutMagazine(c),
      _ => _layoutCenteredAvatar(c),
    };
  }

  PortfolioMotion _motion(String name) => switch (name) {
        'slideLeft' => PortfolioMotion.slideLeft,
        'clipReveal' => PortfolioMotion.clipReveal,
        'glitchSnap' => PortfolioMotion.glitchSnap,
        'bounceSoft' => PortfolioMotion.bounceSoft,
        'brutalSnap' => PortfolioMotion.brutalSnap,
        'zenRise' => PortfolioMotion.zenRise,
        'luxuryFade' => PortfolioMotion.luxuryFade,
        _ => PortfolioMotion.fadeUp,
      };

  Map<String, dynamic> get _primary =>
      document.blockByContentType(1)?.contentData ?? const {};

  Map<String, dynamic> get _secondary =>
      document.blockByContentType(2)?.contentData ?? const {};

  PortfolioProfile get _p => PortfolioDesignHelpers.profile;

  Widget _layoutCenteredAvatar(bool c) {
    final pad = theme.pad(c);
    return Padding(
      padding: pad,
      child: Column(
        children: [
          SiteImage(path: _primary['profileImage'] as String?, width: c ? 96 : 120, height: c ? 96 : 120),
          SizedBox(height: c ? 10 : 14),
          Text(_p.name, textAlign: TextAlign.center, style: theme.heading(c, size: 30).copyWith(color: theme.primary)),
          Text(_p.title, textAlign: TextAlign.center, style: theme.body(c).copyWith(color: theme.accent)),
          SizedBox(height: c ? 8 : 12),
          Text(_p.bio, textAlign: TextAlign.center, style: theme.body(c)),
          SizedBox(height: c ? 12 : 16),
          PortfolioSocialBar(links: _p.socialLinks, compact: c, variant: SocialBarVariant.filled, centered: true, iconColor: Colors.white, borderColor: theme.primary),
        ],
      ),
    );
  }

  Widget _layoutSplitPhoto(bool c) {
    final pad = theme.pad(c);
    if (mobileProfileLayout) return _layoutCenteredAvatar(c);
    return Padding(
      padding: pad,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SiteImage(path: _primary['profileImage'] as String?, width: c ? 140 : 180, height: c ? 180 : 220, borderRadius: theme.radius),
          SizedBox(width: c ? 16 : 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_p.name, style: theme.heading(c, size: 32)),
                Text(_p.title, style: theme.body(c).copyWith(color: theme.primary)),
                SizedBox(height: c ? 8 : 12),
                Text(_p.bio, style: theme.body(c)),
                SizedBox(height: c ? 12 : 16),
                PortfolioSocialBar(links: _p.socialLinks, compact: c, variant: SocialBarVariant.outlined, iconColor: theme.primary, borderColor: theme.primary.withValues(alpha: 0.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _layoutMinimalType(bool c) {
    return Padding(
      padding: theme.pad(c),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_p.name.toUpperCase(), style: theme.body(c, size: 11).copyWith(letterSpacing: 4)),
          SizedBox(height: c ? 6 : 8),
          Text(_p.title, style: theme.heading(c, size: 36)),
          Container(width: 48, height: 3, margin: EdgeInsets.symmetric(vertical: c ? 10 : 14), color: theme.primary),
          Text(_p.bio, style: theme.body(c, size: 13)),
          SizedBox(height: c ? 14 : 18),
          PortfolioSocialBar(links: _p.socialLinks, compact: c, variant: SocialBarVariant.minimal, iconColor: theme.secondary),
        ],
      ),
    );
  }

  Widget _layoutProfileCard(bool c) {
    return Padding(
      padding: theme.pad(c),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(c ? 16 : 20),
        decoration: theme.cardDecoration(),
        child: Column(
          children: [
            SiteImage(path: _primary['profileImage'] as String?, width: c ? 72 : 88, height: c ? 72 : 88),
            SizedBox(height: c ? 10 : 12),
            Text(_p.name, style: theme.heading(c, size: 24)),
            Text(_p.title, style: theme.body(c).copyWith(color: theme.primary)),
            SizedBox(height: c ? 8 : 10),
            Text(_p.bio, textAlign: TextAlign.center, style: theme.body(c)),
            SizedBox(height: c ? 12 : 14),
            PortfolioSocialBar(links: _p.socialLinks, compact: c, variant: SocialBarVariant.luxury, centered: true, iconColor: theme.primary, borderColor: theme.primary),
          ],
        ),
      ),
    );
  }

  Widget _layoutExperienceFirst(bool c) {
    final experience = (_secondary['experience'] as List?)?.whereType<Map>().toList() ?? const [];
    return Padding(
      padding: theme.pad(c),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_p.name, style: theme.heading(c, size: 26)),
          Text(_p.title, style: theme.body(c).copyWith(color: theme.accent)),
          SizedBox(height: c ? 12 : 16),
          for (final item in experience.take(3))
            Padding(
              padding: EdgeInsets.only(bottom: c ? 10 : 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 4, height: 48, color: theme.primary),
                  SizedBox(width: c ? 10 : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['role']?.toString() ?? '', style: theme.heading(c, size: 14)),
                        Text('${item['company']} · ${item['period']}', style: theme.body(c, size: 11)),
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

  Widget _layoutSkillsGrid(bool c) {
    final skills = (_secondary['skills'] as List?)?.map((e) => e.toString()).toList() ?? const [];
    return Padding(
      padding: theme.pad(c),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_p.name, style: theme.heading(c, size: 28)),
          SizedBox(height: c ? 8 : 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final skill in skills)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: c ? 10 : 12, vertical: c ? 8 : 10),
                  decoration: BoxDecoration(
                    color: theme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(theme.radius),
                    border: Border.all(color: theme.primary.withValues(alpha: 0.25)),
                  ),
                  child: Text(skill, style: theme.body(c, size: 12)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _layoutProjectMasonry(bool c) {
    final projects = PortfolioDesignHelpers.projects;
    return Padding(
      padding: theme.pad(c),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_p.name, style: theme.heading(c, size: 24)),
          SizedBox(height: c ? 10 : 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: mobileProfileLayout ? 1 : 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.4,
            ),
            itemCount: projects.length.clamp(0, 4),
            itemBuilder: (context, index) {
              final project = projects[index];
              return Container(
                padding: EdgeInsets.all(c ? 10 : 12),
                decoration: theme.cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(project.title, style: theme.heading(c, size: 13)),
                    Text(project.category, style: theme.body(c, size: 10)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _layoutGalleryFirst(bool c) {
    final gallery = (document.blockByContentType(3)?.contentData['gallery'] as List?)?.whereType<Map>().toList() ?? const [];
    return Padding(
      padding: theme.pad(c),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: c ? 120 : 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: gallery.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = gallery[index];
                return SiteImage(path: item['image'] as String?, width: c ? 120 : 160, height: c ? 120 : 160, borderRadius: theme.radius);
              },
            ),
          ),
          SizedBox(height: c ? 10 : 12),
          Text(_p.name, style: theme.heading(c, size: 26)),
          Text(_p.title, style: theme.body(c).copyWith(color: theme.primary)),
        ],
      ),
    );
  }

  Widget _layoutQuoteStack(bool c) {
    final testimonials = PortfolioDesignHelpers.testimonials;
    return Padding(
      padding: theme.pad(c),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_p.name, style: theme.heading(c, size: 22)),
          for (final t in testimonials.take(2))
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: c ? 10 : 12),
              padding: EdgeInsets.all(c ? 14 : 16),
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: theme.primary, width: 4)),
                color: theme.primary.withValues(alpha: 0.06),
              ),
              child: Text('“${t.quote}”', style: theme.body(c).copyWith(fontStyle: FontStyle.italic)),
            ),
        ],
      ),
    );
  }

  Widget _layoutBoldBands(bool c) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: theme.pad(c),
          color: theme.primary,
          child: Text(_p.name, style: theme.heading(c, size: 28).copyWith(color: Colors.white)),
        ),
        Container(
          width: double.infinity,
          padding: theme.pad(c),
          color: theme.secondary,
          child: Text(_p.title, style: theme.body(c).copyWith(color: Colors.white70)),
        ),
        Padding(
          padding: theme.pad(c),
          child: Text(_p.bio, style: theme.body(c)),
        ),
      ],
    );
  }

  Widget _layoutMagazine(bool c) {
    if (mobileProfileLayout) return _layoutSplitPhoto(c);
    return Padding(
      padding: theme.pad(c),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_p.name, style: theme.heading(c, size: 34)),
                SizedBox(height: c ? 8 : 10),
                Text(_secondary['about'] as String? ?? _p.bio, style: theme.body(c)),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                SiteImage(path: _primary['profileImage'] as String?, width: double.infinity, height: c ? 140 : 180, borderRadius: theme.radius),
                SizedBox(height: c ? 8 : 10),
                if (_primary['resumeUrl'] != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    color: theme.accent,
                    alignment: Alignment.center,
                    child: Text('Resume', style: theme.body(c).copyWith(color: Colors.white)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(bool c, String label, Widget child) {
    return Padding(
      padding: theme.pad(c),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: theme.body(c, size: 10).copyWith(letterSpacing: 2)),
          SizedBox(height: c ? 8 : 12),
          child,
        ],
      ),
    );
  }

  Widget _testimonials(bool c) {
    return Column(
      children: [
        for (final item in PortfolioDesignHelpers.testimonials)
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: c ? 8 : 10),
            padding: EdgeInsets.all(c ? 12 : 14),
            decoration: theme.cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.quote, style: theme.body(c)),
                SizedBox(height: c ? 6 : 8),
                Text('— ${item.author}', style: theme.body(c, size: 11).copyWith(color: theme.primary)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _projects(bool c, int variant) {
    final raw = document.blockByContentType(3)?.contentData['projects'] as List? ?? const [];
    final projects = raw.whereType<Map>().toList();
    if (variant == 18) return const SizedBox.shrink();

    if (variant == 19) {
      return _galleryGrid(c);
    }

    return Column(
      children: [
        for (final project in projects)
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: c ? 8 : 10),
            padding: EdgeInsets.all(c ? 12 : 14),
            decoration: theme.cardDecoration(),
            child: Row(
              children: [
                if (project['image'] != null)
                  Padding(
                    padding: EdgeInsets.only(right: c ? 10 : 12),
                    child: SiteImage(path: project['image'] as String?, width: c ? 48 : 56, height: c ? 48 : 56, borderRadius: theme.radius * 0.5),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(project['title']?.toString() ?? '', style: theme.heading(c, size: 16)),
                      Text(project['category']?.toString() ?? '', style: theme.body(c, size: 11)),
                    ],
                  ),
                ),
                Text(project['year']?.toString() ?? '', style: theme.body(c, size: 11)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _galleryGrid(bool c) {
    final gallery = (document.blockByContentType(3)?.contentData['gallery'] as List?)?.whereType<Map>().toList() ?? const [];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: mobileProfileLayout ? 2 : 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: gallery.length,
      itemBuilder: (context, index) {
        final item = gallery[index];
        return SiteImage(path: item['image'] as String?, width: double.infinity, height: 80, borderRadius: theme.radius * 0.5);
      },
    );
  }
}
