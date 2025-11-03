import 'package:hive/hive.dart';
import '../models/movie.dart';

class MovieController {
  late Box<Movie> _movieBox;

  /// Inicializa o Hive e abre (ou cria) a box de filmes
  Future<void> init() async {
    _movieBox = await Hive.openBox<Movie>('movies');
    print("📦 Box 'movies' aberta. Contém ${_movieBox.length} filmes.");
  }

  /// Fecha todas as boxes do Hive
  void closeBox() {
    Hive.close();
  }

  /// Retorna todos os filmes cadastrados
  List<Movie> get movies {
    print("🎬 Recuperando ${_movieBox.length} filmes do Hive...");
    return _movieBox.values.toList();
  }

  /// Adiciona um novo filme
  Future<void> addMovie(Movie movie) async {
    final key = await _movieBox.add(movie);
    print("✅ Filme salvo no Hive! Key: $key | Título: ${movie.title}");
  }

  /// Atualiza um filme existente (pelo índice)
  Future<void> updateMovie(int index, Movie updatedMovie) async {
    final key = _movieBox.keyAt(index);
    await _movieBox.put(key, updatedMovie);
    print("✏️ Filme atualizado! Key: $key | Novo título: ${updatedMovie.title}");
  }

  /// Remove um filme pelo índice
  Future<void> deleteMovie(int index) async {
    final key = _movieBox.keyAt(index);
    await _movieBox.delete(key);
    print("🗑️ Filme removido! Key: $key");
  }
}
