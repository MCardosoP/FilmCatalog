import '../models/movie.dart';

class MovieController {
  final List<Movie> _movies = [
    Movie(title: "The Matrix", genre: "Ficção Científica", year: 1999),
    Movie(title: "O Senhor dos Anéis", genre: "Fantasia", year: 2001),
    Movie(title: "Interstellar", genre: "Ficção Científica", year: 2014),
  ];

  List<Movie> get movies => _movies;

  void addMovie(Movie movie) {
    _movies.add(movie);
  }
}