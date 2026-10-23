import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webapp/core/domain/category_type.dart';
import 'package:webapp/features/dashboard/data/category_templates_data.dart';
import 'package:webapp/features/dashboard/widgets/category_template_preview_content.dart';
import 'package:webapp/features/dashboard/widgets/portfolio/portfolio_screen_background.dart';
import 'package:webapp/features/dashboard/widgets/preview_device_frame.dart';
import 'package:webapp/features/dashboard/widgets/template_selection_panel.dart';
import 'package:webapp/features/website/domain/entities/website_document.dart';
import 'package:webapp/features/export/export_document_resolver.dart';
import 'package:webapp/features/export/static_site_exporter.dart';
import 'package:webapp/features/website/domain/repositories/website_repository.dart';
import 'package:webapp/features/dashboard/screens/template_fullscreen_preview_screen.dart';
import 'package:webapp/features/website/presentation/bloc/my_websites_bloc.dart';

enum _PreviewMode { mobile, tablet, web }

const _bottomSheetCollapsedHeight = 40.0;
const _bottomSheetAnimationDuration = Duration(milliseconds: 300);

/// Category detail with device preview and responsive detail panel.
class CategoryDetailScreen extends StatefulWidget {
  const CategoryDetailScreen({
    super.key,
    required this.categoryType,
    this.initialDocument,
  });

  final int categoryType;
  final WebsiteDocument? initialDocument;

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  static const double _tabletBreakpoint = 600;
  static const double _desktopBreakpoint = 1024;

  _PreviewMode? _selectedMode;
  bool _isDetailPanelExpanded = true;
  bool _isSaving = false;
  late WebsiteDocument _selectedDocument;
  late List<TemplateDefinition> _templateDefinitions;
  late int _selectedTemplateType;

  @override
  void initState() {
    super.initState();
    _templateDefinitions = CategoryTemplatesData.templatesForCategory(widget.categoryType);
    if (widget.initialDocument != null) {
      _selectedDocument =
          ExportDocumentResolver.ensureFullContent(widget.initialDocument!);
      _selectedTemplateType = _selectedDocument.templateType;
    } else {
      final first = _templateDefinitions.firstOrNull;
      _selectedTemplateType = first?.templateType ?? 1;
      _selectedDocument = first?.toDocument() ??
          CategoryTemplatesData.byType(widget.categoryType)!;
    }
  }

  void _selectTemplate(TemplateDefinition definition) {
    if (definition.templateType == _selectedTemplateType) return;
    setState(() {
      _selectedTemplateType = definition.templateType;
      _selectedDocument = definition.toDocument().copyWith(
        id: _selectedDocument.id,
        updatedAt: _selectedDocument.updatedAt,
      );
    });
  }

  Future<void> _saveSelectedTemplate() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final repository = context.read<WebsiteRepository>();
      final toSave = ExportDocumentResolver.ensureFullContent(
        _selectedDocument.copyWith(updatedAt: DateTime.now()),
      );
      await repository.saveWebsite(toSave);
      String? exportNote;
      try {
        final path = await StaticSiteExporter.exportAndDownload(toSave);
        exportNote =
            'Website ZIP ready ($path). Upload the whole folder to your host.';
      } catch (_) {
        exportNote = 'Saved locally; could not download static site ZIP.';
      }
      if (!mounted) return;
      context.read<MyWebsitesBloc>().add(const MyWebsitesRequested());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved to My Websites. $exportNote')),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save: $error')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  _PreviewMode _defaultMode(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < _tabletBreakpoint) return _PreviewMode.mobile;
    if (width < _desktopBreakpoint) return _PreviewMode.tablet;
    return _PreviewMode.web;
  }

  void _openFullscreenPreview(BuildContext context, _PreviewMode mode) {
    final (compact, mobileProfileLayout) = switch (mode) {
      _PreviewMode.mobile => (true, true),
      _PreviewMode.tablet => (false, false),
      _PreviewMode.web => (false, false),
    };
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => TemplateFullscreenPreviewScreen(
          document: _selectedDocument,
          compact: compact,
          mobileProfileLayout: mobileProfileLayout,
        ),
      ),
    );
  }

  Widget _buildPreview(_PreviewMode mode, BoxConstraints constraints) {
    final content = CategoryTemplatePreviewContent(
      key: ValueKey(
        '${_selectedDocument.type}_${_selectedDocument.templateType}_$mode',
      ),
      document: _selectedDocument,
      compact: mode == _PreviewMode.mobile,
      mobileProfileLayout: mode == _PreviewMode.mobile,
    );

    final screenBg = PreviewScreenBackground.forTemplate(
      _selectedDocument,
      mobileProfileLayout: mode == _PreviewMode.mobile,
    );

    final (fitWidth, fitHeight, frame) = switch (mode) {
      _PreviewMode.mobile => (
          IPhonePreviewFrame.fitWidth,
          IPhonePreviewFrame.fitHeight,
          IPhonePreviewFrame(screenBackground: screenBg, child: content),
        ),
      _PreviewMode.tablet => (
          TabletPreviewFrame.fitWidth,
          TabletPreviewFrame.fitHeight,
          TabletPreviewFrame(screenBackground: screenBg, child: content),
        ),
      _PreviewMode.web => (
          DesktopPreviewFrame.fitWidth,
          DesktopPreviewFrame.fitHeight,
          DesktopPreviewFrame(screenBackground: screenBg, child: content),
        ),
    };

    return RepaintBoundary(
      child: _FittedDevicePreview(
        maxWidth: constraints.maxWidth,
        maxHeight: constraints.maxHeight,
        fitWidth: fitWidth,
        fitHeight: fitHeight,
        child: frame,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedMode ??= _defaultMode(context);
  }

  @override
  Widget build(BuildContext context) {
    final selectedMode = _selectedMode ?? _defaultMode(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(CategoryType.homeTitle(widget.categoryType)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _GradientSaveButton(
              isLoading: _isSaving,
              onTap: _saveSelectedTemplate,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isPortraitLayout =
                constraints.maxWidth < constraints.maxHeight;

            final previewSection = _DevicePreviewSection(
              selectedMode: selectedMode,
              onModeChanged: (mode) => setState(() => _selectedMode = mode),
              onFullscreenTap: () => _openFullscreenPreview(context, selectedMode),
              previewBuilder: (previewConstraints) => _ExclusivePreviewPane(
                key: ValueKey(
                  '${selectedMode.name}_$_selectedTemplateType',
                ),
                builder: (_) => _buildPreview(selectedMode, previewConstraints),
              ),
            );

            final detailPanel = _CategoryDetailPanel(
              templateDefinitions: _templateDefinitions,
              selectedTemplateType: _selectedTemplateType,
              onTemplateSelected: _selectTemplate,
              isBottomSheet: isPortraitLayout,
              isExpanded: _isDetailPanelExpanded,
              onToggle: isPortraitLayout
                  ? () => setState(
                        () => _isDetailPanelExpanded = !_isDetailPanelExpanded,
                      )
                  : null,
            );

            if (isPortraitLayout) {
              final expandedSheetHeight = constraints.maxHeight * 0.4;

              return Column(
                children: [
                  Expanded(child: previewSection),
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: AnimatedContainer(
                      duration: _bottomSheetAnimationDuration,
                      curve: Curves.easeInOutCubic,
                      height: _isDetailPanelExpanded
                          ? expandedSheetHeight
                          : _bottomSheetCollapsedHeight,
                      child: detailPanel,
                    ),
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(flex: 6, child: previewSection),
                Expanded(flex: 4, child: detailPanel),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DevicePreviewSection extends StatelessWidget {
  const _DevicePreviewSection({
    required this.selectedMode,
    required this.onModeChanged,
    required this.onFullscreenTap,
    required this.previewBuilder,
  });

  final _PreviewMode selectedMode;
  final ValueChanged<_PreviewMode> onModeChanged;
  final VoidCallback onFullscreenTap;
  final Widget Function(BoxConstraints constraints) previewBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return previewBuilder(constraints);
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
          child: Center(
            child: _PreviewViewportToolbar(
              selectedMode: selectedMode,
              onModeChanged: onModeChanged,
              onFullscreenTap: onFullscreenTap,
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryDetailPanel extends StatelessWidget {
  const _CategoryDetailPanel({
    required this.templateDefinitions,
    required this.selectedTemplateType,
    required this.onTemplateSelected,
    required this.isBottomSheet,
    required this.isExpanded,
    this.onToggle,
  });

  final List<TemplateDefinition> templateDefinitions;
  final int selectedTemplateType;
  final ValueChanged<TemplateDefinition> onTemplateSelected;
  final bool isBottomSheet;
  final bool isExpanded;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: isBottomSheet
              ? const BorderSide(color: Color(0xFFE2E8F0))
              : BorderSide.none,
          left: isBottomSheet
              ? BorderSide.none
              : const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        borderRadius: isBottomSheet
            ? const BorderRadius.vertical(top: Radius.circular(16))
            : BorderRadius.zero,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: isBottomSheet ? const Offset(0, -4) : const Offset(-4, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isBottomSheet)
            _BottomSheetToggle(
              isExpanded: isExpanded,
              onTap: onToggle,
            ),
          Expanded(
            child: IgnorePointer(
              ignoring: isBottomSheet && !isExpanded,
              child: TemplateSelectionPanel(
                templates: templateDefinitions,
                selectedTemplateType: selectedTemplateType,
                onSelected: onTemplateSelected,
                isMobileLayout: isBottomSheet,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomSheetToggle extends StatelessWidget {
  const _BottomSheetToggle({
    required this.isExpanded,
    this.onTap,
  });

  final bool isExpanded;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Center(
            child: AnimatedRotation(
              turns: isExpanded ? 0 : 0.5,
              duration: _bottomSheetAnimationDuration,
              curve: Curves.easeInOutCubic,
              child: const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 28,
                color: Color(0xFF64748B),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientSaveButton extends StatelessWidget {
  const _GradientSaveButton({
    required this.onTap,
    required this.isLoading,
  });

  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else ...[
                  const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewViewportToolbar extends StatelessWidget {
  const _PreviewViewportToolbar({
    required this.selectedMode,
    required this.onModeChanged,
    required this.onFullscreenTap,
  });

  static const _outerRadius = 28.0;
  static const _innerRadius = 22.0;
  static const _barHeight = 46.0;

  final _PreviewMode selectedMode;
  final ValueChanged<_PreviewMode> onModeChanged;
  final VoidCallback onFullscreenTap;

  static const _modes = [
    _PreviewMode.mobile,
    _PreviewMode.tablet,
    _PreviewMode.web,
  ];

  static IconData _iconFor(_PreviewMode mode) => switch (mode) {
        _PreviewMode.mobile => Icons.phone_iphone_rounded,
        _PreviewMode.tablet => Icons.tablet_mac_rounded,
        _PreviewMode.web => Icons.desktop_windows_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_outerRadius),
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE8ECF4)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.14),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: _barHeight,
              width: 228,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(_innerRadius),
              ),
              child: Row(
                children: [
                  for (final mode in _modes) ...[
                    Expanded(
                      child: _PreviewModeChip(
                        icon: _iconFor(mode),
                        selected: mode == selectedMode,
                        onTap: () => onModeChanged(mode),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 6),
            _FullscreenPreviewButton(onTap: onFullscreenTap),
          ],
        ),
      ),
    );
  }
}

class _PreviewModeChip extends StatelessWidget {
  const _PreviewModeChip({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          height: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: selected
                ? const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            size: 21,
            color: selected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}

class _FullscreenPreviewButton extends StatelessWidget {
  const _FullscreenPreviewButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Full screen preview',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF6366F1).withValues(alpha: 0.14),
                  const Color(0xFF8B5CF6).withValues(alpha: 0.22),
                ],
              ),
              border: Border.all(
                color: const Color(0xFF6366F1).withValues(alpha: 0.22),
              ),
            ),
            child: SizedBox(
              width: 48,
              height: _PreviewViewportToolbar._barHeight,
              child: const Icon(
                Icons.open_in_full_rounded,
                size: 21,
                color: Color(0xFF4F46E5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Mounts a single heavy preview; disposes the previous tree before building the next.
class _ExclusivePreviewPane extends StatefulWidget {
  const _ExclusivePreviewPane({
    super.key,
    required this.builder,
  });

  final WidgetBuilder builder;

  @override
  State<_ExclusivePreviewPane> createState() => _ExclusivePreviewPaneState();
}

class _ExclusivePreviewPaneState extends State<_ExclusivePreviewPane> {
  Widget? _preview;
  int _loadGeneration = 0;

  @override
  void initState() {
    super.initState();
    _schedulePreviewBuild();
  }

  @override
  void didUpdateWidget(covariant _ExclusivePreviewPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.key != oldWidget.key) {
      _preview = null;
      _schedulePreviewBuild();
    }
  }

  void _schedulePreviewBuild() {
    final generation = ++_loadGeneration;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || generation != _loadGeneration) return;
      setState(() => _preview = widget.builder(context));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_preview == null) {
      return const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    return _preview!;
  }
}

class _FittedDevicePreview extends StatelessWidget {
  const _FittedDevicePreview({
    required this.child,
    required this.maxWidth,
    required this.maxHeight,
    required this.fitWidth,
    required this.fitHeight,
  });

  final Widget child;
  final double maxWidth;
  final double maxHeight;
  final double fitWidth;
  final double fitHeight;

  @override
  Widget build(BuildContext context) {
    if (maxWidth <= 0 || maxHeight <= 0) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: maxWidth,
      height: maxHeight,
      child: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          clipBehavior: Clip.none,
          child: SizedBox(
            width: fitWidth,
            height: fitHeight,
            child: child,
          ),
        ),
      ),
    );
  }
}
