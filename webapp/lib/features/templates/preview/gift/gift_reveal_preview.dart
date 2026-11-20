import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:webapp/core/services/image_asset_service.dart';
import 'package:webapp/features/templates/preview/layouts/site_layout_blocks.dart';
import 'package:webapp/features/templates/preview/layout_theme.dart';
import 'package:webapp/features/website/domain/entities/website_document.dart';

/// Gift reveal preview with countdown, sequenced messages, music, and animation.
class GiftRevealPreview extends StatefulWidget {
  const GiftRevealPreview({
    super.key,
    required this.document,
    required this.compact,
    required this.mobileLayout,
    this.layoutVariant = 1,
  });

  final WebsiteDocument document;
  final bool compact;
  final bool mobileLayout;
  final int layoutVariant;

  @override
  State<GiftRevealPreview> createState() => _GiftRevealPreviewState();
}

class _GiftRevealPreviewState extends State<GiftRevealPreview> with TickerProviderStateMixin {
  late AnimationController _anim;
  Timer? _countdownTimer;
  int _secondsLeft = 0;
  int _visibleMessages = 0;
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _startSequence();
  }

  @override
  void didUpdateWidget(GiftRevealPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.document != widget.document) {
      _countdownTimer?.cancel();
      _visibleMessages = 0;
      _revealed = false;
      _startSequence();
    }
  }

  void _startSequence() {
    final secondary = widget.document.blockByContentType(2)?.contentData ?? {};
    _secondsLeft = (secondary['countdownSeconds'] as num?)?.toInt() ?? 10;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          _revealed = true;
          timer.cancel();
        }
      });
    });

    final messages = (secondary['messages'] as List?)?.whereType<Map>().toList() ?? [];
    for (var i = 0; i < messages.length; i++) {
      final delay = (messages[i]['delayMs'] as num?)?.toInt() ?? i * 1000;
      Future<void>.delayed(Duration(milliseconds: delay), () {
        if (mounted) setState(() => _visibleMessages = math.max(_visibleMessages, i + 1));
      });
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = widget.document.blockByContentType(1)?.contentData ?? {};
    final secondary = widget.document.blockByContentType(2)?.contentData ?? {};
    final tertiary = widget.document.blockByContentType(3)?.contentData ?? {};
    final theme = LayoutTheme.fromContent(primary);
    final animation = secondary['animation'] as String? ?? 'confetti';
    final musicUrl = secondary['musicUrl'] as String? ?? '';
    final messages = (secondary['messages'] as List?)?.whereType<Map>().toList() ?? [];
    final revealImages = (primary['revealImages'] as List?)?.map((e) => e.toString()).toList() ?? const [];

    return ColoredBox(
      color: theme.background,
      child: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              SiteNavBar(theme: theme, title: primary['title'] as String? ?? widget.document.name, compact: widget.compact, mobileLayout: widget.mobileLayout),
              ..._layoutBody(primary, secondary, tertiary, theme, animation, musicUrl, messages, revealImages),
              SiteFooter(theme: theme, compact: widget.compact, phone: '', email: '', title: widget.document.name),
            ],
          ),
          if (_revealed && (animation == 'confetti' || animation == 'fireworks' || animation == 'sparkle')) _ConfettiOverlay(controller: _anim),
          if (_revealed && (animation == 'heartBurst' || animation == 'balloon')) _HeartOverlay(controller: _anim),
        ],
      ),
    );
  }

  List<Widget> _layoutBody(
    Map<String, dynamic> primary,
    Map<String, dynamic> secondary,
    Map<String, dynamic> tertiary,
    LayoutTheme theme,
    String animation,
    String musicUrl,
    List<Map<dynamic, dynamic>> messages,
    List<String> revealImages,
  ) {
    final v = widget.layoutVariant;
    final pad = theme.pad(widget.compact);
    final title = primary['title'] as String? ?? widget.document.name;
    final cover = ImageAssetService.buildImage(
      path: primary['coverImage'] as String?,
      width: double.infinity,
      height: widget.compact ? 160 : 200,
      borderRadius: BorderRadius.circular(theme.radius),
    );

    final exclusive = _exclusiveLayout(
      variant: v,
      pad: pad,
      title: title,
      cover: cover,
      theme: theme,
      musicUrl: musicUrl,
      messages: messages,
      revealImages: revealImages,
      tertiary: tertiary,
    );
    if (exclusive != null) return exclusive;

    if (v % 4 == 0) {
      return [
        cover,
        Padding(padding: pad, child: Column(children: [_countdown(theme), ..._messages(messages, theme), ..._finale(tertiary, theme), if (musicUrl.isNotEmpty) _music(musicUrl, theme)])),
      ];
    }
    if (v % 4 == 1) {
      return [
        Padding(
          padding: pad,
          child: Column(
            children: [
              Text(title, textAlign: TextAlign.center, style: theme.heading(widget.compact, size: 30)),
              SizedBox(height: widget.compact ? 10 : 12),
              cover,
              SizedBox(height: widget.compact ? 12 : 16),
              _countdown(theme),
              ..._messages(messages, theme),
              ..._finale(tertiary, theme),
              if (musicUrl.isNotEmpty) _music(musicUrl, theme),
              if (revealImages.isNotEmpty) _revealStrip(revealImages, theme),
            ],
          ),
        ),
      ];
    }
    if (v % 4 == 2 && !widget.mobileLayout) {
      return [
        Padding(
          padding: pad,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: theme.heading(widget.compact, size: 26)), SizedBox(height: 10), _countdown(theme), ..._messages(messages, theme), ..._finale(tertiary, theme)])),
              SizedBox(width: 12),
              Expanded(child: Column(children: [cover, if (revealImages.isNotEmpty) _revealStrip(revealImages, theme), if (musicUrl.isNotEmpty) _music(musicUrl, theme)])),
            ],
          ),
        ),
      ];
    }
    return [
      Padding(
        padding: pad,
        child: Column(
          crossAxisAlignment: widget.mobileLayout ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.heading(widget.compact, size: 28)),
            if (musicUrl.isNotEmpty) _music(musicUrl, theme),
            SizedBox(height: widget.compact ? 10 : 14),
            cover,
            if (revealImages.isNotEmpty) _revealStrip(revealImages, theme),
            SizedBox(height: widget.compact ? 12 : 16),
            _countdown(theme),
            ..._messages(messages, theme),
            ..._finale(tertiary, theme),
          ],
        ),
      ),
    ];
  }

  List<Widget>? _exclusiveLayout({
    required int variant,
    required EdgeInsets pad,
    required String title,
    required Widget cover,
    required LayoutTheme theme,
    required String musicUrl,
    required List<Map<dynamic, dynamic>> messages,
    required List<String> revealImages,
    required Map<String, dynamic> tertiary,
  }) {
    if (variant < 2 || variant > 6) return null;
    final subname = widget.document.subname;
    final story = <Widget>[
      _countdown(theme),
      ..._messages(messages, theme),
      ..._finale(tertiary, theme),
      if (musicUrl.isNotEmpty) _music(musicUrl, theme),
      if (revealImages.isNotEmpty) _revealStrip(revealImages, theme),
    ];

    switch (variant) {
      case 2:
        return [
          Container(
            width: double.infinity,
            padding: pad.copyWith(top: pad.top + (widget.compact ? 12 : 20), bottom: pad.bottom + 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [theme.primary, theme.secondary],
              ),
            ),
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.heading(widget.compact, size: 30).copyWith(color: Colors.white),
                ),
                if (subname.isNotEmpty) ...[
                  SizedBox(height: widget.compact ? 6 : 8),
                  Text(
                    subname,
                    textAlign: TextAlign.center,
                    style: theme.body(widget.compact).copyWith(color: Colors.white70),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: pad,
            child: Column(children: [cover, SizedBox(height: widget.compact ? 14 : 18), ...story]),
          ),
        ];
      case 3:
        return [
          Padding(
            padding: pad,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A PRIVATE NOTE',
                  style: theme.body(widget.compact, size: 11).copyWith(
                        color: theme.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.8,
                      ),
                ),
                SizedBox(height: widget.compact ? 8 : 10),
                Text(title, style: theme.heading(widget.compact, size: widget.compact ? 30 : 36)),
                Container(
                  height: 3,
                  width: 56,
                  margin: EdgeInsets.only(top: widget.compact ? 10 : 12),
                  color: theme.accent,
                ),
                SizedBox(height: widget.compact ? 16 : 20),
                cover,
                SizedBox(height: widget.compact ? 14 : 18),
                ...story,
              ],
            ),
          ),
        ];
      case 4:
        return [
          cover,
          Padding(
            padding: EdgeInsets.fromLTRB(pad.left, 0, pad.right, pad.bottom),
            child: Transform.translate(
              offset: Offset(0, widget.compact ? -28 : -36),
              child: Container(
                width: double.infinity,
                padding: pad,
                decoration: theme.cardDecoration(),
                child: Column(children: story),
              ),
            ),
          ),
        ];
      case 5:
        return [
          Padding(
            padding: pad,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(color: theme.primary, borderRadius: BorderRadius.circular(999)),
                  child: Text(
                    'FOR YOU',
                    style: theme.body(widget.compact, size: 11).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                  ),
                ),
                SizedBox(height: widget.compact ? 12 : 14),
                Text(title, textAlign: TextAlign.center, style: theme.heading(widget.compact, size: 30)),
                if (subname.isNotEmpty) ...[
                  SizedBox(height: widget.compact ? 6 : 8),
                  Text(subname, textAlign: TextAlign.center, style: theme.body(widget.compact).copyWith(color: theme.primary)),
                ],
                if (revealImages.isNotEmpty) _revealStrip(revealImages, theme),
                SizedBox(height: widget.compact ? 12 : 16),
                _countdown(theme),
                cover,
                ..._messages(messages, theme),
                ..._finale(tertiary, theme),
                if (musicUrl.isNotEmpty) _music(musicUrl, theme),
              ],
            ),
          ),
        ];
      default:
        return [
          Container(height: widget.compact ? 6 : 8, color: theme.primary),
          Padding(
            padding: pad,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.heading(widget.compact, size: widget.compact ? 28 : 34).copyWith(letterSpacing: -0.6),
                ),
                if (subname.isNotEmpty) ...[
                  SizedBox(height: widget.compact ? 6 : 8),
                  Text(subname, style: theme.body(widget.compact).copyWith(color: theme.primary, fontWeight: FontWeight.w600)),
                ],
                SizedBox(height: widget.compact ? 14 : 18),
                _countdown(theme),
                ..._messages(messages, theme),
                ..._finale(tertiary, theme),
                SizedBox(height: widget.compact ? 8 : 12),
                cover,
                if (musicUrl.isNotEmpty) _music(musicUrl, theme),
                if (revealImages.isNotEmpty) _revealStrip(revealImages, theme),
              ],
            ),
          ),
        ];
    }
  }

  Widget _countdown(LayoutTheme theme) {
    if (!_revealed) {
      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          margin: EdgeInsets.only(bottom: widget.compact ? 10 : 12),
          decoration: BoxDecoration(color: theme.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(theme.radius)),
          child: Text('Reveal in $_secondsLeft', style: theme.heading(widget.compact, size: 22).copyWith(color: theme.primary)),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  List<Widget> _finale(Map<String, dynamic> tertiary, LayoutTheme theme) {
    if (!_revealed) return const [];
    return [
      Text(tertiary['finalMessage'] as String? ?? 'Happy surprise!', textAlign: TextAlign.center, style: theme.heading(widget.compact, size: 22)),
      if (tertiary['ctaLabel'] != null) ...[
        SizedBox(height: widget.compact ? 10 : 14),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: theme.primary,
            child: Text(tertiary['ctaLabel'] as String, style: theme.body(widget.compact).copyWith(color: Colors.white)),
          ),
        ),
      ],
    ];
  }

  List<Widget> _messages(List<Map<dynamic, dynamic>> messages, LayoutTheme theme) {
    return [
      for (var i = 0; i < _visibleMessages && i < messages.length; i++)
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: widget.compact ? 8 : 10),
          padding: EdgeInsets.all(widget.compact ? 12 : 14),
          decoration: theme.cardDecoration(),
          child: Text(messages[i]['text']?.toString() ?? '', style: theme.body(widget.compact)),
        ),
    ];
  }

  Widget _music(String musicUrl, LayoutTheme theme) {
    return Padding(
      padding: EdgeInsets.only(bottom: widget.compact ? 8 : 10),
      child: Row(
        children: [
          Icon(Icons.music_note_rounded, size: widget.compact ? 16 : 18, color: theme.primary),
          SizedBox(width: widget.compact ? 6 : 8),
          Expanded(child: Text(musicUrl, style: theme.body(widget.compact, size: 11), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _revealStrip(List<String> revealImages, LayoutTheme theme) {
    return Padding(
      padding: EdgeInsets.only(top: widget.compact ? 10 : 12),
      child: SizedBox(
        height: widget.compact ? 72 : 88,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: revealImages.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) => ImageAssetService.buildImage(
            path: revealImages[index],
            width: widget.compact ? 72 : 88,
            height: widget.compact ? 72 : 88,
            borderRadius: BorderRadius.circular(theme.radius * 0.6),
          ),
        ),
      ),
    );
  }
}

class _ConfettiOverlay extends StatelessWidget {
  const _ConfettiOverlay({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _ConfettiPainter(controller.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.t);
  final double t;
  final _random = math.Random(7);

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < 40; i++) {
      final paint = Paint()..color = Colors.primaries[i % Colors.primaries.length].withValues(alpha: 0.8);
      final x = (_random.nextDouble() * size.width + t * 120 + i * 17) % size.width;
      final y = (_random.nextDouble() * size.height * 0.6 + t * 200 + i * 23) % (size.height * 0.7);
      canvas.drawRect(Rect.fromCenter(center: Offset(x, y), width: 6, height: 10), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => oldDelegate.t != t;
}

class _HeartOverlay extends StatelessWidget {
  const _HeartOverlay({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return Center(
            child: Opacity(
              opacity: 0.25 + (math.sin(controller.value * math.pi * 2) * 0.15),
              child: Icon(Icons.favorite, size: 120, color: Colors.pink.shade300),
            ),
          );
        },
      ),
    );
  }
}
