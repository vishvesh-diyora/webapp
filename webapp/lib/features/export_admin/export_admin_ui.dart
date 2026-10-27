import 'package:flutter/material.dart';

/// Shared chrome for the exported-site admin editor.
class ExportAdminSectionCard extends StatelessWidget {
  const ExportAdminSectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.6)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 20, color: theme.colorScheme.onPrimaryContainer),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class ExportAdminCompactImageButton extends StatelessWidget {
  const ExportAdminCompactImageButton({
    super.key,
    required this.imageUrl,
    required this.onTap,
    this.size = 56,
    this.width,
    this.height,
    this.shape = BoxShape.circle,
    this.icon = Icons.add_a_photo_outlined,
  });

  final String? imageUrl;
  final VoidCallback onTap;
  final double size;
  final double? width;
  final double? height;
  final BoxShape shape;
  final IconData icon;

  bool get _has => imageUrl != null && imageUrl!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = shape == BoxShape.circle ? null : BorderRadius.circular(12);
    return Material(
      color: theme.colorScheme.surfaceContainerHigh,
      shape: shape == BoxShape.circle
          ? const CircleBorder()
          : RoundedRectangleBorder(borderRadius: radius!),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: shape == BoxShape.circle
            ? const CircleBorder()
            : RoundedRectangleBorder(borderRadius: radius!),
        child: SizedBox(
          width: width ?? size,
          height: height ?? size,
          child: _has
              ? Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(icon, color: theme.colorScheme.outline),
                )
              : Icon(icon, size: size * 0.38, color: theme.colorScheme.outline),
        ),
      ),
    );
  }
}

/// Admin image with a Change control so it is obvious the photo can be replaced.
class ExportAdminEditableImage extends StatelessWidget {
  const ExportAdminEditableImage({
    super.key,
    required this.imageUrl,
    required this.onChange,
    this.height = 160,
    this.width,
  });

  final String? imageUrl;
  final VoidCallback onChange;
  final double height;
  final double? width;

  bool get _has => imageUrl != null && imageUrl!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final compact = width != null && width! < 140;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: width ?? double.infinity,
          height: height,
          child: Stack(
            children: [
              Positioned.fill(
                child: Material(
                  color: theme.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(14),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: onChange,
                    child: _has
                        ? Image.network(
                            imageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: height,
                            errorBuilder: (_, _, _) => Icon(
                              Icons.broken_image_outlined,
                              color: theme.colorScheme.outline,
                            ),
                          )
                        : Icon(Icons.add_photo_alternate_outlined, color: theme.colorScheme.outline),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.black.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: onChange,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 10, vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.edit, size: 14, color: Colors.white),
                          if (!compact) ...[
                            const SizedBox(width: 6),
                            const Text(
                              'Change',
                              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExportAdminAddTile extends StatelessWidget {
  const ExportAdminAddTile({
    super.key,
    required this.label,
    required this.onTap,
    this.width = 72,
    this.height = 72,
  });

  final String label;
  final VoidCallback onTap;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: width,
          height: height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 22, color: theme.colorScheme.primary),
              const SizedBox(height: 4),
              Text(label, style: theme.textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}

InputDecoration exportAdminInputDecoration(BuildContext context, String label) {
  return InputDecoration(
    labelText: label,
    isDense: true,
    filled: true,
    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Theme.of(context).dividerColor),
    ),
  );
}
