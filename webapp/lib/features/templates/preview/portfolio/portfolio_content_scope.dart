import 'package:flutter/material.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_helpers.dart';
import 'package:webapp/features/website/domain/entities/website_document.dart';

/// Provides JSON-driven portfolio content to descendant design widgets.
class PortfolioContentScope extends StatefulWidget {
  const PortfolioContentScope({
    super.key,
    required this.document,
    required this.child,
  });

  final WebsiteDocument document;
  final Widget child;

  @override
  State<PortfolioContentScope> createState() => _PortfolioContentScopeState();
}

class _PortfolioContentScopeState extends State<PortfolioContentScope> {
  @override
  void initState() {
    super.initState();
    PortfolioDesignHelpers.bind(widget.document);
  }

  @override
  void didUpdateWidget(PortfolioContentScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.document != widget.document) {
      PortfolioDesignHelpers.bind(widget.document);
    }
  }

  @override
  void dispose() {
    PortfolioDesignHelpers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
