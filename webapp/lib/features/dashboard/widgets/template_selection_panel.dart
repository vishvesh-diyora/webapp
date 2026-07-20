import 'package:flutter/material.dart';
import 'package:webapp/features/dashboard/data/category_templates_data.dart';
import 'package:webapp/features/dashboard/models/category_template.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_renderer.dart';

/// Template picker shown in the detail bottom sheet / side panel.
class TemplateSelectionPanel extends StatelessWidget {
  const TemplateSelectionPanel({
    super.key,
    required this.templates,
    required this.selected,
    required this.onSelected,
    required this.isMobileLayout,
  });

  final List<CategoryTemplate> templates;
  final CategoryTemplate selected;
  final ValueChanged<CategoryTemplate> onSelected;
  final bool isMobileLayout;

  @override
  Widget build(BuildContext context) {
    if (templates.length <= 1) {
      return _SingleTemplateInfo(template: selected);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            'Choose Template',
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

  final List<CategoryTemplate> templates;
  final CategoryTemplate selected;
  final ValueChanged<CategoryTemplate> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      itemCount: templates.length,
      separatorBuilder: (_, _) => const SizedBox(width: 10),
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

  final List<CategoryTemplate> templates;
  final CategoryTemplate selected;
  final ValueChanged<CategoryTemplate> onSelected;

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

  final CategoryTemplate template;
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
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(11),
                    ),
                    child: showMiniPreview &&
                            template.type == CategoryType.portfolio
                        ? IgnorePointer(
                            child: PortfolioTemplateRenderer(
                              template: template,
                              compact: true,
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
                        style: const TextStyle(
                          fontSize: 9,
                          color: Color(0xFF64748B),
                        ),
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

class _SingleTemplateInfo extends StatelessWidget {
  const _SingleTemplateInfo({required this.template});

  final CategoryTemplate template;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          template.name,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          template.subname,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          template.description,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
