import 'package:equatable/equatable.dart';
import 'package:webapp/features/website/domain/entities/website_document.dart';

abstract class WebsiteEditorEvent extends Equatable {
  const WebsiteEditorEvent();

  @override
  List<Object?> get props => [];
}

class WebsiteEditorStarted extends WebsiteEditorEvent {
  const WebsiteEditorStarted(this.document);
  final WebsiteDocument document;

  @override
  List<Object?> get props => [document];
}

class WebsiteEditorFieldChanged extends WebsiteEditorEvent {
  const WebsiteEditorFieldChanged({
    required this.contentType,
    required this.field,
    required this.value,
  });

  final int contentType;
  final String field;
  final dynamic value;

  @override
  List<Object?> get props => [contentType, field, value];
}

class WebsiteEditorMetaChanged extends WebsiteEditorEvent {
  const WebsiteEditorMetaChanged({this.name, this.subname, this.description, this.logo});

  final String? name;
  final String? subname;
  final String? description;
  final String? logo;

  @override
  List<Object?> get props => [name, subname, description, logo];
}

class WebsiteEditorSaved extends WebsiteEditorEvent {
  const WebsiteEditorSaved();
}

class WebsiteEditorListItemChanged extends WebsiteEditorEvent {
  const WebsiteEditorListItemChanged({
    required this.contentType,
    required this.listKey,
    required this.index,
    required this.item,
  });

  final int contentType;
  final String listKey;
  final int index;
  final Map<String, dynamic> item;

  @override
  List<Object?> get props => [contentType, listKey, index, item];
}

class WebsiteEditorListItemAdded extends WebsiteEditorEvent {
  const WebsiteEditorListItemAdded({
    required this.contentType,
    required this.listKey,
    required this.item,
  });

  final int contentType;
  final String listKey;
  final Map<String, dynamic> item;

  @override
  List<Object?> get props => [contentType, listKey, item];
}

class WebsiteEditorListItemRemoved extends WebsiteEditorEvent {
  const WebsiteEditorListItemRemoved({
    required this.contentType,
    required this.listKey,
    required this.index,
  });

  final int contentType;
  final String listKey;
  final int index;

  @override
  List<Object?> get props => [contentType, listKey, index];
}

class WebsiteEditorImagePicked extends WebsiteEditorEvent {
  const WebsiteEditorImagePicked({
    required this.contentType,
    required this.field,
    this.listKey,
    this.listIndex,
    this.listField,
  });

  final int contentType;
  final String field;
  final String? listKey;
  final int? listIndex;
  final String? listField;

  @override
  List<Object?> get props => [contentType, field, listKey, listIndex, listField];
}

abstract class WebsiteEditorState extends Equatable {
  const WebsiteEditorState();

  @override
  List<Object?> get props => [];
}

class WebsiteEditorInitial extends WebsiteEditorState {
  const WebsiteEditorInitial();
}

class WebsiteEditorReady extends WebsiteEditorState {
  const WebsiteEditorReady({
    required this.document,
    this.isSaving = false,
    this.message,
  });

  final WebsiteDocument document;
  final bool isSaving;
  final String? message;

  WebsiteEditorReady copyWith({
    WebsiteDocument? document,
    bool? isSaving,
    String? message,
  }) {
    return WebsiteEditorReady(
      document: document ?? this.document,
      isSaving: isSaving ?? this.isSaving,
      message: message,
    );
  }

  @override
  List<Object?> get props => [document, isSaving, message];
}

class WebsiteEditorFailure extends WebsiteEditorState {
  const WebsiteEditorFailure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
