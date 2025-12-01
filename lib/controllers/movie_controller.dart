import 'package:hive/hive.dart';
import '../models/movie.dart';

class MovieController {
  late Box<Movie> _movieBox;
  String? _currentUserId; // Armazena o ID do usuário atual

  /// Inicializa o Hive e abre (ou cria) a box de filmes
  /// Recebe o userId do usuário logado
  Future<void> init(String userId) async {
    _currentUserId = userId;
    _movieBox = await Hive.openBox<Movie>('movies');
  }

  /// Fecha todas as boxes do Hive
  void closeBox() {
    Hive.close();
  }

  /// Retorna todos os filmes cadastrados (apenas do usuário atual)
  List<Movie> get movies {
    print('DEBUG: Buscando filmes para usuário: $_currentUserId');
    print('DEBUG: Total de filmes na box: ${_movieBox.length}');

    if (_currentUserId == null) return [];

    final userMovies = _movieBox.values
        .where((movie) => movie.userId == _currentUserId)
        .toList();

    print('DEBUG: Filmes do usuário $_currentUserId: ${userMovies.length}');
    for (var movie in userMovies) {
      print('  - ${movie.title} (userId: ${movie.userId})');
    }

    return userMovies;
  }

  /// Adiciona um novo filme com validação
  Future<String?> addMovie(Movie movie) async {
    // Validação: título não pode estar vazio
    if (movie.title.trim().isEmpty) {
      return 'O título do filme não pode estar vazio';
    }

    // Validação: ano deve ser válido
    if (movie.year < 1888 || movie.year > DateTime.now().year + 5) {
      return 'Ano inválido';
    }

    // Validação: rating deve estar entre 0 e 10
    if (movie.rating < 0 || movie.rating > 10) {
      return 'A avaliação deve estar entre 0 e 10';
    }

    // Validação: userId deve estar presente
    if (movie.userId.isEmpty) {
      return 'Erro: usuário não identificado';
    }

    // Verificar se já existe um filme com o mesmo título e ano (apenas do usuário atual)
    final duplicate = _movieBox.values.any(
          (m) => m.userId == movie.userId &&
          m.title.toLowerCase() == movie.title.toLowerCase() &&
          m.year == movie.year,
    );

    if (duplicate) {
      return 'Já existe um filme com este título e ano no seu catálogo';
    }

    print('DEBUG: Adicionando filme "${movie.title}" para usuário: ${movie.userId}');
    print('DEBUG: _currentUserId = $_currentUserId');

    await _movieBox.add(movie);
    return null; // Sucesso
  }

  /// Atualiza um filme existente (pelo índice)
  Future<String?> updateMovie(int index, Movie updatedMovie) async {
    if (index < 0 || index >= _movieBox.length) {
      return 'Filme não encontrado';
    }

    // Validações similares ao addMovie
    if (updatedMovie.title.trim().isEmpty) {
      return 'O título do filme não pode estar vazio';
    }

    if (updatedMovie.year < 1888 || updatedMovie.year > DateTime.now().year + 5) {
      return 'Ano inválido';
    }

    if (updatedMovie.rating < 0 || updatedMovie.rating > 10) {
      return 'A avaliação deve estar entre 0 e 10';
    }

    final key = _movieBox.keyAt(index);
    await _movieBox.put(key, updatedMovie);
    return null; // Sucesso
  }

  /// Remove um filme pelo índice
  Future<void> deleteMovie(int index) async {
    if (index >= 0 && index < _movieBox.length) {
      final key = _movieBox.keyAt(index);
      await _movieBox.delete(key);
    }
  }

  /// Busca filmes por título (case-insensitive) - apenas do usuário atual
  List<Movie> searchByTitle(String query) {
    if (query.trim().isEmpty) return movies;

    final lowerQuery = query.toLowerCase();
    return movies
        .where((movie) => movie.title.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Filtra filmes por gênero - apenas do usuário atual
  List<Movie> filterByGenre(String genre) {
    if (genre.trim().isEmpty) return movies;

    return movies
        .where((movie) => movie.genre.toLowerCase().contains(genre.toLowerCase()))
        .toList();
  }

  /// Filtra filmes por ano - apenas do usuário atual
  List<Movie> filterByYear(int year) {
    return movies
        .where((movie) => movie.year == year)
        .toList();
  }

  /// Retorna apenas filmes assistidos - apenas do usuário atual
  List<Movie> get watchedMovies {
    return movies
        .where((movie) => movie.isWatched)
        .toList();
  }

  /// Retorna apenas filmes favoritos - apenas do usuário atual
  List<Movie> get favoriteMovies {
    return movies
        .where((movie) => movie.isFavorite)
        .toList();
  }

  /// Retorna filmes não assistidos - apenas do usuário atual
  List<Movie> get unwatchedMovies {
    return movies
        .where((movie) => !movie.isWatched)
        .toList();
  }

  /// Ordena filmes alfabeticamente
  List<Movie> get moviesSortedByTitle {
    final list = movies;
    list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    return list;
  }

  /// Ordena filmes por ano (mais recente primeiro)
  List<Movie> get moviesSortedByYear {
    final list = movies;
    list.sort((a, b) => b.year.compareTo(a.year));
    return list;
  }

  /// Ordena filmes por avaliação (maior primeiro)
  List<Movie> get moviesSortedByRating {
    final list = movies;
    list.sort((a, b) => b.rating.compareTo(a.rating));
    return list;
  }

  /// Ordena filmes por data de adição (mais recente primeiro)
  List<Movie> get moviesSortedByDateAdded {
    final list = movies;
    list.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    return list;
  }

  /// Alterna o status de "assistido"
  Future<void> toggleWatched(int index) async {
    if (index >= 0 && index < _movieBox.length) {
      final movie = _movieBox.getAt(index);
      if (movie != null) {
        movie.isWatched = !movie.isWatched;
        await movie.save();
      }
    }
  }

  /// Alterna o status de "favorito"
  Future<void> toggleFavorite(int index) async {
    if (index >= 0 && index < _movieBox.length) {
      final movie = _movieBox.getAt(index);
      if (movie != null) {
        movie.isFavorite = !movie.isFavorite;
        await movie.save();
      }
    }
  }

  /// Atualiza a avaliação de um filme
  Future<void> updateRating(int index, double newRating) async {
    if (index >= 0 && index < _movieBox.length && newRating >= 0 && newRating <= 10) {
      final movie = _movieBox.getAt(index);
      if (movie != null) {
        movie.rating = newRating;
        await movie.save();
      }
    }
  }

  // ========== ESTATÍSTICAS ==========

  /// Total de filmes no catálogo
  int get totalMovies => _movieBox.length;

  /// Total de filmes assistidos
  int get totalWatched => watchedMovies.length;

  /// Total de filmes favoritos
  int get totalFavorites => favoriteMovies.length;

  /// Média de avaliação de todos os filmes
  double get averageRating {
    if (_movieBox.isEmpty) return 0.0;
    final sum = _movieBox.values.fold<double>(0, (sum, movie) => sum + movie.rating);
    return sum / _movieBox.length;
  }

  /// Conta filmes por gênero - apenas do usuário atual
  Map<String, int> get moviesByGenre {
    final Map<String, int> genreCount = {};

    for (var movie in movies) {
      // Divide gêneros se houver vírgula (caso de múltiplos gêneros)
      final genres = movie.genre.split(',').map((g) => g.trim()).toList();

      for (var genre in genres) {
        genreCount[genre] = (genreCount[genre] ?? 0) + 1;
      }
    }

    return genreCount;
  }

  /// Retorna os anos com filmes cadastrados - apenas do usuário atual
  List<int> get yearsWithMovies {
    final years = movies.map((m) => m.year).toSet().toList();
    years.sort((a, b) => b.compareTo(a)); // Ordem decrescente
    return years;
  }

  /// Retorna os gêneros únicos cadastrados - apenas do usuário atual
  List<String> get uniqueGenres {
    final Set<String> genres = {};

    for (var movie in movies) {
      final movieGenres = movie.genre.split(',').map((g) => g.trim()).toList();
      genres.addAll(movieGenres);
    }

    return genres.toList()..sort();
  }
}