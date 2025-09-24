import 'package:flutter/material.dart';
import '../controllers/movie_controller.dart';
import '../widgets/movie_card.dart';
import 'add_movie_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MovieController _controller = MovieController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Catálogo de Filmes"),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: _controller.movies.length,
        itemBuilder: (context, index) {
          final movie = _controller.movies[index];
          return MovieCard(
            movie: movie,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Abrir detalhes de: ${movie.title}")),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddMoviePage(controller: _controller),
            ),
          ).then((_) {
            setState(() {}); // Atualiza a lista ao voltar
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}