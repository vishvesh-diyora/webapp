import 'package:flutter/material.dart';
import 'package:webapp/features/templates/catalog/template_catalog.dart';

class TemplateSelectionPanel extends StatelessWidget {
  const TemplateSelectionPanel({
    super.key,
    required this.templates,
    required this.selectedTemplateType,
    required this.onSelected,
    required this.isMobileLayout,
  });

  final List<TemplateDefinition> templates;
  final int selectedTemplateType;
  final ValueChanged<TemplateDefinition> onSelected;
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
                  selectedTemplateType: selectedTemplateType,
                  onSelected: onSelected,
                )
              : _WebTemplateGrid(
                  templates: templates,
                  selectedTemplateType: selectedTemplateType,
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
    required this.selectedTemplateType,
    required this.onSelected,
  });

  final List<TemplateDefinition> templates;
  final int selectedTemplateType;
  final ValueChanged<TemplateDefinition> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      itemCount: templates.length,
      separatorBuilder: (context, index) => const SizedBox(width: 10),
      itemBuilder: (context, index) {
        final template = templates[index];
        return SizedBox(
          width: 140,
          child: _TemplateCard(
            template: template,
            isSelected: template.templateType == selectedTemplateType,
            onTap: () => onSelected(template),
          ),
        );
      },
    );
  }
}

class _WebTemplateGrid extends StatelessWidget {
  const _WebTemplateGrid({
    required this.templates,
    required this.selectedTemplateType,
    required this.onSelected,
  });

  final List<TemplateDefinition> templates;
  final int selectedTemplateType;
  final ValueChanged<TemplateDefinition> onSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.8,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        return _TemplateCard(
          template: template,
          isSelected: template.templateType == selectedTemplateType,
          onTap: () => onSelected(template),
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
  });

  final TemplateDefinition template;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = template.style;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? style.primary.withValues(alpha: 0.06) : Colors.white,
            border: Border.all(
              color: isSelected ? style.primary : const Color(0xFFE2E8F0),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: style.primary.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            template.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              fontSize: 13,
              color: isSelected ? style.primary : const Color(0xFF0F172A),
            ),
          ),
        ),
      ),
    );
  }
}
