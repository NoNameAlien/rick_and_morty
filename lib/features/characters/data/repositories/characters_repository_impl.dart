import 'package:dio/dio.dart';

import '../../domain/entities/characters_page.dart';
import '../../domain/repositories/characters_repository.dart';
import '../dto/character_dto.dart';

class CharactersRepositoryImpl implements CharactersRepository {
  CharactersRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<CharactersPage> getCharacters({
    required int page,
    required String name,
  }) async {
    if (page < 1) {
      throw ArgumentError.value(page, 'page', 'Must be greater than zero');
    }

    final Response<Map<String, dynamic>> response;
    try {
      response = await _dio.get<Map<String, dynamic>>(
        'character',
        queryParameters: {'page': page, 'name': name},
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 404 && page == 1 && name.isNotEmpty) {
        return CharactersPage(characters: const [], hasMore: false);
      }
      rethrow;
    }

    final data = response.data;
    if (data == null) {
      throw const FormatException('Character response body is missing');
    }
    final info = data['info'] as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>;

    return CharactersPage(
      characters: results
          .map(
            (json) =>
                CharacterDto.fromJson(json as Map<String, dynamic>).toDomain(),
          )
          .toList(),
      hasMore: info['next'] != null,
    );
  }
}
