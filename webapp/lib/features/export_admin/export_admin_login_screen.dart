import 'package:flutter/material.dart';
import 'package:webapp/features/export_admin/export_admin_dev_flags.dart';
import 'package:webapp/features/export_admin/export_admin_session.dart';
import 'package:webapp/features/export_admin/export_remote_config_keys.dart';
import 'package:webapp/features/export_admin/export_viewer_config_load_result.dart';
import 'package:webapp/features/export_admin/export_viewer_public_nav.dart';

class ExportAdminLoginScreen extends StatefulWidget {
  const ExportAdminLoginScreen({
    super.key,
    required this.loadResult,
    required this.onLoggedIn,
  });

  final ExportViewerConfigLoadResult loadResult;
  final VoidCallback onLoggedIn;

  @override
  State<ExportAdminLoginScreen> createState() => _ExportAdminLoginScreenState();
}

class _ExportAdminLoginScreenState extends State<ExportAdminLoginScreen> {
  final _user = TextEditingController();
  final _pass = TextEditingController();
  String? _error;

  ExportViewerConfigLoadResult get _result => widget.loadResult;

  @override
  void dispose() {
    _user.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_result.canValidateLogin) {
      setState(() {
        _error = 'Sign-in is not available until server admin credentials are configured (see below).';
      });
      return;
    }
    final ok = _user.text.trim() == _result.config.adminUsername &&
        _pass.text == _result.config.adminPassword;
    if (!ok) {
      setState(() => _error = 'Invalid username or password');
      return;
    }
    _completeLogin();
  }

  void _completeLogin() {
    exportAdminSetLoggedIn(true);
    widget.onLoggedIn();
  }

  void _bypassForTesting() {
    exportAdminSetLoggedIn(true);
    widget.onLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final blockers = _result.loginBlockers;

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      appBar: AppBar(
        title: const Text('Admin'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Sign in',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Credentials come from Firebase Remote Config on this hosted site. '
                      'For local testing only, you may set adminUsername / adminPassword in runtime-config.json.',
                      style: theme.textTheme.bodySmall,
                    ),
                    if (blockers.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Configuration',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: theme.colorScheme.onErrorContainer,
                              ),
                            ),
                            const SizedBox(height: 8),
                            for (final line in blockers)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  '• $line',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onErrorContainer,
                                  ),
                                ),
                              ),
                            if (_result.missingGithubKeys.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'After login, Save / uploads need: ${_result.missingGithubKeys.join(', ')}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onErrorContainer,
                                ),
                              ),
                            ],
                            const SizedBox(height: 4),
                            Text(
                              'Required Remote Config keys: ${ExportRemoteConfigKeys.allKeys.join(', ')}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onErrorContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    TextField(
                      controller: _user,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                      ),
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _pass,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      onSubmitted: (_) => _submit(),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ],
                    const SizedBox(height: 20),
                    FilledButton(onPressed: _submit, child: const Text('Sign in')),
                    if (kExportAdminShowBypassForTesting) ...[
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _bypassForTesting,
                        child: const Text('Bypass for testing'),
                      ),
                      Text(
                        'Testing only — hide via export_admin_dev_flags.dart',
                        style: theme.textTheme.labelSmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: exportViewerOpenPublicSiteImpl,
                      child: const Text('Back to website'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
