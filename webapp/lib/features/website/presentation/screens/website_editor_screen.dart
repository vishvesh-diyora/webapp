import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:webapp/features/auth/auth_gate_screen.dart';
import 'package:webapp/features/cloudflare/data/cloudflare_publish_repository.dart';
import 'package:webapp/features/cloudflare/presentation/bloc/cloudflare_bloc.dart';
import 'package:webapp/features/cloudflare/presentation/screens/publish_failure_screen.dart';
import 'package:webapp/features/cloudflare/presentation/screens/publish_success_screen.dart';
import 'package:webapp/features/cloudflare/presentation/widgets/publish_progress_dialog.dart';
import 'package:webapp/features/cloudflare/presentation/widgets/publish_username_dialog.dart';
import 'package:webapp/features/templates/preview/website_preview_renderer.dart';
import 'package:webapp/features/website/domain/entities/website_document.dart';
import 'package:webapp/features/website/presentation/bloc/my_websites_bloc.dart';
import 'package:webapp/features/website/presentation/bloc/website_editor_bloc.dart';
import 'package:webapp/features/website/presentation/widgets/content_editor_panel.dart';

class WebsiteEditorScreen extends StatefulWidget {
  const WebsiteEditorScreen({super.key});

  @override
  State<WebsiteEditorScreen> createState() => _WebsiteEditorScreenState();
}

class _WebsiteEditorScreenState extends State<WebsiteEditorScreen> {
  bool _publishDialogOpen = false;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<WebsiteEditorBloc, WebsiteEditorState>(
          listener: (context, state) {
            if (state is WebsiteEditorReady && state.message != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message!)),
              );
            }
          },
        ),
        BlocListener<CloudflareBloc, CloudflareState>(
          listener: (context, state) => _onCloudflareState(context, state),
        ),
      ],
      child: BlocBuilder<WebsiteEditorBloc, WebsiteEditorState>(
        builder: (context, state) {
          if (state is! WebsiteEditorReady) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          final document = state.document;
          final isWide = MediaQuery.sizeOf(context).width >= 900;
          final isPublishing = context.watch<CloudflareBloc>().state is CloudflarePublishing;

          return Scaffold(
            appBar: AppBar(
              title: Text(document.name),
              actions: [
                TextButton(
                  onPressed: state.isSaving
                      ? null
                      : () => context.read<WebsiteEditorBloc>().add(const WebsiteEditorSaved()),
                  child: state.isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
                FilledButton(
                  onPressed: isPublishing ? null : () => _startPublish(context, document),
                  child: isPublishing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Publish'),
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: isWide
                ? Row(
                    children: [
                      Expanded(flex: 4, child: ContentEditorPanel(document: document)),
                      const VerticalDivider(width: 1),
                      Expanded(flex: 6, child: _PreviewPane(document: document)),
                    ],
                  )
                : Column(
                    children: [
                      SizedBox(height: 280, child: _PreviewPane(document: document)),
                      const Divider(height: 1),
                      Expanded(child: ContentEditorPanel(document: document)),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Future<void> _startPublish(BuildContext context, WebsiteDocument document) async {
    if (Supabase.instance.client.auth.currentSession == null) {
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => const AuthGateScreen(modal: true),
        ),
      );
      if (!context.mounted) return;
      if (Supabase.instance.client.auth.currentSession == null) return;
    }

    final username = await showPublishUsernameDialog(
      context,
      publishRepository: context.read<CloudflarePublishRepository>(),
      initialUsername: document.deployment?.projectName,
      websiteId: document.id,
    );
    if (username == null || !context.mounted) return;

    context.read<CloudflareBloc>().add(
          CloudflarePublishRequested(document: document, username: username),
        );
  }

  Future<void> _onCloudflareState(BuildContext context, CloudflareState state) async {
    if (state is CloudflarePublishing) {
      if (!_publishDialogOpen) {
        _publishDialogOpen = true;
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => BlocBuilder<CloudflareBloc, CloudflareState>(
            buildWhen: (previous, current) => current is CloudflarePublishing,
            builder: (_, publishState) {
              if (publishState is CloudflarePublishing) {
                return PublishProgressDialog(
                  stage: publishState.stage,
                  progress: publishState.progress,
                );
              }
              return const PublishProgressDialog(stage: 'Finishing', progress: 1);
            },
          ),
        );
        _publishDialogOpen = false;
      }
      return;
    }

    if (_publishDialogOpen && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      _publishDialogOpen = false;
    }

    if (state is CloudflarePublishSuccess) {
      context.read<WebsiteEditorBloc>().add(WebsiteEditorStarted(state.document));
      context.read<MyWebsitesBloc>().add(const MyWebsitesRequested());

      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => PublishSuccessScreen(
            url: state.url,
            onDone: () => Navigator.of(context).pop(),
          ),
        ),
      );
      return;
    }

    if (state is CloudflarePublishFailure) {
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => PublishFailureScreen(
            message: state.message,
            onRetry: () {
              Navigator.of(context).pop();
              context.read<CloudflareBloc>().add(const CloudflarePublishRetry());
            },
            onClose: () => Navigator.of(context).pop(),
          ),
        ),
      );
    }
  }
}

class _PreviewPane extends StatelessWidget {
  const _PreviewPane({required this.document});
  final WebsiteDocument document;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF1F5F9),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: WebsitePreviewRenderer(
              document: document,
              compact: true,
              mobileProfileLayout: true,
            ),
          ),
        ),
      ),
    );
  }
}
