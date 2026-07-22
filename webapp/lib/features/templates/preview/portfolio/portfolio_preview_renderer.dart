import 'package:flutter/material.dart';
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
import 'package:webapp/features/templates/preview/layout_theme.dart';
import 'package:webapp/features/templates/preview/portfolio/json_portfolio_variant_design.dart';
import 'package:webapp/features/templates/preview/portfolio/portfolio_content_scope.dart';
import 'package:webapp/features/website/domain/entities/website_document.dart';

/// Portfolio preview — templates 1–11 handcrafted, 12–22 JSON variants.
class PortfolioPreviewRenderer extends StatelessWidget {
  const PortfolioPreviewRenderer({
    super.key,
    required this.document,
    required this.compact,
    required this.mobileProfileLayout,
  });

  final WebsiteDocument document;
  final bool compact;
  final bool mobileProfileLayout;

  @override
  Widget build(BuildContext context) {
    final child = switch (document.templateType) {
      1 => SplitMonochromeDesign(
          template: document,
          compact: compact,
          mobileProfileLayout: mobileProfileLayout,
        ),
      2 => DarkDevDesign(
          template: document,
          compact: compact,
          mobileProfileLayout: mobileProfileLayout,
        ),
      3 => SwissMinimalDesign(
          template: document,
          compact: compact,
          mobileProfileLayout: mobileProfileLayout,
        ),
      4 => NoirCinemaDesign(
          template: document,
          compact: compact,
          mobileProfileLayout: mobileProfileLayout,
        ),
      5 => EditorialMagazineDesign(
          template: document,
          compact: compact,
          mobileProfileLayout: mobileProfileLayout,
        ),
      6 => AuroraGlassDesign(
          template: document,
          compact: compact,
          mobileProfileLayout: mobileProfileLayout,
        ),
      7 => NeonCyberDesign(
          template: document,
          compact: compact,
          mobileProfileLayout: mobileProfileLayout,
        ),
      8 => PastelDreamDesign(
          template: document,
          compact: compact,
          mobileProfileLayout: mobileProfileLayout,
        ),
      9 => BrutalistDesign(
          template: document,
          compact: compact,
          mobileProfileLayout: mobileProfileLayout,
        ),
      10 => NatureZenDesign(
          template: document,
          compact: compact,
          mobileProfileLayout: mobileProfileLayout,
        ),
      11 => LuxuryGoldDesign(
          template: document,
          compact: compact,
          mobileProfileLayout: mobileProfileLayout,
        ),
      _ => JsonPortfolioVariantDesign(
          document: document,
          compact: compact,
          mobileProfileLayout: mobileProfileLayout,
          theme: LayoutTheme.fromContent(document.blockByContentType(1)?.contentData),
        ),
    };

    return PortfolioContentScope(
      document: document,
      child: child,
    );
  }
}
