import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webapp/core/config/cloudflare_config.dart';
import 'package:webapp/features/cloudflare/data/cloudflare_oauth_service.dart';
import 'package:webapp/features/cloudflare/data/cloudflare_publish_repository.dart';
import 'package:webapp/features/cloudflare/data/cloudflare_service.dart';
import 'package:webapp/features/cloudflare/presentation/bloc/cloudflare_state.dart';
import 'package:webapp/features/website/domain/entities/website_document.dart';
import 'package:webapp/features/website/domain/repositories/website_repository.dart';

export 'cloudflare_state.dart';

class CloudflareBloc extends Bloc<CloudflareEvent, CloudflareState> {
  CloudflareBloc({
    required CloudflarePublishRepository publishRepository,
    required CloudflareOAuthService oauthService,
    required WebsiteRepository websiteRepository,
  })  : _publishRepository = publishRepository,
        _oauthService = oauthService,
        _websiteRepository = websiteRepository,
        super(const CloudflareInitial()) {
    on<CloudflareStarted>(_onStarted);
    on<CloudflareConnectRequested>(_onConnectRequested);
    on<CloudflareDisconnectRequested>(_onDisconnectRequested);
    on<CloudflarePublishRequested>(_onPublishRequested);
    on<CloudflarePublishRetry>(_onPublishRetry);
  }

  final CloudflarePublishRepository _publishRepository;
  final CloudflareOAuthService _oauthService;
  final WebsiteRepository _websiteRepository;

  WebsiteDocument? _lastFailedDocument;

  Future<void> _onStarted(CloudflareStarted event, Emitter<CloudflareState> emit) async {
    await _oauthService.completeWebCallbackIfPresent();

    final connected = await _publishRepository.isCloudflareConnected();
    emit(connected ? const CloudflareConnected() : const CloudflareDisconnected());

    final pendingId = await _publishRepository.takePendingPublishWebsiteId();
    if (pendingId == null || !connected) return;

    final sites = await _websiteRepository.fetchWebsites();
    final document = sites.where((s) => s.id == pendingId).firstOrNull;
    if (document != null) {
      add(CloudflarePublishRequested(document));
    }
  }

  Future<void> _onConnectRequested(
    CloudflareConnectRequested event,
    Emitter<CloudflareState> emit,
  ) async {
    emit(const CloudflareConnecting());
    try {
      CloudflareConfig.assertConfigured();

      final doc = event.resumePublishDocument;
      if (doc?.id != null) {
        await _publishRepository.markPendingPublish(doc!.id!);
      }

      if (kIsWeb) {
        await _oauthService.connect();
        return;
      }

      await _oauthService.connect();
      emit(const CloudflareConnected());

      if (doc != null) {
        add(CloudflarePublishRequested(doc));
      }
    } on CloudflareOAuthException catch (error) {
      emit(CloudflareConnectFailure(error.message));
      emit(const CloudflareDisconnected());
    } catch (error) {
      emit(CloudflareConnectFailure(error.toString()));
      emit(const CloudflareDisconnected());
    }
  }

  Future<void> _onDisconnectRequested(
    CloudflareDisconnectRequested event,
    Emitter<CloudflareState> emit,
  ) async {
    await _oauthService.disconnect();
    emit(const CloudflareDisconnected());
  }

  Future<void> _onPublishRequested(
    CloudflarePublishRequested event,
    Emitter<CloudflareState> emit,
  ) async {
    final document = event.document;
    _lastFailedDocument = document;

    if (!CloudflareConfig.isConfigured) {
      emit(
        CloudflarePublishFailure(
          message:
              'Cloudflare OAuth is not configured. Build with CLOUDFLARE_OAUTH_CLIENT_ID.',
          document: document,
        ),
      );
      return;
    }

    final connected = await _publishRepository.isCloudflareConnected();
    if (!connected) {
      emit(
        CloudflarePublishFailure(
          message: 'Connect Cloudflare to publish your website.',
          document: document,
          needsConnect: true,
        ),
      );
      return;
    }

    emit(CloudflarePublishing(stage: 'Starting', progress: 0, document: document));

    try {
      final result = await _publishRepository.publish(
        document: document,
        onProgress: (stage, progress) {
          if (!emit.isDone) {
            emit(CloudflarePublishing(stage: stage, progress: progress, document: document));
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
    } on CloudflareOAuthException catch (error) {
      emit(
        CloudflarePublishFailure(
          message: error.message,
          document: document,
          needsConnect: true,
        ),
      );
    } on CloudflareApiException catch (error) {
      emit(
        CloudflarePublishFailure(
          message: error.message,
          document: document,
        ),
      );
    } catch (error) {
      emit(
        CloudflarePublishFailure(
          message: error.toString(),
          document: document,
        ),
      );
    }
  }

  Future<void> _onPublishRetry(
    CloudflarePublishRetry event,
    Emitter<CloudflareState> emit,
  ) async {
    final document = _lastFailedDocument;
    if (document == null) return;
    add(CloudflarePublishRequested(document));
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    return iterator.current;
  }
}
