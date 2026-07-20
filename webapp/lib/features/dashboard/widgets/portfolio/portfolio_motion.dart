import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:webapp/features/dashboard/models/category_template.dart';

/// Unique motion preset per portfolio template.
enum PortfolioMotion {
  fadeUp,
  slideLeft,
  scaleBounce,
  clipReveal,
  blurFloat,
  glitchSnap,
  bounceSoft,
  brutalSnap,
  zenRise,
  luxuryFade,
}

class PortfolioMotionLayer extends StatefulWidget {
  const PortfolioMotionLayer({
    super.key,
    required this.motion,
    required this.index,
    required this.child,
    this.compact = false,
  });

  final PortfolioMotion motion;
  final int index;
  final Widget child;
  final bool compact;

  @override
  State<PortfolioMotionLayer> createState() => _PortfolioMotionLayerState();
}

class _PortfolioMotionLayerState extends State<PortfolioMotionLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _t;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.compact ? 550 : 750),
    );
    _t = CurvedAnimation(parent: _c, curve: _curveFor(widget.motion));
    Future<void>.delayed(Duration(milliseconds: 120 * widget.index), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Curve _curveFor(PortfolioMotion m) => switch (m) {
        PortfolioMotion.brutalSnap || PortfolioMotion.glitchSnap => Curves.easeOutCubic,
        PortfolioMotion.bounceSoft || PortfolioMotion.scaleBounce => Curves.elasticOut,
        PortfolioMotion.luxuryFade => Curves.easeInOutCubic,
        _ => Curves.easeOutCubic,
      };

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      builder: (context, child) {
        final v = _t.value;
        return switch (widget.motion) {
          PortfolioMotion.fadeUp || PortfolioMotion.zenRise => Opacity(
              opacity: v,
              child: Transform.translate(
                offset: Offset(0, (1 - v) * (widget.compact ? 22 : 32)),
                child: child,
              ),
            ),
          PortfolioMotion.slideLeft => Opacity(
              opacity: v,
              child: Transform.translate(
                offset: Offset((1 - v) * -40, 0),
                child: child,
              ),
            ),
          PortfolioMotion.scaleBounce || PortfolioMotion.bounceSoft => Opacity(
              opacity: v.clamp(0.0, 1.0),
              child: Transform.scale(scale: 0.85 + (v * 0.15), child: child),
            ),
          PortfolioMotion.clipReveal => ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: v,
                child: Opacity(opacity: v, child: child),
              ),
            ),
          PortfolioMotion.blurFloat => Opacity(
              opacity: v,
              child: Transform.translate(
                offset: Offset(0, math.sin(v * math.pi) * -8),
                child: child,
              ),
            ),
          PortfolioMotion.glitchSnap => Opacity(
              opacity: v,
              child: Transform.translate(
                offset: Offset((1 - v) * (widget.index.isEven ? -18 : 18), 0),
                child: child,
              ),
            ),
          PortfolioMotion.brutalSnap => Opacity(
              opacity: v > 0.2 ? 1 : 0,
              child: Transform.translate(
                offset: Offset(0, (1 - v) * 48),
                child: child,
              ),
            ),
          PortfolioMotion.luxuryFade => Opacity(
              opacity: v,
              child: Transform.scale(scale: 0.96 + (v * 0.04), child: child),
            ),
        };
      },
      child: widget.child,
    );
  }
}

/// Gentle floating loop for memoji / hero visuals.
class PortfolioFloatLoop extends StatefulWidget {
  const PortfolioFloatLoop({super.key, required this.child, this.amplitude = 6});

  final Widget child;
  final double amplitude;

  @override
  State<PortfolioFloatLoop> createState() => _PortfolioFloatLoopState();
}

class _PortfolioFloatLoopState extends State<PortfolioFloatLoop>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, math.sin(_c.value * math.pi * 2) * widget.amplitude),
        child: child,
      ),
      child: widget.child,
    );
  }
}

/// Stagger item inside horizontal/vertical lists.
class PortfolioListReveal extends StatefulWidget {
  const PortfolioListReveal({
    super.key,
    required this.index,
    required this.child,
    this.compact = false,
  });

  final int index;
  final Widget child;
  final bool compact;

  @override
  State<PortfolioListReveal> createState() => _PortfolioListRevealState();
}

class _PortfolioListRevealState extends State<PortfolioListReveal>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.compact ? 400 : 550),
    );
    Future<void>.delayed(Duration(milliseconds: 80 * widget.index + 300), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _c, curve: Curves.easeOut),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic)),
        child: widget.child,
      ),
    );
  }
}

/// Builds animated sections from JSON block order.
Widget buildAnimatedPortfolio({
  required CategoryTemplate template,
  required bool compact,
  required PortfolioMotion motion,
  required Widget Function(bool compact) profile,
  required Widget Function(bool compact) testimonials,
  required Widget Function(bool compact) projects,
}) {
  final blocks = List<CategoryContentBlock>.from(template.data)
    ..sort((a, b) => a.seqId.compareTo(b.seqId));
  var idx = 0;
  return Container(
    color: Colors.transparent,
    child: ListView(
      padding: EdgeInsets.zero,
      physics: const ClampingScrollPhysics(),
      children: [
      for (final block in blocks)
        switch (block.contentType) {
          ContentType.banners => PortfolioMotionLayer(
              motion: motion,
              index: idx++,
              compact: compact,
              child: profile(compact),
            ),
          ContentType.categories => PortfolioMotionLayer(
              motion: motion,
              index: idx++,
              compact: compact,
              child: testimonials(compact),
            ),
          ContentType.products => PortfolioMotionLayer(
              motion: motion,
              index: idx++,
              compact: compact,
              child: projects(compact),
            ),
          _ => const SizedBox.shrink(),
        },
    ],
    ),
  );
}
