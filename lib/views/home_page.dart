import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../controllers/movie_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/movie.dart';
import '../widgets/movie_card.dart';
import 'add_movie_page.dart';
import 'movie_detail_page.dart';
import 'login_page.dart';
import 'search_movie_page.dart';

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

    // Passa o userId para o MovieController
    final userId = _authController.currentUser!;
    await _movieController.init(userId);

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
        automaticallyImplyLeading: false, // Remove o botão "Voltar"
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Buscar no TMDB',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SearchMoviePage(
                    controller: _movieController,
                    userId: _authController.currentUser!,
                  ),
                ),
              );
            },
          ),
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
          // ✅ CORREÇÃO: Usa o getter do controller que filtra por usuário
          final movies = _movieController.movies;

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
                        userId: _authController.currentUser!, // Passa o userId
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
                userId: _authController.currentUser!, // Passa o userId
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