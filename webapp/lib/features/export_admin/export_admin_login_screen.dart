import 'package:flutter/material.dart';
import 'package:webapp/features/export_admin/export_admin_session.dart';
import 'package:webapp/features/export_admin/export_runtime_config.dart';

class ExportAdminLoginScreen extends StatefulWidget {
  const ExportAdminLoginScreen({
    super.key,
    required this.config,
    required this.onLoggedIn,
  });

  final ExportRuntimeConfig config;
  final VoidCallback onLoggedIn;

  @override
  State<ExportAdminLoginScreen> createState() => _ExportAdminLoginScreenState();
}

class _ExportAdminLoginScreenState extends State<ExportAdminLoginScreen> {
  final _user = TextEditingController();
  final _pass = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _user.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _submit() {
    final ok = _user.text.trim() == widget.config.adminUsername &&
        _pass.text == widget.config.adminPassword;
    if (!ok) {
      setState(() => _error = 'Invalid username or password');
      return;
    }
    exportAdminSetLoggedIn(true);
    widget.onLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin sign in')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _user,
                  decoration: const InputDecoration(labelText: 'Username'),
                  autocorrect: false,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _pass,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  onSubmitted: (_) => _submit(),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
                const SizedBox(height: 20),
                FilledButton(onPressed: _submit, child: const Text('Sign in')),
                const SizedBox(height: 16),
                Text(
                  widget.config.secretsFromFirebase
                      ? 'Admin login is loaded from Firebase Remote Config (not stored in your Cloudflare files).'
                      : 'Configure firebase-config.json and Remote Config (see ADMIN_SETUP.md), or legacy runtime-config.json for local dev only.',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
