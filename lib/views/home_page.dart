import 'package:flutter/material.dart';
import '../controllers/movie_controller.dart';
import '../widgets/movie_card.dart';
import 'add_movie_page.dart';
import 'movie_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MovieController _controller = MovieController();

  @override
  Widget build(BuildContext context) {
    final movies = _controller.movies;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Catálogo de Filmes"),
        centerTitle: true,
      ),
      body: movies.isEmpty
          ? const Center(
            child: Text(
             "Nenhum filme cadastrado ainda.\nAdicione o primeiro!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          )
          : ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return MovieCard(
                movie: movie,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MovieDetailPage(
                        movie: movie,
                        controller: _controller,
                        index: index
                      ),
                    ),
                  ).then((_) {
                    setState(() {});
                  });
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