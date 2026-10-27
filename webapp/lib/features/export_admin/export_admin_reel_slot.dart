import 'package:flutter/material.dart';
import 'package:webapp/features/export_admin/export_admin_ui.dart';
import 'package:webapp/features/templates/preview/shared/catalog_reel_video_player.dart';

/// Product reel slot — vertical preview like the storefront, not a raw URL field.
class ExportAdminReelSlot extends StatelessWidget {
  const ExportAdminReelSlot({
    super.key,
    required this.videoUrl,
    required this.onUrlChanged,
  });

  final String? videoUrl;
  final ValueChanged<String?> onUrlChanged;

  static const _w = 96.0;
  static const _h = 152.0;

  bool get _has => videoUrl != null && videoUrl!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Reel video', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => _openEditor(context),
              child: Container(
                width: _w,
                height: _h,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor),
                ),
                clipBehavior: Clip.antiAlias,
                child: _has
                    ? CatalogReelVideoPlayer(
                        url: videoUrl!,
                        placeholder: _placeholder(theme),
                        error: _errorPlaceholder(theme),
                      )
                    : _emptyReel(theme),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _has ? 'Tap preview to change or remove' : 'Optional short video for this item',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonalIcon(
                    onPressed: () => _openEditor(context),
                    icon: Icon(_has ? Icons.edit_outlined : Icons.video_library_outlined, size: 18),
                    label: Text(_has ? 'Edit reel' : 'Add reel'),
                  ),
                  if (_has)
                    TextButton(
                      onPressed: () => onUrlChanged(null),
                      child: const Text('Remove reel'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _emptyReel(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.play_circle_outline, size: 36, color: Colors.white70),
        const SizedBox(height: 6),
        Text('Add reel', style: theme.textTheme.labelSmall?.copyWith(color: Colors.white70)),
      ],
    );
  }

  Widget _placeholder(ThemeData theme) => Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary),
        ),
      );

  Widget _errorPlaceholder(ThemeData theme) => const Center(
        child: Icon(Icons.videocam_off_outlined, color: Colors.white54, size: 28),
      );

  Future<void> _openEditor(BuildContext context) async {
    final controller = TextEditingController(text: videoUrl ?? '');
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final draft = controller.text.trim();
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewPaddingOf(ctx).bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Reel video', style: Theme.of(ctx).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    'Paste a Google Drive link or direct MP4. Shoppers see this in the reel carousel.',
                    style: Theme.of(ctx).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      width: _w,
                      height: _h,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: draft.isNotEmpty
                          ? CatalogReelVideoPlayer(
                              url: draft,
                              placeholder: _placeholder(Theme.of(ctx)),
                              error: _errorPlaceholder(Theme.of(ctx)),
                            )
                          : _emptyReel(Theme.of(ctx)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    decoration: exportAdminInputDecoration(ctx, 'Video link'),
                    onChanged: (_) => setSheetState(() {}),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () {
                      final v = controller.text.trim();
                      onUrlChanged(v.isEmpty ? null : v);
                      Navigator.pop(ctx);
                    },
                    child: const Text('Save reel'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
