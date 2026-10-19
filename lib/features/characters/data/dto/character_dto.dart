import '../../domain/entities/character.dart';

class CharacterDto {
  const CharacterDto({
    required this.id,
    required this.name,
    required this.image,
    required this.status,
    required this.species,
    required this.origin,
    required this.location,
  });

  factory CharacterDto.fromJson(Map<String, dynamic> json) => CharacterDto(
    id: json['id'] as int,
    name: json['name'] as String,
    image: json['image'] as String,
    status: json['status'] as String,
    species: json['species'] as String,
    origin: (json['origin'] as Map<String, dynamic>)['name'] as String,
    location: (json['location'] as Map<String, dynamic>)['name'] as String,
  );

  final int id;
  final String name;
  final String image;
  final String status;
  final String species;
  final String origin;
  final String location;

  Character toDomain() => Character(
    id: id,
    name: name,
    image: image,
    status: status,
    species: species,
    origin: origin,
    location: location,
  );
}
