import 'package:equatable/equatable.dart';

import 'character.dart';

class CharactersPage extends Equatable {
  CharactersPage({required List<Character> characters, required this.hasMore})
    : characters = List.unmodifiable(characters);

  final List<Character> characters;
  final bool hasMore;

  @override
  List<Object> get props => [characters, hasMore];
}
