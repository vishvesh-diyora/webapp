import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webapp/core/config/cloudflare_config.dart';
import 'package:webapp/features/cloudflare/data/cloudflare_publish_repository.dart';

/// Asks for a unique publish username before deploying to Cloudflare Pages.
Future<String?> showPublishUsernameDialog(
  BuildContext context, {
  required CloudflarePublishRepository publishRepository,
  String? initialUsername,
  String? websiteId,
}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => MediaQuery.withClampedTextScaling(
      minScaleFactor: 0.85,
      maxScaleFactor: 1.15,
      child: PublishUsernameDialog(
        publishRepository: publishRepository,
        initialUsername: initialUsername,
        websiteId: websiteId,
      ),
    ),
  );
}

class PublishUsernameDialog extends StatefulWidget {
  const PublishUsernameDialog({
    super.key,
    required this.publishRepository,
    this.initialUsername,
    this.websiteId,
  });

  final CloudflarePublishRepository publishRepository;
  final String? initialUsername;
  final String? websiteId;

  @override
  State<PublishUsernameDialog> createState() => _PublishUsernameDialogState();
}

class _PublishUsernameDialogState extends State<PublishUsernameDialog> {
  late final TextEditingController _controller;
  Timer? _debounce;
  String? _validationError;
  String? _availabilityError;
  bool _checking = false;
  bool? _isAvailable;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialUsername ?? '');
    _controller.addListener(_onTextChanged);
    if (_controller.text.isNotEmpty) {
      _scheduleAvailabilityCheck();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _validationError = null;
      _availabilityError = null;
      _isAvailable = null;
    });
    _scheduleAvailabilityCheck();
  }

  void _scheduleAvailabilityCheck() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _checkAvailability);
  }

  Future<void> _checkAvailability() async {
    final raw = _controller.text;
    final username = normalizeUsername(raw);
    final validationError = PublishUsername.validate(username);
    if (validationError != null) {
      setState(() {
        _validationError = validationError;
        _checking = false;
        _isAvailable = null;
      });
      return;
    }

    setState(() => _checking = true);
    final result = await widget.publishRepository.checkUsernameAvailability(
      username: username,
      excludeWebsiteId: widget.websiteId,
      ownedProjectName: widget.initialUsername,
    );
    if (!mounted) return;
    setState(() {
      _checking = false;
      _isAvailable = result.isAvailable;
      _availabilityError = result.isAvailable ? null : result.message;
    });
  }

  Future<void> _publish() async {
    final username = normalizeUsername(_controller.text);
    final validationError = PublishUsername.validate(username);
    if (validationError != null) {
      setState(() => _validationError = validationError);
      return;
    }

    if (_isAvailable != true) {
      await _checkAvailability();
      if (_isAvailable != true) {
        setState(() {
          _availabilityError ??= 'Choose an available username.';
        });
        return;
      }
    }

    if (!mounted) return;
    Navigator.of(context).pop(username);
  }

  @override
  Widget build(BuildContext context) {
    final username = normalizeUsername(_controller.text);
    final previewUrl = username.isNotEmpty
        ? CloudflareConfig.pagesUrlForUsername(username)
        : 'https://yourname.pages.dev';
    final fieldError = _validationError;

    return AlertDialog(
      title: const Text('Choose your website address'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Pick a unique username. Your site will be published at:',
              ),
              const SizedBox(height: 8),
              Text(
                previewUrl,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Username',
                  hintText: 'my-portfolio',
                  errorText: fieldError,
                  suffixIcon: _checking
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : _isAvailable == true
                          ? const Icon(
                              Icons.check_circle,
                              color: Color(0xFF16A34A),
                            )
                          : null,
                  border: const OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _publish(),
              ),
              if (_availabilityError != null && fieldError == null) ...[
                const SizedBox(height: 8),
                Text(
                  _availabilityError!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _publish,
          child: const Text('Publish'),
        ),
      ],
    );
  }
}
