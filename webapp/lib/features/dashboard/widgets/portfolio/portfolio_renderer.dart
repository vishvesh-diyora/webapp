import 'package:flutter/material.dart';
import 'package:webapp/features/dashboard/models/category_template.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/designs/aurora_glass_design.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/designs/brutalist_design.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/designs/dark_dev_design.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/designs/editorial_magazine_design.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/designs/luxury_gold_design.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/designs/nature_zen_design.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/designs/neon_cyber_design.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/designs/noir_cinema_design.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/designs/pastel_dream_design.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/designs/split_monochrome_design.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/designs/swiss_minimal_design.dart';

/// Renders a portfolio template preview driven by [template.data] blocks.
class PortfolioTemplateRenderer extends StatelessWidget {
  const PortfolioTemplateRenderer({
    super.key,
    required this.template,
    this.compact = false,
    this.mobileProfileLayout = true,
  });

  final CategoryTemplate template;
  final bool compact;
  final bool mobileProfileLayout;

  @override
  Widget build(BuildContext context) {
    final args = (
      template: template,
      compact: compact,
      mobileProfileLayout: mobileProfileLayout,
    );

    return switch (template.templateType) {
      1 => DarkDevDesign(
          template: args.template,
          compact: args.compact,
          mobileProfileLayout: args.mobileProfileLayout,
        ),
      2 => SwissMinimalDesign(
          template: args.template,
          compact: args.compact,
          mobileProfileLayout: args.mobileProfileLayout,
        ),
      3 => NoirCinemaDesign(
          template: args.template,
          compact: args.compact,
          mobileProfileLayout: args.mobileProfileLayout,
        ),
      4 => EditorialMagazineDesign(
          template: args.template,
          compact: args.compact,
          mobileProfileLayout: args.mobileProfileLayout,
        ),
      5 => AuroraGlassDesign(
          template: args.template,
          compact: args.compact,
          mobileProfileLayout: args.mobileProfileLayout,
        ),
      6 => NeonCyberDesign(
          template: args.template,
          compact: args.compact,
          mobileProfileLayout: args.mobileProfileLayout,
        ),
      7 => PastelDreamDesign(
          template: args.template,
          compact: args.compact,
          mobileProfileLayout: args.mobileProfileLayout,
        ),
      8 => BrutalistDesign(
          template: args.template,
          compact: args.compact,
          mobileProfileLayout: args.mobileProfileLayout,
        ),
      9 => NatureZenDesign(
          template: args.template,
          compact: args.compact,
          mobileProfileLayout: args.mobileProfileLayout,
        ),
      10 => LuxuryGoldDesign(
          template: args.template,
          compact: args.compact,
          mobileProfileLayout: args.mobileProfileLayout,
        ),
      11 => SplitMonochromeDesign(
          template: args.template,
          compact: args.compact,
          mobileProfileLayout: args.mobileProfileLayout,
        ),
      _ => DarkDevDesign(
          template: args.template,
          compact: args.compact,
          mobileProfileLayout: args.mobileProfileLayout,
        ),
    };
  }
}
