import 'package:equatable/equatable.dart';
import 'package:webapp/features/cloudflare/domain/entities/website_deployment_info.dart';
import 'package:webapp/features/website/domain/entities/website_document.dart';

abstract class CloudflareEvent extends Equatable {
  const CloudflareEvent();

  @override
  List<Object?> get props => [];
}

class CloudflarePublishRequested extends CloudflareEvent {
  const CloudflarePublishRequested({
    required this.document,
    required this.username,
  });

  final WebsiteDocument document;
  final String username;

  @override
  List<Object?> get props => [document, username];
}

class CloudflarePublishRetry extends CloudflareEvent {
  const CloudflarePublishRetry();
}

abstract class CloudflareState extends Equatable {
  const CloudflareState();

  @override
  List<Object?> get props => [];
}

class CloudflareIdle extends CloudflareState {
  const CloudflareIdle();
}

class CloudflarePublishing extends CloudflareState {
  const CloudflarePublishing({
    required this.stage,
    required this.progress,
    required this.document,
    required this.username,
  });

  final String stage;
  final double progress;
  final WebsiteDocument document;
  final String username;

  @override
  List<Object?> get props => [stage, progress, document, username];
}

class CloudflarePublishSuccess extends CloudflareState {
  const CloudflarePublishSuccess({
    required this.url,
    required this.deployment,
    required this.document,
  });

  final String url;
  final WebsiteDeploymentInfo deployment;
  final WebsiteDocument document;

  @override
  List<Object?> get props => [url, deployment, document];
}

class CloudflarePublishFailure extends CloudflareState {
  const CloudflarePublishFailure({
    required this.message,
    required this.document,
    required this.username,
  });

  final String message;
  final WebsiteDocument document;
  final String username;

  @override
  List<Object?> get props => [message, document, username];
}
