import 'package:flutter/material.dart';
import 'package:webapp/features/templates/preview/layout_theme.dart';
import 'package:webapp/features/templates/preview/shared/site_image.dart';

/// Site navigation — 22 distinct styles driven by [LayoutTheme.navStyle].
class SiteNavBar extends StatelessWidget {
  const SiteNavBar({
    super.key,
    required this.theme,
    required this.title,
    required this.compact,
    required this.mobileLayout,
    this.logo,
  });

  final LayoutTheme theme;
  final String title;
  final bool compact;
  final bool mobileLayout;
  final String? logo;

  static const _links = ['Home', 'About', 'Work', 'Contact'];

  @override
  Widget build(BuildContext context) {
    return switch (theme.navStyle) {
      'sidebar' when !mobileLayout => _sidebar(),
      'bottom' => _bottom(),
      'pill' => _pill(),
      'underline' => _underline(),
      'block' => _block(),
      'floating' => _floating(),
      'elegant' => _elegant(),
      'terminal' => _terminal(),
      'minimal' => _minimal(),
      'tabs' => _tabs(),
      'segmented' => _segmented(),
      'drawer' => _drawerHint(),
      'icon' => _iconRow(),
      'wide' => _wide(),
      'sticky' => _sticky(),
      'overlay' => _overlay(),
      _ => _top(),
    };
  }

  Widget _top() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16, vertical: compact ? 10 : 12),
      color: theme.surface,
      child: Row(
        children: [
          if (logo != null) ...[
            SiteImage(path: logo, width: compact ? 28 : 32, height: compact ? 28 : 32, borderRadius: 6),
            SizedBox(width: compact ? 8 : 10),
          ],
          Expanded(child: Text(title, style: theme.heading(compact, size: 16))),
          if (!mobileLayout) ...[
            for (final link in _links)
              Padding(
                padding: EdgeInsets.only(left: compact ? 10 : 14),
                child: Text(link, style: theme.body(compact, size: 12)),
              ),
          ],
        ],
      ),
    );
  }

  Widget _sticky() => Material(elevation: 2, color: theme.surface, child: _top());

  Widget _sidebar() {
    return Container(
      width: 72,
      color: theme.secondary,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Icon(Icons.home_outlined, color: theme.accent, size: compact ? 20 : 22),
          const Spacer(),
          for (final _ in _links)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(width: 6, height: 6, decoration: BoxDecoration(color: theme.accent, shape: BoxShape.circle)),
            ),
        ],
      ),
    );
  }

  Widget _bottom() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: compact ? 8 : 10),
      decoration: BoxDecoration(color: theme.surface, border: Border(top: BorderSide(color: theme.text.withValues(alpha: 0.1)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [for (final _ in _links.take(4)) Icon(Icons.circle_outlined, size: compact ? 18 : 20, color: theme.primary)],
      ),
    );
  }

  Widget _pill() {
    return Padding(
      padding: EdgeInsets.all(compact ? 10 : 12),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16, vertical: compact ? 8 : 10),
          decoration: BoxDecoration(color: theme.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < _links.length; i++)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 8),
                  child: Text(_links[i], style: theme.body(compact, size: 11).copyWith(color: i == 0 ? theme.primary : null, fontWeight: i == 0 ? FontWeight.w700 : null)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _underline() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(compact ? 12 : 16, compact ? 10 : 12, compact ? 12 : 16, 0),
          child: Row(
            children: [
              Expanded(child: Text(title, style: theme.heading(compact, size: 18))),
            ],
          ),
        ),
        SizedBox(
          height: compact ? 36 : 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16),
            itemCount: _links.length,
            separatorBuilder: (_, __) => SizedBox(width: compact ? 16 : 20),
            itemBuilder: (context, i) => Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(_links[i], style: theme.body(compact, size: 12)),
                Container(height: 2, width: 32, margin: const EdgeInsets.only(top: 6), color: i == 0 ? theme.primary : Colors.transparent),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _block() {
    return Container(
      width: double.infinity,
      color: theme.secondary,
      padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16, vertical: compact ? 10 : 12),
      child: Text(title.toUpperCase(), style: theme.heading(compact, size: 14).copyWith(color: theme.accent, letterSpacing: 2)),
    );
  }

  Widget _floating() {
    return Padding(
      padding: EdgeInsets.all(compact ? 10 : 12),
      child: Align(
        alignment: Alignment.topRight,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12, vertical: compact ? 8 : 10),
          decoration: BoxDecoration(color: theme.surface, borderRadius: BorderRadius.circular(theme.radius), boxShadow: [BoxShadow(color: theme.secondary.withValues(alpha: 0.12), blurRadius: 12)]),
          child: Text('Menu', style: theme.body(compact, size: 12)),
        ),
      ),
    );
  }

  Widget _elegant() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 24, vertical: compact ? 14 : 18),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: theme.primary.withValues(alpha: 0.25)))),
      child: Center(child: Text(title, style: theme.heading(compact, size: 20).copyWith(letterSpacing: 4, fontWeight: FontWeight.w300))),
    );
  }

  Widget _terminal() {
    return Container(
      color: const Color(0xFF0A0A0F),
      padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16, vertical: compact ? 8 : 10),
      child: Row(
        children: [
          Text('>', style: TextStyle(color: theme.primary, fontFamily: 'monospace', fontSize: compact ? 14 : 16)),
          SizedBox(width: compact ? 6 : 8),
          Expanded(child: Text('$title.exe', style: TextStyle(color: theme.accent, fontFamily: 'monospace', fontSize: compact ? 12 : 13))),
        ],
      ),
    );
  }

  Widget _minimal() {
    return Padding(
      padding: EdgeInsets.all(compact ? 12 : 16),
      child: Align(alignment: Alignment.centerLeft, child: Text(title, style: theme.heading(compact, size: 14))),
    );
  }

  Widget _tabs() {
    return Container(
      color: theme.surface,
      child: Row(
        children: [
          for (var i = 0; i < 3; i++)
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: compact ? 10 : 12),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: i == 0 ? theme.primary : Colors.transparent, width: 2)),
                ),
                alignment: Alignment.center,
                child: Text(_links[i], style: theme.body(compact, size: 11)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _segmented() {
    return Padding(
      padding: EdgeInsets.all(compact ? 10 : 12),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: theme.surface, borderRadius: BorderRadius.circular(theme.radius)),
        child: Row(
          children: [
            for (var i = 0; i < 3; i++)
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: compact ? 8 : 10),
                  decoration: BoxDecoration(
                    color: i == 0 ? theme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(theme.radius * 0.7),
                  ),
                  alignment: Alignment.center,
                  child: Text(_links[i], style: theme.body(compact, size: 10).copyWith(color: i == 0 ? Colors.white : null)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _drawerHint() => Padding(
        padding: EdgeInsets.all(compact ? 12 : 16),
        child: Row(children: [Icon(Icons.menu, color: theme.primary, size: compact ? 22 : 24), SizedBox(width: compact ? 8 : 10), Text(title, style: theme.heading(compact, size: 16))]),
      );

  Widget _iconRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16, vertical: compact ? 10 : 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: theme.heading(compact, size: 14)),
          Row(children: [for (final icon in [Icons.home_outlined, Icons.search, Icons.person_outline]) Icon(icon, size: compact ? 18 : 20, color: theme.primary)]),
        ],
      ),
    );
  }

  Widget _wide() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 32, vertical: compact ? 14 : 18),
      color: theme.primary.withValues(alpha: 0.08),
      child: Row(
        children: [
          Expanded(child: Text(title, style: theme.heading(compact, size: 22))),
          if (!mobileLayout) Text('Explore', style: theme.body(compact).copyWith(color: theme.primary)),
        ],
      ),
    );
  }

  Widget _overlay() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16, vertical: compact ? 10 : 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [theme.secondary.withValues(alpha: 0.85), Colors.transparent]),
      ),
      child: Text(title, style: theme.heading(compact, size: 18).copyWith(color: Colors.white)),
    );
  }
}

/// Hero section — driven by [LayoutTheme.heroStyle] (22 unique structures).
class SiteHero extends StatelessWidget {
  const SiteHero({
    super.key,
    required this.theme,
    required this.title,
    required this.subtitle,
    required this.compact,
    required this.mobileLayout,
    this.logo,
    this.description,
  });

  final LayoutTheme theme;
  final String title;
  final String subtitle;
  final bool compact;
  final bool mobileLayout;
  final String? logo;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return switch (theme.heroStyle) {
      'center' => _center(),
      'overlap' => _overlap(),
      'fullBleed' => _fullBleed(),
      'card' => _card(),
      'splitVertical' => _splitVertical(),
      'stacked' => _stacked(),
      'curved' => _curved(),
      'marble' => _marble(),
      'neon' => _neon(),
      'monochromeSplit' => _monoSplit(),
      'ribbon' => _ribbon(),
      'inset' => _inset(),
      'dual' => _dual(),
      'compact' => _compact(),
      'wide' => _wide(),
      'pill' => _pill(),
      'shadow' => _shadow(),
      'underline' => _underline(),
      'bold' => _bold(),
      'soft' => _soft(),
      'edge' => _edge(),
      _ => _left(),
    };
  }

  EdgeInsets get _pad => theme.pad(compact);

  Widget _left() {
    return Padding(
      padding: _pad,
      child: Row(
        children: [
          Expanded(child: _textColumn(CrossAxisAlignment.start, TextAlign.start)),
          if (logo != null && !mobileLayout) SiteImage(path: logo, width: compact ? 80 : 100, height: compact ? 80 : 100, borderRadius: theme.radius),
        ],
      ),
    );
  }

  Widget _center() {
    return Padding(
      padding: _pad,
      child: Column(
        children: [
          if (logo != null) SiteImage(path: logo, width: compact ? 64 : 80, height: compact ? 64 : 80),
          if (logo != null) SizedBox(height: compact ? 10 : 12),
          _textColumn(CrossAxisAlignment.center, TextAlign.center),
        ],
      ),
    );
  }

  Widget _overlap() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(height: compact ? 120 : 160, width: double.infinity, color: theme.primary.withValues(alpha: 0.15)),
        Positioned(left: _pad.left, right: _pad.right, bottom: compact ? -24 : -32, child: Container(padding: _pad, decoration: theme.cardDecoration(), child: _textColumn(CrossAxisAlignment.start, TextAlign.start))),
      ],
    );
  }

  Widget _fullBleed() {
    return Container(
      width: double.infinity,
      padding: _pad.copyWith(top: _pad.top + (compact ? 16 : 24), bottom: _pad.bottom + 12),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.primary, theme.secondary])),
      child: _textColumn(mobileLayout ? CrossAxisAlignment.center : CrossAxisAlignment.start, mobileLayout ? TextAlign.center : TextAlign.start, light: true),
    );
  }

  Widget _card() {
    return Padding(
      padding: _pad,
      child: Container(width: double.infinity, padding: _pad, decoration: theme.cardDecoration(), child: _textColumn(CrossAxisAlignment.start, TextAlign.start)),
    );
  }

  Widget _splitVertical() {
    return Column(
      children: [
        Container(width: double.infinity, height: compact ? 100 : 140, color: theme.primary.withValues(alpha: 0.2)),
        Padding(padding: _pad, child: _textColumn(CrossAxisAlignment.start, TextAlign.start)),
      ],
    );
  }

  Widget _stacked() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(padding: _pad, color: theme.secondary, child: Text(title.toUpperCase(), style: theme.heading(compact, size: 24).copyWith(color: theme.accent))),
        Padding(padding: _pad, child: Text(subtitle, style: theme.body(compact, size: 14))),
      ],
    );
  }

  Widget _curved() {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(compact ? 24 : 32)),
      child: Container(width: double.infinity, padding: _pad, color: theme.primary.withValues(alpha: 0.12), child: _textColumn(CrossAxisAlignment.center, TextAlign.center)),
    );
  }

  Widget _marble() {
    return Container(
      width: double.infinity,
      padding: _pad,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [theme.background, theme.surface]),
        border: Border(bottom: BorderSide(color: theme.primary.withValues(alpha: 0.35))),
      ),
      child: Center(child: Text(title, style: theme.heading(compact, size: 28).copyWith(letterSpacing: 6, fontWeight: FontWeight.w300))),
    );
  }

  Widget _neon() {
    return Container(
      width: double.infinity,
      padding: _pad,
      color: theme.background,
      child: Text(title, style: theme.heading(compact, size: 30).copyWith(color: theme.primary, shadows: [Shadow(color: theme.primary.withValues(alpha: 0.8), blurRadius: 16)])),
    );
  }

  Widget _monoSplit() {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(child: Container(color: theme.secondary, padding: _pad, child: Text(title, style: theme.heading(compact, size: 22).copyWith(color: Colors.white)))),
          Expanded(child: Container(color: theme.background, padding: _pad, child: Text(subtitle, style: theme.body(compact)))),
        ],
      ),
    );
  }

  Widget _ribbon() {
    return Column(
      children: [
        Container(width: double.infinity, padding: EdgeInsets.symmetric(vertical: compact ? 6 : 8), color: theme.accent, child: Center(child: Text(description ?? subtitle, style: theme.body(compact, size: 10).copyWith(color: theme.secondary)))),
        Padding(padding: _pad, child: _textColumn(CrossAxisAlignment.center, TextAlign.center)),
      ],
    );
  }

  Widget _inset() {
    return Padding(
      padding: _pad,
      child: Container(
        padding: _pad,
        decoration: BoxDecoration(color: theme.surface, borderRadius: BorderRadius.circular(theme.radius), border: Border.all(color: theme.primary.withValues(alpha: 0.2))),
        child: _textColumn(CrossAxisAlignment.start, TextAlign.start),
      ),
    );
  }

  Widget _dual() {
    return Padding(
      padding: _pad,
      child: Row(
        children: [
          Expanded(child: Text(title, style: theme.heading(compact, size: 26))),
          Container(width: 1, height: compact ? 48 : 56, color: theme.primary),
          Expanded(child: Padding(padding: EdgeInsets.only(left: compact ? 12 : 16), child: Text(subtitle, style: theme.body(compact)))),
        ],
      ),
    );
  }

  Widget _compact() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _pad.left, vertical: compact ? 8 : 10),
      child: Row(children: [Expanded(child: Text(title, style: theme.heading(compact, size: 18))), Text(subtitle, style: theme.body(compact, size: 11))]),
    );
  }

  Widget _wide() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: compact ? 20 : 32, vertical: compact ? 24 : 32),
      child: Text(title, style: theme.heading(compact, size: compact ? 34 : 42)),
    );
  }

  Widget _pill() {
    return Padding(
      padding: _pad,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 14, vertical: compact ? 6 : 8), decoration: BoxDecoration(color: theme.primary, borderRadius: BorderRadius.circular(999)), child: Text(subtitle, style: theme.body(compact, size: 11).copyWith(color: Colors.white))),
          SizedBox(height: compact ? 10 : 12),
          Text(title, style: theme.heading(compact, size: 28)),
        ],
      ),
    );
  }

  Widget _shadow() {
    return Padding(
      padding: _pad,
      child: Container(
        padding: _pad,
        decoration: BoxDecoration(color: theme.surface, borderRadius: BorderRadius.circular(theme.radius), boxShadow: [BoxShadow(color: theme.secondary.withValues(alpha: 0.18), blurRadius: 24, offset: const Offset(0, 12))]),
        child: _textColumn(CrossAxisAlignment.start, TextAlign.start),
      ),
    );
  }

  Widget _underline() {
    return Padding(
      padding: _pad,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.heading(compact, size: 32)),
          Container(height: 4, width: compact ? 48 : 64, margin: EdgeInsets.only(top: compact ? 8 : 10), color: theme.primary),
          SizedBox(height: compact ? 8 : 10),
          Text(subtitle, style: theme.body(compact)),
        ],
      ),
    );
  }

  Widget _bold() {
    return Container(
      width: double.infinity,
      padding: _pad,
      color: theme.primary,
      child: Text(title, style: theme.heading(compact, size: 32).copyWith(color: Colors.white)),
    );
  }

  Widget _soft() {
    return Container(
      width: double.infinity,
      margin: _pad,
      padding: _pad,
      decoration: BoxDecoration(color: theme.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(theme.radius * 2)),
      child: _textColumn(CrossAxisAlignment.center, TextAlign.center),
    );
  }

  Widget _edge() {
    return Row(
      children: [
        Container(width: compact ? 6 : 8, height: compact ? 100 : 120, color: theme.primary),
        Expanded(child: Padding(padding: _pad, child: _textColumn(CrossAxisAlignment.start, TextAlign.start))),
      ],
    );
  }

  Widget _textColumn(CrossAxisAlignment align, TextAlign textAlign, {bool light = false}) {
    final titleStyle = theme.heading(compact, size: 28).copyWith(color: light ? Colors.white : null);
    final subStyle = theme.body(compact).copyWith(color: light ? Colors.white70 : theme.primary);
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(title, textAlign: textAlign, style: titleStyle),
        SizedBox(height: compact ? 6 : 8),
        Text(subtitle, textAlign: textAlign, style: subStyle),
      ],
    );
  }
}

/// Footer — driven by [LayoutTheme.footerStyle].
class SiteFooter extends StatelessWidget {
  const SiteFooter({
    super.key,
    required this.theme,
    required this.compact,
    required this.phone,
    required this.email,
    required this.title,
  });

  final LayoutTheme theme;
  final bool compact;
  final String phone;
  final String email;
  final String title;

  @override
  Widget build(BuildContext context) {
    if (phone.isEmpty && email.isEmpty) return const SizedBox.shrink();
    return switch (theme.footerStyle) {
      'columns' => _columns(),
      'dark' => _solid(theme.secondary),
      'compact' => _compact(),
      'gradient' => _gradient(),
      'wide' => _wide(),
      'brutal' => _brutal(),
      'nature' => _nature(),
      'premium' => _premium(),
      'grid' => _grid(),
      'mono' => _mono(),
      'split' => _split(),
      'inline' => _inline(),
      _ => _minimal(),
    };
  }

  Widget _minimal() {
    return Container(
      width: double.infinity,
      padding: theme.pad(compact),
      color: theme.surface,
      child: Text(phone.isNotEmpty ? phone : email, style: theme.body(compact, size: 12)),
    );
  }

  Widget _columns() {
    return Container(
      width: double.infinity,
      padding: theme.pad(compact),
      color: theme.surface,
      child: Row(
        children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: theme.heading(compact, size: 14)), Text('Contact', style: theme.body(compact, size: 10))])),
          Expanded(child: Text(phone, style: theme.body(compact, size: 12))),
          if (email.isNotEmpty) Expanded(child: Text(email, style: theme.body(compact, size: 12))),
        ],
      ),
    );
  }

  Widget _solid(Color color) {
    return Container(
      width: double.infinity,
      padding: theme.pad(compact),
      color: color,
      child: Text(phone, style: theme.body(compact).copyWith(color: Colors.white)),
    );
  }

  Widget _compact() => Padding(padding: EdgeInsets.all(compact ? 10 : 12), child: Center(child: Text(phone, style: theme.body(compact, size: 11))));

  Widget _gradient() {
    return Container(
      width: double.infinity,
      padding: theme.pad(compact),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.primary, theme.accent])),
      child: Text(phone, style: theme.body(compact).copyWith(color: Colors.white)),
    );
  }

  Widget _wide() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: compact ? 20 : 32, vertical: compact ? 16 : 20),
      color: theme.secondary,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: theme.body(compact).copyWith(color: Colors.white70)), Text(phone, style: theme.body(compact).copyWith(color: Colors.white))]),
    );
  }

  Widget _brutal() {
    return Container(
      width: double.infinity,
      padding: theme.pad(compact),
      decoration: BoxDecoration(color: theme.secondary, border: Border(top: BorderSide(color: theme.accent, width: 4))),
      child: Text(phone.toUpperCase(), style: theme.heading(compact, size: 14).copyWith(color: theme.accent)),
    );
  }

  Widget _nature() {
    return Container(
      width: double.infinity,
      padding: theme.pad(compact),
      color: theme.primary.withValues(alpha: 0.12),
      child: Row(children: [Icon(Icons.eco_outlined, color: theme.primary, size: compact ? 18 : 20), SizedBox(width: 8), Text(phone, style: theme.body(compact))]),
    );
  }

  Widget _premium() {
    return Container(
      width: double.infinity,
      padding: theme.pad(compact),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: theme.primary.withValues(alpha: 0.35)))),
      child: Center(child: Text('$title · $phone', style: theme.body(compact, size: 11).copyWith(letterSpacing: 2))),
    );
  }

  Widget _grid() {
    return Container(
      width: double.infinity,
      padding: theme.pad(compact),
      color: const Color(0xFF0A0A0F),
      child: Wrap(spacing: 12, runSpacing: 8, children: [Text(phone, style: TextStyle(color: theme.primary, fontFamily: 'monospace', fontSize: compact ? 11 : 12)), if (email.isNotEmpty) Text(email, style: TextStyle(color: theme.accent, fontFamily: 'monospace', fontSize: compact ? 11 : 12))]),
    );
  }

  Widget _mono() {
    return Container(width: double.infinity, padding: theme.pad(compact), color: theme.background, child: Text(phone, style: theme.body(compact).copyWith(color: Colors.white70)));
  }

  Widget _split() {
    return Row(
      children: [
        Expanded(child: Container(padding: theme.pad(compact), color: theme.primary, child: Text(phone, style: theme.body(compact).copyWith(color: Colors.white)))),
        Expanded(child: Container(padding: theme.pad(compact), color: theme.surface, child: Text(email, style: theme.body(compact)))),
      ],
    );
  }

  Widget _inline() {
    return Padding(
      padding: theme.pad(compact),
      child: Text('$phone${email.isNotEmpty ? ' · $email' : ''}', style: theme.body(compact, size: 11), textAlign: TextAlign.center),
    );
  }
}
