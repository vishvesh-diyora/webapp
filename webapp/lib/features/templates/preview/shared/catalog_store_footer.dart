import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webapp/features/templates/preview/layout_theme.dart';

/// Contact + social footer for ecommerce, restaurant, and business profile previews.
class CatalogStoreFooter extends StatelessWidget {
  const CatalogStoreFooter({
    super.key,
    required this.primary,
    required this.theme,
    required this.compact,
  });

  final Map<String, dynamic> primary;
  final LayoutTheme theme;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final email = primary['email'] as String? ?? '';
    final address = primary['address'] as String? ?? '';
    final phone = _displayPhone(primary);
    final social = _resolveSocialLinks(primary);

    if (email.isEmpty && address.isEmpty && phone.isEmpty && social.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: theme.pad(compact),
      color: theme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (phone.isNotEmpty) ...[
            _phoneRow(phone),
            SizedBox(height: compact ? 8 : 10),
          ],
          if (email.isNotEmpty) ...[
            _row(Icons.mail_outline_rounded, email),
            SizedBox(height: compact ? 8 : 10),
          ],
          if (address.isNotEmpty) ...[
            _row(Icons.location_on_outlined, address),
            SizedBox(height: compact ? 12 : 14),
          ],
          if (social.isNotEmpty)
            Wrap(
              spacing: compact ? 10 : 12,
              runSpacing: compact ? 10 : 12,
              children: [
                for (final link in social)
                  _SocialIconButton(
                    icon: link.icon,
                    url: link.url,
                    theme: theme,
                    compact: compact,
                  ),
              ],
            ),
        ],
      ),
    );
  }

  static String _displayPhone(Map<String, dynamic> primary) {
    final phone = (primary['phone'] as String? ?? '').trim();
    if (phone.isNotEmpty) return phone;
    return (primary['whatsapp'] as String? ?? '').trim();
  }

  Widget _row(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: compact ? 18 : 20, color: theme.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: theme.body(compact, size: 12))),
      ],
    );
  }

  Widget _phoneRow(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    final canCall = digits.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canCall
            ? () {
                final uri = Uri.parse('tel:$digits');
                launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.phone_outlined, size: compact ? 18 : 20, color: theme.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(phone, style: theme.body(compact, size: 12))),
            ],
          ),
        ),
      ),
    );
  }

  static List<_SocialLink> _resolveSocialLinks(Map<String, dynamic> primary) {
    final links = <_SocialLink>[];
    final seen = <String>{};

    void add(IconData icon, String? url) {
      final trimmed = url?.trim() ?? '';
      if (trimmed.isEmpty || seen.contains(trimmed)) return;
      seen.add(trimmed);
      links.add(_SocialLink(icon: icon, url: trimmed));
    }

    final raw = primary['socialLinks'];
    if (raw is List) {
      for (final item in raw) {
        if (item is! Map) continue;
        final url = item['url'] as String? ?? '';
        final key = (item['icon'] as String? ?? item['platform'] as String? ?? '').toLowerCase();
        add(_iconForKey(key), url);
      }
    }

    add(Icons.camera_alt_outlined, primary['instagram'] as String?);
    add(Icons.facebook_rounded, primary['facebook'] as String?);
    add(Icons.chat_rounded, _whatsappUrl(primary['whatsapp'] as String?));
    add(Icons.alternate_email_rounded, primary['twitter'] as String?);
    add(Icons.work_outline_rounded, primary['linkedin'] as String?);

    return links;
  }

  static String? _whatsappUrl(String? phone) {
    if (phone == null || phone.trim().isEmpty) return null;
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    return 'https://wa.me/$digits';
  }

  static IconData _iconForKey(String key) {
    if (key.contains('insta')) return Icons.camera_alt_outlined;
    if (key.contains('face')) return Icons.facebook_rounded;
    if (key.contains('whats')) return Icons.chat_rounded;
    if (key.contains('twit') || key.contains('x')) return Icons.alternate_email_rounded;
    if (key.contains('link')) return Icons.work_outline_rounded;
    return Icons.link_rounded;
  }
}

class _SocialLink {
  const _SocialLink({required this.icon, required this.url});
  final IconData icon;
  final String url;
}

class _SocialIconButton extends StatelessWidget {
  const _SocialIconButton({
    required this.icon,
    required this.url,
    required this.theme,
    required this.compact,
  });

  final IconData icon;
  final String url;
  final LayoutTheme theme;
  final bool compact;

  Future<void> _open() async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final size = compact ? 40.0 : 44.0;
    return Material(
      color: theme.primary.withValues(alpha: 0.1),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: _open,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: compact ? 20 : 22, color: theme.primary),
        ),
      ),
    );
  }
}
