import 'package:equatable/equatable.dart';

import '../../domain/entities/character.dart';

enum CharactersStatus { initial, loading, success, empty, failure }

class CharactersState extends Equatable {
  CharactersState({
    this.status = CharactersStatus.initial,
    List<Character> characters = const [],
    this.searchQuery = '',
    this.nextPage = 1,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.loadMoreError,
  }) : characters = List.unmodifiable(characters);

  final CharactersStatus status;
  final List<Character> characters;
  final String searchQuery;
  final int nextPage;
  final bool hasMore;
  final bool isLoadingMore;
  final String? errorMessage;
  final String? loadMoreError;

  @override
  List<Object?> get props => [
    status,
    characters,
    searchQuery,
    nextPage,
    hasMore,
    isLoadingMore,
    errorMessage,
    loadMoreError,
  ];
}
