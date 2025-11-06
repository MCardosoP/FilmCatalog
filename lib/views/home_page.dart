import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../controllers/movie_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/movie.dart';
import '../widgets/movie_card.dart';
import 'add_movie_page.dart';
import 'movie_detail_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MovieController _movieController = MovieController();
  final AuthController _authController = AuthController();
  bool _isLoading = true; // flag para aguardar o Hive abrir

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _authController.init();

    if (!_authController.isLoggedIn) {
      if (mounted) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
      return;
    }

    await _movieController.init();

    if (mounted) {
      setState(() {
        _isLoading = false; // pronto para renderizar
      });
    }
  }

  Future<void> _logout() async {
    await _authController.logout();
    if (mounted) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final movieBox = Hive.box<Movie>('movies');
    final currentUser = _authController.currentUser ?? 'Usuário';

    return Scaffold(
      appBar: AppBar(
        title: Text("Catálogo de Filmes — $currentUser"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: _logout,
          ),
        ],
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
                        controller: _movieController,
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
                  await _movieController.addMovie(newMovie);
                },
              ),
            ),
          );

          if (result == true) {
            setState(() {});
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
