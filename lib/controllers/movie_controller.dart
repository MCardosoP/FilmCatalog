import '../models/movie.dart';

class MovieController {
  final List<Movie> movies = [];

  void addMovie(Movie movie) {
    movies.add(movie);
  }

  void updateMovie(int index, Movie updatedMovie) {
    if (index >= 0 && index < movies.length) {
      movies[index] = updatedMovie;
    }
  }
}