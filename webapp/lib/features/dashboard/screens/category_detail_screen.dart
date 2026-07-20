import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webapp/features/dashboard/models/category_template.dart';
import 'package:webapp/features/dashboard/widgets/category_template_preview_content.dart';
import 'package:webapp/features/dashboard/widgets/preview_device_frame.dart';

enum _PreviewMode { mobile, tablet, web }

const _bottomSheetCollapsedHeight = 40.0;
const _bottomSheetAnimationDuration = Duration(milliseconds: 300);

/// Category detail with device preview and responsive detail panel.
class CategoryDetailScreen extends StatefulWidget {
  const CategoryDetailScreen({super.key, required this.template});

  final CategoryTemplate template;

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  static const double _tabletBreakpoint = 600;
  static const double _desktopBreakpoint = 1024;

  _PreviewMode? _selectedMode;
  bool _isDetailPanelExpanded = true;

  _PreviewMode _defaultMode(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < _tabletBreakpoint) return _PreviewMode.mobile;
    if (width < _desktopBreakpoint) return _PreviewMode.tablet;
    return _PreviewMode.web;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedMode ??= _defaultMode(context);
  }

  Widget _buildPreview(_PreviewMode mode, BoxConstraints constraints) {
    final content = CategoryTemplatePreviewContent(
      template: widget.template,
      compact: true,
    );

    final (fitWidth, fitHeight, frame) = switch (mode) {
      _PreviewMode.mobile => (
          IPhonePreviewFrame.fitWidth,
          IPhonePreviewFrame.fitHeight,
          IPhonePreviewFrame(child: content),
        ),
      _PreviewMode.tablet => (
          TabletPreviewFrame.fitWidth,
          TabletPreviewFrame.fitHeight,
          TabletPreviewFrame(child: content),
        ),
      _PreviewMode.web => (
          DesktopPreviewFrame.fitWidth,
          DesktopPreviewFrame.fitHeight,
          DesktopPreviewFrame(child: content),
        ),
    };

    return _FittedDevicePreview(
      key: ValueKey(mode.name),
      maxWidth: constraints.maxWidth,
      maxHeight: constraints.maxHeight,
      fitWidth: fitWidth,
      fitHeight: fitHeight,
      child: frame,
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedMode = _selectedMode ?? _defaultMode(context);

    return Scaffold(
      appBar: AppBar(
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: _GradientNextButton(),
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
              previewBuilder: (previewConstraints) => AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                layoutBuilder: (currentChild, previousChildren) {
                  return Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      ...previousChildren,
                      ?currentChild,
                    ],
                  );
                },
                child: _buildPreview(selectedMode, previewConstraints),
              ),
            );

            final detailPanel = _CategoryDetailPanel(
              template: widget.template,
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
    required this.previewBuilder,
  });

  final _PreviewMode selectedMode;
  final ValueChanged<_PreviewMode> onModeChanged;
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
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
          child: Center(
            child: SizedBox(
              width: 220,
              child: CupertinoSlidingSegmentedControl<_PreviewMode>(
                groupValue: selectedMode,
                thumbColor: Colors.white,
                backgroundColor: const Color(0xFFE2E8F0),
                children: const {
                  _PreviewMode.mobile: _SegmentIcon(
                    icon: Icons.phone_iphone_outlined,
                  ),
                  _PreviewMode.tablet: _SegmentIcon(
                    icon: Icons.tablet_mac_outlined,
                  ),
                  _PreviewMode.web: _SegmentIcon(
                    icon: Icons.desktop_mac_outlined,
                  ),
                },
                onValueChanged: (value) {
                  if (value == null) return;
                  onModeChanged(value);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryDetailPanel extends StatelessWidget {
  const _CategoryDetailPanel({
    required this.template,
    required this.isBottomSheet,
    required this.isExpanded,
    this.onToggle,
  });

  final CategoryTemplate template;
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
              child: CategoryTemplatePreviewContent(template: template),
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

class _GradientNextButton extends StatelessWidget {
  const _GradientNextButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
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
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Next',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SegmentIcon extends StatelessWidget {
  const _SegmentIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Icon(
        icon,
        size: 20,
        color: const Color(0xFF334155),
      ),
    );
  }
}

class _FittedDevicePreview extends StatelessWidget {
  const _FittedDevicePreview({
    super.key,
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
