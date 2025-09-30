import 'package:flutter/material.dart';
import '../models/movie.dart';
import 'edit_movie_page.dart';
import '../controllers/movie_controller.dart';

class MovieDetailPage extends StatelessWidget {
  final Movie movie;
  final MovieController controller;
  final int index;

  const MovieDetailPage({
    Key? key,
    required this.movie,
    required this.controller,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(movie.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              movie.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                const Icon(Icons.category, size: 20),
                const SizedBox(width: 8),
                Text(
                  movie.genre,
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                const Icon(Icons.date_range, size: 20),
                const SizedBox(width: 8),
                Text(
                  movie.year.toString(),
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("Voltar"),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            EditMoviePage(
                              controller: controller,
                              movieIndex: index,
                              movie: movie,
                            ),
                      ),
                    ).then((_) {
                      Navigator.pop(context);
                    });
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text("Editar"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}