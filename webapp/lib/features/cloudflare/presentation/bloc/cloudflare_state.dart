import 'package:equatable/equatable.dart';
import 'package:webapp/features/cloudflare/domain/entities/website_deployment_info.dart';
import 'package:webapp/features/website/domain/entities/website_document.dart';

abstract class CloudflareEvent extends Equatable {
  const CloudflareEvent();

  @override
  List<Object?> get props => [];
}

class CloudflareStarted extends CloudflareEvent {
  const CloudflareStarted();
}

class CloudflareConnectRequested extends CloudflareEvent {
  const CloudflareConnectRequested({this.resumePublishDocument});

  final WebsiteDocument? resumePublishDocument;

  @override
  List<Object?> get props => [resumePublishDocument];
}

class CloudflareDisconnectRequested extends CloudflareEvent {
  const CloudflareDisconnectRequested();
}

class CloudflarePublishRequested extends CloudflareEvent {
  const CloudflarePublishRequested(this.document);

  final WebsiteDocument document;

  @override
  List<Object?> get props => [document];
}

class CloudflarePublishRetry extends CloudflareEvent {
  const CloudflarePublishRetry();
}

abstract class CloudflareState extends Equatable {
  const CloudflareState();

  @override
  List<Object?> get props => [];
}

class CloudflareInitial extends CloudflareState {
  const CloudflareInitial();
}

class CloudflareDisconnected extends CloudflareState {
  const CloudflareDisconnected();
}

class CloudflareConnected extends CloudflareState {
  const CloudflareConnected();
}

class CloudflareConnecting extends CloudflareState {
  const CloudflareConnecting();
}

class CloudflarePublishing extends CloudflareState {
  const CloudflarePublishing({
    required this.stage,
    required this.progress,
    required this.document,
  });

  final String stage;
  final double progress;
  final WebsiteDocument document;

  @override
  List<Object?> get props => [stage, progress, document];
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
    this.needsConnect = false,
  });

  final String message;
  final WebsiteDocument document;
  final bool needsConnect;

  @override
  List<Object?> get props => [message, document, needsConnect];
}

class CloudflareConnectFailure extends CloudflareState {
  const CloudflareConnectFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
