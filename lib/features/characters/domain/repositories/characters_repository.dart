import '../entities/characters_page.dart';

abstract class CharactersRepository {
  Future<CharactersPage> getCharacters({
    required int page,
    required String name,
  });
}
