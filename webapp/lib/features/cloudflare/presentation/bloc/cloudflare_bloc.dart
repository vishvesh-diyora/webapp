import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webapp/core/config/cloudflare_config.dart';
import 'package:webapp/features/cloudflare/data/cloudflare_publish_repository.dart';
import 'package:webapp/features/cloudflare/data/cloudflare_service.dart';
import 'package:webapp/features/cloudflare/presentation/bloc/cloudflare_state.dart';
import 'package:webapp/features/website/domain/entities/website_document.dart';

export 'cloudflare_state.dart';

class CloudflareBloc extends Bloc<CloudflareEvent, CloudflareState> {
  CloudflareBloc({
    required CloudflarePublishRepository publishRepository,
  })  : _publishRepository = publishRepository,
        super(const CloudflareIdle()) {
    on<CloudflarePublishRequested>(_onPublishRequested);
    on<CloudflarePublishRetry>(_onPublishRetry);
  }

  final CloudflarePublishRepository _publishRepository;

  WebsiteDocument? _lastFailedDocument;
  String? _lastFailedUsername;

  Future<void> _onPublishRequested(
    CloudflarePublishRequested event,
    Emitter<CloudflareState> emit,
  ) async {
    final document = event.document;
    final username = event.username;
    _lastFailedDocument = document;
    _lastFailedUsername = username;

    if (!CloudflareConfig.isConfigured) {
      emit(
        CloudflarePublishFailure(
          message:
              'Publishing is not configured. Add Cloudflare credentials to your .env file.',
          document: document,
          username: username,
        ),
      );
      return;
    }

    emit(
      CloudflarePublishing(
        stage: 'Starting',
        progress: 0,
        document: document,
        username: username,
      ),
    );

    try {
      final result = await _publishRepository.publish(
        document: document,
        username: username,
        onProgress: (stage, progress) {
          if (!emit.isDone) {
            emit(
              CloudflarePublishing(
                stage: stage,
                progress: progress,
                document: document,
                username: username,
              ),
            );
          }
        },
      );

      emit(
        CloudflarePublishSuccess(
          url: result.deployment.publishedUrl,
          deployment: result.deployment,
          document: result.document,
        ),
      );
    } on CloudflareApiException catch (error) {
      emit(
        CloudflarePublishFailure(
          message: error.message,
          document: document,
          username: username,
        ),
      );
    } catch (error) {
      emit(
        CloudflarePublishFailure(
          message: error.toString(),
          document: document,
          username: username,
        ),
      );
    }
  }

  Future<void> _onPublishRetry(
    CloudflarePublishRetry event,
    Emitter<CloudflareState> emit,
  ) async {
    final document = _lastFailedDocument;
    final username = _lastFailedUsername;
    if (document == null || username == null) return;
    add(CloudflarePublishRequested(document: document, username: username));
  }
}
