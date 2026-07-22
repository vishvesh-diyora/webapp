import 'package:flutter/material.dart';
import 'package:webapp/core/domain/category_type.dart';
import 'package:webapp/features/dashboard/data/category_templates_data.dart';
import 'package:webapp/features/dashboard/models/category_template.dart';
import 'package:webapp/features/templates/preview/website_preview_renderer.dart';

class TemplateSelectionPanel extends StatelessWidget {
  const TemplateSelectionPanel({
    super.key,
    required this.templates,
    required this.selected,
    required this.onSelected,
    required this.isMobileLayout,
  });

  final List<WebsiteDocument> templates;
  final WebsiteDocument selected;
  final ValueChanged<WebsiteDocument> onSelected;
  final bool isMobileLayout;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            'Choose Template (${templates.length})',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: isMobileLayout ? 14 : 15,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        Expanded(
          child: isMobileLayout
              ? _MobileTemplateStrip(
                  templates: templates,
                  selected: selected,
                  onSelected: onSelected,
                )
              : _WebTemplateGrid(
                  templates: templates,
                  selected: selected,
                  onSelected: onSelected,
                ),
        ),
      ],
    );
  }
}

class _MobileTemplateStrip extends StatelessWidget {
  const _MobileTemplateStrip({
    required this.templates,
    required this.selected,
    required this.onSelected,
  });

  final List<WebsiteDocument> templates;
  final WebsiteDocument selected;
  final ValueChanged<WebsiteDocument> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      itemCount: templates.length,
      separatorBuilder: (_, __) => const SizedBox(width: 10),
      itemBuilder: (context, index) {
        final template = templates[index];
        return _TemplateCard(
          template: template,
          isSelected: template.templateType == selected.templateType,
          onTap: () => onSelected(template),
          width: 140,
          showMiniPreview: true,
        );
      },
    );
  }
}

class _WebTemplateGrid extends StatelessWidget {
  const _WebTemplateGrid({
    required this.templates,
    required this.selected,
    required this.onSelected,
  });

  final List<WebsiteDocument> templates;
  final WebsiteDocument selected;
  final ValueChanged<WebsiteDocument> onSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        return _TemplateCard(
          template: template,
          isSelected: template.templateType == selected.templateType,
          onTap: () => onSelected(template),
          showMiniPreview: true,
        );
      },
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.template,
    required this.isSelected,
    required this.onTap,
    this.width,
    this.showMiniPreview = false,
  });

  final WebsiteDocument template;
  final bool isSelected;
  final VoidCallback onTap;
  final double? width;
  final bool showMiniPreview;

  @override
  Widget build(BuildContext context) {
    final style = CategoryTemplatesData.styleFor(template);

    return SizedBox(
      width: width,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? style.primary : const Color(0xFFE2E8F0),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: style.primary.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                    child: showMiniPreview
                        ? IgnorePointer(
                            child: WebsitePreviewRenderer(
                              document: template,
                              compact: true,
                              mobileProfileLayout: template.type == CategoryType.portfolio,
                            ),
                          )
                        : DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: style.previewGradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                style.icon,
                                color: Colors.white.withValues(alpha: 0.9),
                                size: 28,
                              ),
                            ),
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        template.subname,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 9, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
