import 'package:flutter/material.dart';
import '../models/movie.dart';

/// Widget responsável por exibir as informações de um filme em forma de card.
class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback? onTap;

  const MovieCard({Key? key, required this.movie, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: const Icon(Icons.movie, color: Colors.blue),
        title: Text(movie.title,
          style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${movie.genre} • ${movie.year}"),
        onTap: onTap, // Navega para detalhes do filme
      ),
    );
  }
}