import 'package:flutter/material.dart';

class PublishProgressDialog extends StatelessWidget {
  const PublishProgressDialog({
    super.key,
    required this.stage,
    required this.progress,
  });

  final String stage;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: const Text('Publishing to Cloudflare'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(value: progress.clamp(0, 1)),
            const SizedBox(height: 16),
            Text(stage, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
