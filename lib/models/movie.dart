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
  }) : dateAdded = dateAdded ?? DateTime.now();

  // Construtor factory para criar a partir de dados do TMDB
  factory Movie.fromTMDB(Map<String, dynamic> json, String userId) {
    return Movie(
      title: json['title'] ?? 'Sem título',
      genre: _extractGenres(json['genre_ids'] ?? []),
      year: _extractYear(json['release_date']),
      userId: userId, // Passa o userId
      description: json['overview'] ?? 'Sem descrição disponível',
      rating: (json['vote_average'] ?? 0.0).toDouble(),
      posterUrl: json['poster_path'] != null
          ? 'https://image.tmdb.org/t/p/w500${json['poster_path']}'
          : null,
      tmdbId: json['id'],
    );
  }

  // Helper para extrair o ano da data de lançamento
  static int _extractYear(String? releaseDate) {
    if (releaseDate == null || releaseDate.isEmpty) return DateTime.now().year;
    try {
      return DateTime.parse(releaseDate).year;
    } catch (e) {
      return DateTime.now().year;
    }
  }

  // Helper para converter IDs de gênero em texto (mapeamento básico do TMDB)
  static String _extractGenres(List<dynamic> genreIds) {
    const genreMap = {
      28: 'Ação',
      12: 'Aventura',
      16: 'Animação',
      35: 'Comédia',
      80: 'Crime',
      99: 'Documentário',
      18: 'Drama',
      10751: 'Família',
      14: 'Fantasia',
      36: 'História',
      27: 'Terror',
      10402: 'Música',
      9648: 'Mistério',
      10749: 'Romance',
      878: 'Ficção Científica',
      10770: 'TV',
      53: 'Thriller',
      10752: 'Guerra',
      37: 'Faroeste',
    };

    if (genreIds.isEmpty) return 'Geral';

    final genres = genreIds
        .map((id) => genreMap[id])
        .where((genre) => genre != null)
        .take(2) // Pega até 2 gêneros
        .join(', ');

    return genres.isEmpty ? 'Geral' : genres;
  }

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
    );
  }

  // Getter para exibir a nota formatada
  String get ratingFormatted => rating.toStringAsFixed(1);

  // Getter para ano como string
  String get yearString => year.toString();
}