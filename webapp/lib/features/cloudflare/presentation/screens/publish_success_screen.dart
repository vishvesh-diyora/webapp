import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class PublishSuccessScreen extends StatelessWidget {
  const PublishSuccessScreen({
    super.key,
    required this.url,
    required this.onDone,
  });

  final String url;
  final VoidCallback onDone;

  Future<void> _openSite() async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Published')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.check_circle_rounded, size: 72, color: Colors.green.shade600),
            const SizedBox(height: 16),
            Text(
              'Your website is live on Cloudflare Pages',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SelectableText(
              url,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _openSite,
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('Open website'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: url));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('URL copied')),
                );
              },
              icon: const Icon(Icons.copy_rounded),
              label: const Text('Copy URL'),
            ),
            const Spacer(),
            FilledButton(onPressed: onDone, child: const Text('Done')),
          ],
        ),
      ),
    );
  }
}
