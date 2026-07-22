import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webapp/features/website/domain/repositories/website_repository.dart';
import 'package:webapp/features/website/presentation/bloc/my_websites_state.dart';

export 'my_websites_state.dart';

class MyWebsitesBloc extends Bloc<MyWebsitesEvent, MyWebsitesState> {
  MyWebsitesBloc({required WebsiteRepository repository})
      : _repository = repository,
        super(const MyWebsitesLoading()) {
    on<MyWebsitesRequested>(_onRequested);
    on<MyWebsitesDeleted>(_onDeleted);
    add(const MyWebsitesRequested());
  }

  final WebsiteRepository _repository;

  Future<void> _onRequested(
    MyWebsitesRequested event,
    Emitter<MyWebsitesState> emit,
  ) async {
    emit(const MyWebsitesLoading());
    try {
      final websites = await _repository.fetchWebsites();
      emit(MyWebsitesReady(websites));
    } catch (error) {
      emit(MyWebsitesFailure(error.toString()));
    }
  }

  Future<void> _onDeleted(
    MyWebsitesDeleted event,
    Emitter<MyWebsitesState> emit,
  ) async {
    try {
      await _repository.deleteWebsite(event.id);
      add(const MyWebsitesRequested());
    } catch (error) {
      emit(MyWebsitesFailure(error.toString()));
    }
  }
}
