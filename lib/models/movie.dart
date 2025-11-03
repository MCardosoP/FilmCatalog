import 'package:hive/hive.dart';

part 'movie.g.dart';

@HiveType(typeId: 0)
class Movie extends HiveObject { // Modelo que representa um filme no catálogo.
  @HiveField(0)
  String title;
  
  @HiveField(1)
  String genre;
  
  @HiveField(2)
  int year;

  Movie({ // Construtor do modelo de filme.
    required this.title,
    required this.genre,
    required this.year,
  });
}