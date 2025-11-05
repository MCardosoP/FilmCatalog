import 'package:hive/hive.dart';
import '../models/movie.dart';

class MovieController {
  late Box<Movie> _movieBox;

  /// Inicializa o Hive e abre (ou cria) a box de filmes
  Future<void> init() async {
    _movieBox = await Hive.openBox<Movie>('movies');
  }

  /// Fecha todas as boxes do Hive
  void closeBox() {
    Hive.close();
  }

  /// Retorna todos os filmes cadastrados
  List<Movie> get movies {
    return _movieBox.values.toList();
  }

  /// Adiciona um novo filme
  Future<void> addMovie(Movie movie) async {
    final key = await _movieBox.add(movie);
  }

  /// Atualiza um filme existente (pelo índice)
  Future<void> updateMovie(int index, Movie updatedMovie) async {
    final key = _movieBox.keyAt(index);
    await _movieBox.put(key, updatedMovie);
  }

  /// Remove um filme pelo índice
  Future<void> deleteMovie(int index) async {
    final key = _movieBox.keyAt(index);
    await _movieBox.delete(key);
  }
}
