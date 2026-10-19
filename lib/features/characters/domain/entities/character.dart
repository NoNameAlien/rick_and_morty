import 'package:equatable/equatable.dart';

class Character extends Equatable {
  const Character({
    required this.id,
    required this.name,
    required this.image,
    required this.status,
    required this.species,
    required this.origin,
    required this.location,
  });

  final int id;
  final String name;
  final String image;
  final String status;
  final String species;
  final String origin;
  final String location;

  @override
  List<Object> get props => [
    id,
    name,
    image,
    status,
    species,
    origin,
    location,
  ];
}
