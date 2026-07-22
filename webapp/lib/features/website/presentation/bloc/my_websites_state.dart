import 'package:equatable/equatable.dart';
import 'package:webapp/features/website/domain/entities/website_document.dart';

abstract class MyWebsitesEvent extends Equatable {
  const MyWebsitesEvent();

  @override
  List<Object?> get props => [];
}

class MyWebsitesRequested extends MyWebsitesEvent {
  const MyWebsitesRequested();
}

class MyWebsitesDeleted extends MyWebsitesEvent {
  const MyWebsitesDeleted(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}

abstract class MyWebsitesState extends Equatable {
  const MyWebsitesState();

  @override
  List<Object?> get props => [];
}

class MyWebsitesLoading extends MyWebsitesState {
  const MyWebsitesLoading();
}

class MyWebsitesReady extends MyWebsitesState {
  const MyWebsitesReady(this.websites);

  final List<WebsiteDocument> websites;

  @override
  List<Object?> get props => [websites];
}

class MyWebsitesFailure extends MyWebsitesState {
  const MyWebsitesFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
