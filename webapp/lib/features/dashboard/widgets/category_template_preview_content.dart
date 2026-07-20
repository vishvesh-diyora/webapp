import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webapp/features/dashboard/models/category_template.dart';

/// Template summary + data blocks shown inside device preview screens.
class CategoryTemplatePreviewContent extends StatelessWidget {
  const CategoryTemplatePreviewContent({
    super.key,
    required this.template,
    this.compact = false,
  });

  final CategoryTemplate template;
  final bool compact;

  String get _typeLabel => switch (template.type) {
        CategoryType.ecommerce => 'E-commerce (1)',
        CategoryType.portfolio => 'Portfolio (2)',
        CategoryType.gift => 'Gift (3)',
        CategoryType.custom => 'Custom (4)',
        _ => 'Unknown',
      };

  String _contentTypeLabel(int contentType) {
    return switch (contentType) {
      ContentType.banners => 'Banners (1)',
      ContentType.categories => 'Categories (2)',
      ContentType.products => 'Products (3)',
      _ => 'Unknown ($contentType)',
    };
  }

  @override
  Widget build(BuildContext context) {
    final jsonString =
        const JsonEncoder.withIndent('  ').convert(template.toJson());
    final padding = compact ? 12.0 : 16.0;
    final sectionGap = compact ? 10.0 : 14.0;

    return ListView(
      padding: EdgeInsets.all(padding),
      children: [
        Text(
          template.subname,
          style: TextStyle(
            fontSize: compact ? 12 : 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
          ),
        ),
        SizedBox(height: compact ? 4 : 6),
        Text(
          template.description,
          style: TextStyle(
            fontSize: compact ? 11 : 13,
            color: const Color(0xFF64748B),
            height: 1.4,
          ),
        ),
        SizedBox(height: sectionGap),
        _SectionCard(
          compact: compact,
          title: 'Summary',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoRow(compact: compact, label: 'type', value: _typeLabel),
              _InfoRow(
                compact: compact,
                label: 'templateType',
                value: template.templateType.toString(),
              ),
              _InfoRow(compact: compact, label: 'name', value: template.name),
              _InfoRow(
                compact: compact,
                label: 'subname',
                value: template.subname,
              ),
            ],
          ),
        ),
        SizedBox(height: sectionGap),
        _SectionCard(
          compact: compact,
          title: 'data (${template.data.length} blocks)',
          child: Column(
            children: [
              for (final block in template.data)
                Padding(
                  padding: EdgeInsets.only(bottom: compact ? 6 : 8),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(compact ? 8 : 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(compact ? 8 : 10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoRow(
                          compact: compact,
                          label: 'seqId',
                          value: block.seqId.toString(),
                        ),
                        _InfoRow(
                          compact: compact,
                          label: 'contentType',
                          value: _contentTypeLabel(block.contentType),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: sectionGap),
        _SectionCard(
          compact: compact,
          title: 'Full JSON',
          child: SelectableText(
            jsonString,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: compact ? 9 : 11,
              height: 1.4,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    required this.compact,
  });

  final String title;
  final Widget child;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 10 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(compact ? 10 : 12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: compact ? 11 : 13,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: compact ? 8 : 10),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.compact,
  });

  final String label;
  final String value;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 4 : 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: compact ? 72 : 90,
            child: Text(
              '$label:',
              style: TextStyle(
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
                fontSize: compact ? 10 : 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: const Color(0xFF0F172A),
                fontWeight: FontWeight.w500,
                fontSize: compact ? 10 : 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
