import 'package:flutter/material.dart';

/// Image picker tile for export admin (preview + upload, no raw URL field).
class ExportAdminMediaField extends StatelessWidget {
  const ExportAdminMediaField({
    super.key,
    required this.label,
    required this.imageUrl,
    required this.onUpload,
    this.onRemove,
    this.height = 160,
    this.aspectRatio,
  });

  final String label;
  final String? imageUrl;
  final VoidCallback onUpload;
  final VoidCallback? onRemove;
  final double height;
  final double? aspectRatio;

  bool get _hasImage => imageUrl != null && imageUrl!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Material(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onUpload,
            child: AspectRatio(
              aspectRatio: aspectRatio ?? 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (_hasImage)
                    Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(theme, broken: true),
                    )
                  else
                    _placeholder(theme),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _hasImage ? Icons.edit : Icons.add_photo_alternate_outlined,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _hasImage ? 'Change' : 'Add photo',
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_hasImage && onRemove != null) ...[
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Remove photo'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _placeholder(ThemeData theme, {bool broken = false}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            broken ? Icons.broken_image_outlined : Icons.image_outlined,
            size: 40,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 8),
          Text(
            broken ? 'Could not load image — tap to replace' : 'Tap to upload',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
          ),
        ],
      ),
    );
  }
}

class ExportAdminImageThumb extends StatelessWidget {
  const ExportAdminImageThumb({
    super.key,
    required this.url,
    required this.onTap,
    this.onRemove,
    this.size = 88,
  });

  final String url;
  final VoidCallback onTap;
  final VoidCallback? onRemove;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Material(
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Image.network(
              url,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: size,
                height: size,
                color: Colors.grey.shade300,
                child: const Icon(Icons.broken_image_outlined),
              ),
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: Material(
            color: Colors.black.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.all(3),
                child: Icon(Icons.edit, size: 14, color: Colors.white),
              ),
            ),
          ),
        ),
        if (onRemove != null)
          Positioned(
            bottom: 4,
            right: 4,
            child: Material(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: onRemove,
                child: const Padding(
                  padding: EdgeInsets.all(2),
                  child: Icon(Icons.close, size: 14, color: Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
