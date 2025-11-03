import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../controllers/movie_controller.dart';
import '../models/movie.dart';
import '../widgets/movie_card.dart';
import 'add_movie_page.dart';
import 'movie_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MovieController _controller = MovieController();
  bool _isLoading = true; // flag para aguardar o Hive abrir

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    await _controller.init();
    setState(() {
      _isLoading = false; // pronto para renderizar
    });
  }

  @override
  void dispose() {
    _controller.closeBox();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final movieBox = Hive.box<Movie>('movies');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Catálogo de Filmes"),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: movieBox.listenable(),
        builder: (context, Box<Movie> box, _) {
          final movies = box.values.toList();

          if (movies.isEmpty) {
            return const Center(
              child: Text(
                "Nenhum filme cadastrado ainda.\nAdicione o primeiro!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
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
                        index: index,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddMoviePage(
                onSave: (newMovie) async {
                  await _controller.addMovie(newMovie);
                },
              ),
            ),
          );

          if (result == true) {
            setState(() {}); // força rebuild ao voltar
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
