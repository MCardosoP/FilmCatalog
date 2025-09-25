import '../models/movie.dart';

class MovieController {
  final List<Movie> _movies = [];

  List<Movie> get movies => _movies;

  void addMovie(Movie movie) {
    _movies.add(movie);
  }
}