import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty/features/characters/domain/entities/character.dart';
import 'package:rick_and_morty/features/characters/domain/entities/characters_page.dart';
import 'package:rick_and_morty/features/characters/domain/repositories/characters_repository.dart';
import 'package:rick_and_morty/features/characters/presentation/cubit/characters_cubit.dart';
import 'package:rick_and_morty/features/characters/presentation/cubit/characters_state.dart';

Character character(int id) => Character(
  id: id,
  name: 'Character $id',
  image: 'image',
  status: 'Alive',
  species: 'Human',
  origin: 'Earth',
  location: 'Earth',
);

CharactersPage page(List<int> ids, {bool hasMore = false}) =>
    CharactersPage(characters: ids.map(character).toList(), hasMore: hasMore);

class PendingRequest {
  PendingRequest(this.page, this.name);

  final int page;
  final String name;
  final result = Completer<CharactersPage>();
}

class FakeCharactersRepository implements CharactersRepository {
  final requests = <PendingRequest>[];

  @override
  Future<CharactersPage> getCharacters({
    required int page,
    required String name,
  }) {
    final request = PendingRequest(page, name);
    requests.add(request);
    return request.result.future;
  }
}

void main() {
  late FakeCharactersRepository repository;
  late CharactersCubit cubit;

  setUp(() {
    repository = FakeCharactersRepository();
    cubit = CharactersCubit(repository);
  });

  tearDown(() async => cubit.close());

  test('loads first page and appends next page, then stops', () async {
    final first = cubit.loadCharacters();
    expect(cubit.state.status, CharactersStatus.loading);
    repository.requests[0].result.complete(page([1], hasMore: true));
    await first;
    expect(cubit.state.status, CharactersStatus.success);
    expect(cubit.state.nextPage, 2);

    final next = cubit.loadNextPage();
    expect(cubit.state.isLoadingMore, isTrue);
    expect(repository.requests[1].page, 2);
    repository.requests[1].result.complete(page([2]));
    await next;
    expect(cubit.state.characters, [character(1), character(2)]);
    expect(cubit.state.nextPage, 3);
    expect(cubit.state.isLoadingMore, isFalse);
    expect(cubit.state.hasMore, isFalse);
    await cubit.loadNextPage();
    expect(repository.requests, hasLength(2));
    expect(() => cubit.state.characters.clear(), throwsUnsupportedError);
  });

  test('blocks duplicate first-page and pagination requests', () async {
    final first = cubit.loadCharacters();
    await cubit.loadCharacters();
    await cubit.loadNextPage();
    expect(repository.requests, hasLength(1));
    repository.requests[0].result.complete(page([1], hasMore: true));
    await first;

    final next = cubit.loadNextPage();
    await cubit.loadNextPage();
    await cubit.loadCharacters();
    expect(repository.requests, hasLength(2));
    repository.requests[1].result.complete(page([2]));
    await next;
  });

  test('debounces rapid search and ignores pending first-page response', () {
    fakeAsync((async) {
      cubit.loadCharacters();
      cubit.searchQueryChanged('Ric');
      async.elapse(const Duration(milliseconds: 300));
      cubit.searchQueryChanged('Rick');
      repository.requests[0].result.complete(page([99], hasMore: true));
      async.flushMicrotasks();
      expect(cubit.state.status, CharactersStatus.loading);
      expect(cubit.state.characters, isEmpty);
      cubit.loadNextPage();
      cubit.loadCharacters();
      async.elapse(const Duration(milliseconds: 399));
      expect(repository.requests, hasLength(1));
      async.elapse(const Duration(milliseconds: 1));
      expect(repository.requests[1].name, 'Rick');
      expect(repository.requests[1].page, 1);
      repository.requests[1].result.complete(page([1]));
      async.flushMicrotasks();
      expect(cubit.state.searchQuery, 'Rick');
      expect(cubit.state.characters, [character(1)]);
    });
  });

  test('latest search wins and pagination keeps its query', () {
    fakeAsync((async) {
      cubit.searchQueryChanged('Rick');
      async.elapse(const Duration(milliseconds: 400));
      cubit.searchQueryChanged('Morty');
      async.elapse(const Duration(milliseconds: 400));
      repository.requests[1].result.complete(page([2], hasMore: true));
      async.flushMicrotasks();
      repository.requests[0].result.complete(page([1]));
      async.flushMicrotasks();
      expect(cubit.state.searchQuery, 'Morty');
      expect(cubit.state.characters, [character(2)]);
      cubit.loadNextPage();
      expect(repository.requests[2].name, 'Morty');
      expect(repository.requests[2].page, 2);
      repository.requests[2].result.complete(page([3]));
      async.flushMicrotasks();
      expect(cubit.state.characters, [character(2), character(3)]);
    });
  });

  test('ignores stale pagination error after a new search completes', () {
    fakeAsync((async) {
      cubit.loadCharacters();
      repository.requests[0].result.complete(page([1], hasMore: true));
      async.flushMicrotasks();
      cubit.loadNextPage();
      cubit.searchQueryChanged('Morty');
      async.elapse(const Duration(milliseconds: 400));
      repository.requests[2].result.complete(page([2]));
      async.flushMicrotasks();
      final current = cubit.state;
      repository.requests[1].result.completeError(Exception('old request'));
      async.flushMicrotasks();
      expect(cubit.state, current);
    });
  });

  test('keeps list on pagination error and retries the same page', () async {
    final first = cubit.loadCharacters();
    repository.requests[0].result.complete(page([1], hasMore: true));
    await first;
    final next = cubit.loadNextPage();
    repository.requests[1].result.completeError(Exception('offline'));
    await next;
    expect(cubit.state.status, CharactersStatus.success);
    expect(cubit.state.characters, [character(1)]);
    expect(cubit.state.loadMoreError, isNotNull);
    expect(cubit.state.errorMessage, isNull);
    expect(cubit.state.isLoadingMore, isFalse);
    expect(cubit.state.nextPage, 2);

    final retry = cubit.loadNextPage();
    expect(repository.requests[2].page, 2);
    expect(cubit.state.loadMoreError, isNull);
    repository.requests[2].result.complete(page([2]));
    await retry;
    expect(cubit.state.characters, [character(1), character(2)]);
    expect(cubit.state.loadMoreError, isNull);
  });

  test(
    'represents empty search and reloads catalog when search is cleared',
    () {
      fakeAsync((async) {
        cubit.searchQueryChanged('Nobody');
        async.elapse(const Duration(milliseconds: 400));
        repository.requests[0].result.complete(page([]));
        async.flushMicrotasks();
        expect(cubit.state.status, CharactersStatus.empty);
        expect(cubit.state.hasMore, isFalse);
        cubit.searchQueryChanged('');
        async.elapse(const Duration(milliseconds: 400));
        expect(repository.requests[1].name, '');
        expect(repository.requests[1].page, 1);
        repository.requests[1].result.complete(page([1]));
        async.flushMicrotasks();
        expect(cubit.state.status, CharactersStatus.success);
      });
    },
  );

  test('retries first page after failure', () async {
    final first = cubit.loadCharacters();
    repository.requests[0].result.completeError(Exception('offline'));
    await first;
    expect(cubit.state.status, CharactersStatus.failure);
    expect(cubit.state.errorMessage, isNotNull);
    final retry = cubit.loadCharacters();
    expect(cubit.state.errorMessage, isNull);
    expect(repository.requests[1].page, 1);
    repository.requests[1].result.complete(page([1]));
    await retry;
    expect(cubit.state.status, CharactersStatus.success);
  });

  test('close cancels debounce and ignores pending responses', () async {
    final first = cubit.loadCharacters();
    cubit.searchQueryChanged('Rick');
    final current = cubit.state;
    await cubit.close();
    repository.requests[0].result.complete(page([1]));
    await first;
    expect(repository.requests, hasLength(1));
    expect(cubit.state, current);
  });
}
