import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/characters_repository.dart';
import 'characters_state.dart';

class CharactersCubit extends Cubit<CharactersState> {
  CharactersCubit(this._repository) : super(CharactersState());

  final CharactersRepository _repository;
  Timer? _searchTimer;
  int _requestVersion = 0;

  Future<void> loadCharacters() async {
    if (isClosed ||
        state.status == CharactersStatus.loading ||
        state.isLoadingMore) {
      return;
    }
    await _loadFirstPage();
  }

  void searchQueryChanged(String query) {
    if (isClosed || query == state.searchQuery) return;

    _searchTimer?.cancel();
    _requestVersion++;
    emit(CharactersState(status: CharactersStatus.loading, searchQuery: query));
    _searchTimer = Timer(const Duration(milliseconds: 400), _loadFirstPage);
  }

  Future<void> _loadFirstPage() async {
    if (isClosed) return;
    final version = ++_requestVersion;
    final query = state.searchQuery;
    emit(CharactersState(status: CharactersStatus.loading, searchQuery: query));

    try {
      final page = await _repository.getCharacters(page: 1, name: query);
      if (!_isCurrent(version)) return;
      emit(
        CharactersState(
          status: page.characters.isEmpty
              ? CharactersStatus.empty
              : CharactersStatus.success,
          characters: page.characters,
          searchQuery: query,
          nextPage: 2,
          hasMore: page.hasMore,
        ),
      );
    } catch (_) {
      if (!_isCurrent(version)) return;
      emit(
        CharactersState(
          status: CharactersStatus.failure,
          searchQuery: query,
          errorMessage: 'Не удалось загрузить персонажей. Попробуйте ещё раз.',
        ),
      );
    }
  }

  Future<void> loadNextPage() async {
    if (isClosed ||
        state.status != CharactersStatus.success ||
        !state.hasMore ||
        state.isLoadingMore) {
      return;
    }
    final version = _requestVersion;
    final previous = state;
    emit(
      CharactersState(
        status: previous.status,
        characters: previous.characters,
        searchQuery: previous.searchQuery,
        nextPage: previous.nextPage,
        hasMore: previous.hasMore,
        isLoadingMore: true,
      ),
    );

    try {
      final page = await _repository.getCharacters(
        page: previous.nextPage,
        name: previous.searchQuery,
      );
      if (!_isCurrent(version)) return;
      emit(
        CharactersState(
          status: CharactersStatus.success,
          characters: [...previous.characters, ...page.characters],
          searchQuery: previous.searchQuery,
          nextPage: previous.nextPage + 1,
          hasMore: page.hasMore,
        ),
      );
    } catch (_) {
      if (!_isCurrent(version)) return;
      emit(
        CharactersState(
          status: previous.status,
          characters: previous.characters,
          searchQuery: previous.searchQuery,
          nextPage: previous.nextPage,
          hasMore: previous.hasMore,
          loadMoreError:
              'Не удалось загрузить следующую страницу. Попробуйте ещё раз.',
        ),
      );
    }
  }

  bool _isCurrent(int version) => !isClosed && version == _requestVersion;

  @override
  Future<void> close() {
    _searchTimer?.cancel();
    _requestVersion++;
    return super.close();
  }
}
