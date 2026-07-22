import 'package:flutter/material.dart';

class PublishFailureScreen extends StatelessWidget {
  const PublishFailureScreen({
    super.key,
    required this.message,
    required this.onRetry,
    required this.onConnect,
    required this.onClose,
    this.needsConnect = false,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onConnect;
  final VoidCallback onClose;
  final bool needsConnect;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Publish failed')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.error_outline_rounded, size: 72, color: Colors.red.shade600),
            const SizedBox(height: 16),
            Text(
              'We could not publish your website',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const Spacer(),
            if (needsConnect)
              FilledButton.icon(
                onPressed: onConnect,
                icon: const Icon(Icons.link_rounded),
                label: const Text('Connect Cloudflare'),
              ),
            if (needsConnect) const SizedBox(height: 8),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
            const SizedBox(height: 8),
            TextButton(onPressed: onClose, child: const Text('Close')),
          ],
        ),
      ),
    );
  }
}
