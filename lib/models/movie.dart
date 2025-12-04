import 'package:hive/hive.dart';

part 'movie.g.dart';

@HiveType(typeId: 0)
class Movie extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String genre;

  @HiveField(2)
  int year;

  @HiveField(3)
  String description; // Sinopse do filme

  @HiveField(4)
  double rating; // Nota de 0 a 10

  @HiveField(5)
  String? posterUrl; // URL do poster (nullable para filmes antigos)

  @HiveField(6)
  bool isWatched; // Se o usuário já assistiu

  @HiveField(7)
  bool isFavorite; // Se está marcado como favorito

  @HiveField(8)
  DateTime dateAdded; // Data em que foi adicionado ao catálogo

  @HiveField(9)
  int? tmdbId; // ID do filme no TMDB (para integração futura)

  @HiveField(10)
  String userId; // Email do usuário que criou o filme

  @HiveField(11)
  String? localPosterPath; // Caminho local da foto tirada pelo usuário

  Movie({
    required this.title,
    required this.genre,
    required this.year,
    required this.userId, // Agora é obrigatório
    this.description = '',
    this.rating = 0.0,
    this.posterUrl,
    this.isWatched = false,
    this.isFavorite = false,
    DateTime? dateAdded,
    this.tmdbId,
    this.localPosterPath, // Foto local
  }) : dateAdded = dateAdded ?? DateTime.now();

  // Método para copiar com alterações
  Movie copyWith({
    String? title,
    String? genre,
    int? year,
    String? userId,
    String? description,
    double? rating,
    String? posterUrl,
    bool? isWatched,
    bool? isFavorite,
    DateTime? dateAdded,
    int? tmdbId,
    String? localPosterPath,
  }) {
    return Movie(
      title: title ?? this.title,
      genre: genre ?? this.genre,
      year: year ?? this.year,
      userId: userId ?? this.userId,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      posterUrl: posterUrl ?? this.posterUrl,
      isWatched: isWatched ?? this.isWatched,
      isFavorite: isFavorite ?? this.isFavorite,
      dateAdded: dateAdded ?? this.dateAdded,
      tmdbId: tmdbId ?? this.tmdbId,
      localPosterPath: localPosterPath ?? this.localPosterPath,
    );
  }

  // Getter para exibir a nota formatada
  String get ratingFormatted => rating.toStringAsFixed(1);

  // Getter para ano como string
  String get yearString => year.toString();

  // Getter para determinar qual poster usar (prioriza foto local)
  String? get displayPosterPath => localPosterPath ?? posterUrl;

  // Getter para verificar se tem foto local
  bool get hasLocalPoster => localPosterPath != null && localPosterPath!.isNotEmpty;
}