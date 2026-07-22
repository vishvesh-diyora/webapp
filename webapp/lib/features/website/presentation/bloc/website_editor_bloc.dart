import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webapp/core/services/image_asset_service.dart';
import 'package:webapp/features/website/domain/entities/website_document.dart';
import 'package:webapp/features/website/domain/repositories/website_repository.dart';
import 'package:webapp/features/website/presentation/bloc/website_editor_state.dart';

export 'website_editor_state.dart';

class WebsiteEditorBloc extends Bloc<WebsiteEditorEvent, WebsiteEditorState> {
  WebsiteEditorBloc({
    required WebsiteRepository repository,
  })  : _repository = repository,
        super(const WebsiteEditorInitial()) {
    on<WebsiteEditorStarted>(_onStarted);
    on<WebsiteEditorFieldChanged>(_onFieldChanged);
    on<WebsiteEditorMetaChanged>(_onMetaChanged);
    on<WebsiteEditorListItemChanged>(_onListItemChanged);
    on<WebsiteEditorListItemAdded>(_onListItemAdded);
    on<WebsiteEditorListItemRemoved>(_onListItemRemoved);
    on<WebsiteEditorImagePicked>(_onImagePicked);
    on<WebsiteEditorSaved>(_onSaved);
  }

  final WebsiteRepository _repository;

  WebsiteDocument _touch(WebsiteDocument document) =>
      document.copyWith(updatedAt: DateTime.now());

  void _onStarted(WebsiteEditorStarted event, Emitter<WebsiteEditorState> emit) {
    emit(WebsiteEditorReady(document: event.document));
  }

  void _onFieldChanged(WebsiteEditorFieldChanged event, Emitter<WebsiteEditorState> emit) {
    final current = state;
    if (current is! WebsiteEditorReady) return;
    emit(
      current.copyWith(
        document: _touch(current.document.updateBlockField(
          event.contentType,
          event.field,
          event.value,
        )),
        message: null,
      ),
    );
  }

  void _onMetaChanged(WebsiteEditorMetaChanged event, Emitter<WebsiteEditorState> emit) {
    final current = state;
    if (current is! WebsiteEditorReady) return;
    emit(
      current.copyWith(
        document: _touch(current.document.copyWith(
          name: event.name ?? current.document.name,
          subname: event.subname ?? current.document.subname,
          description: event.description ?? current.document.description,
          logo: event.logo ?? current.document.logo,
        )),
        message: null,
      ),
    );
  }

  void _onListItemChanged(WebsiteEditorListItemChanged event, Emitter<WebsiteEditorState> emit) {
    final current = state;
    if (current is! WebsiteEditorReady) return;
    emit(
      current.copyWith(
        document: _touch(current.document.updateListItem(
          contentType: event.contentType,
          listKey: event.listKey,
          index: event.index,
          item: event.item,
        )),
        message: null,
      ),
    );
  }

  void _onListItemAdded(WebsiteEditorListItemAdded event, Emitter<WebsiteEditorState> emit) {
    final current = state;
    if (current is! WebsiteEditorReady) return;
    emit(
      current.copyWith(
        document: _touch(current.document.addListItem(
          contentType: event.contentType,
          listKey: event.listKey,
          item: event.item,
        )),
        message: null,
      ),
    );
  }

  void _onListItemRemoved(WebsiteEditorListItemRemoved event, Emitter<WebsiteEditorState> emit) {
    final current = state;
    if (current is! WebsiteEditorReady) return;
    emit(
      current.copyWith(
        document: _touch(current.document.removeListItem(
          contentType: event.contentType,
          listKey: event.listKey,
          index: event.index,
        )),
        message: null,
      ),
    );
  }

  Future<void> _onImagePicked(WebsiteEditorImagePicked event, Emitter<WebsiteEditorState> emit) async {
    final current = state;
    if (current is! WebsiteEditorReady) return;
    final path = await ImageAssetService.pickAndStore();
    if (path == null) return;

    WebsiteDocument document;
    if (event.field == 'logo' && event.listKey == null) {
      document = _touch(current.document.copyWith(logo: path));
    } else if (event.listKey != null && event.listIndex != null && event.listField != null) {
      final block = current.document.blockByContentType(event.contentType);
      if (block == null) return;
      final list = List<Map<String, dynamic>>.from(
        (block.contentData[event.listKey!] as List?)?.whereType<Map<String, dynamic>>() ?? const [],
      );
      if (event.listIndex! >= list.length) return;
      final item = Map<String, dynamic>.from(list[event.listIndex!]);
      item[event.listField!] = path;
      document = _touch(current.document.updateListItem(
        contentType: event.contentType,
        listKey: event.listKey!,
        index: event.listIndex!,
        item: item,
      ));
    } else {
      document = _touch(current.document.updateBlockField(event.contentType, event.field, path));
    }

    emit(current.copyWith(document: document, message: null));
  }

  Future<void> _onSaved(WebsiteEditorSaved event, Emitter<WebsiteEditorState> emit) async {
    final current = state;
    if (current is! WebsiteEditorReady) return;
    emit(current.copyWith(isSaving: true, message: null));
    try {
      final saved = await _repository.saveWebsite(current.document);
      emit(current.copyWith(isSaving: false, document: saved, message: 'Saved'));
    } catch (error) {
      emit(current.copyWith(isSaving: false, message: error.toString()));
    }
  }
}
