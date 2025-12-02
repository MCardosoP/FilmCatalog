import 'package:flutter/material.dart';
import '../services/omdb_service.dart';
import '../models/movie.dart';
import '../controllers/movie_controller.dart';

class SearchMoviePage extends StatefulWidget {
  final MovieController controller;
  final String userId;

  const SearchMoviePage({
    Key? key,
    required this.controller,
    required this.userId,
  }) : super(key: key);

  @override
  State<SearchMoviePage> createState() => _SearchMoviePageState();
}

class _SearchMoviePageState extends State<SearchMoviePage> {
  final MovieAPIService _apiService = MovieAPIService();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _popularMovies = [];
  bool _isLoading = false;
  bool _showingPopular = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPopularMovies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPopularMovies() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final movies = await _apiService.getPopularMovies();
      setState(() {
        _popularMovies = movies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _searchMovies(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _showingPopular = true;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _showingPopular = false;
      _errorMessage = null;
    });

    try {
      final results = await _apiService.searchMovies(query);

      // Busca detalhes de cada filme encontrado
      final List<Map<String, dynamic>> detailedResults = [];
      for (var result in results.take(10)) {
        final details = await _apiService.getMovieDetails(result['imdbID']);
        if (details != null) {
          detailedResults.add(details);
        }
      }

      setState(() {
        _searchResults = detailedResults;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addMovieToCollection(Map<String, dynamic> movieData) async {
    final converted = MovieAPIService.convertToAppFormat(movieData);

    final movie = Movie(
      title: converted['title'],
      genre: converted['genre'],
      year: converted['year'],
      userId: widget.userId,
      description: converted['plot'],
      rating: converted['rating'],
      posterUrl: converted['poster'],
    );

    final error = await widget.controller.addMovie(movie);

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${movie.title} adicionado ao seu catálogo!'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Ver',
            textColor: Colors.white,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final moviesToShow = _showingPopular ? _popularMovies : _searchResults;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Filmes'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Digite o nome do filme...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _showingPopular = true;
                      _searchResults = [];
                    });
                  },
                )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
              onSubmitted: _searchMovies,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[200],
            child: Row(
              children: [
                Icon(
                  _showingPopular ? Icons.trending_up : Icons.search,
                  color: Colors.grey[700],
                ),
                const SizedBox(width: 8),
                Text(
                  _showingPopular ? 'Filmes Populares' : 'Resultados da Busca',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildContent(moviesToShow),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<Map<String, dynamic>> movies) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Buscando filmes...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Erro ao buscar filmes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _showingPopular ? _loadPopularMovies : () => _searchMovies(_searchController.text),
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (movies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.movie_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _showingPopular
                  ? 'Nenhum filme encontrado'
                  : 'Nenhum resultado para "${_searchController.text}"',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return _buildMovieCard(movie);
      },
    );
  }

  Widget _buildMovieCard(Map<String, dynamic> movie) {
    final converted = MovieAPIService.convertToAppFormat(movie);
    final title = converted['title'];
    final posterUrl = MovieAPIService.getPosterUrl(movie);
    final year = converted['year'];
    final rating = converted['rating'];
    final plot = converted['plot'];
    final genre = converted['genre'];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showMovieDialog(movie),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: posterUrl != null
                  ? Image.network(
                posterUrl,
                width: 100,
                height: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholderPoster();
                },
              )
                  : _buildPlaceholderPoster(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getRatingColor(rating),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star, size: 14, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          year.toString(),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      genre,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      plot,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderPoster() {
    return Container(
      width: 100,
      height: 150,
      color: Colors.grey[300],
      child: const Icon(Icons.movie, size: 40, color: Colors.grey),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 8.0) return Colors.green;
    if (rating >= 6.0) return Colors.orange;
    if (rating >= 4.0) return Colors.amber;
    return Colors.red;
  }

  void _showMovieDialog(Map<String, dynamic> movie) {
    final converted = MovieAPIService.convertToAppFormat(movie);
    final title = converted['title'];
    final posterUrl = MovieAPIService.getPosterUrl(movie);
    final year = converted['year'];
    final rating = converted['rating'];
    final plot = converted['plot'];
    final genre = converted['genre'];
    final director = converted['director'];
    final actors = converted['actors'];
    final runtime = converted['runtime'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (posterUrl != null)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      posterUrl,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: const Icon(Icons.movie, size: 64),
                        );
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    rating.toStringAsFixed(1),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.calendar_today, size: 18),
                  const SizedBox(width: 4),
                  Text(year.toString()),
                  const SizedBox(width: 16),
                  const Icon(Icons.timer, size: 18),
                  const SizedBox(width: 4),
                  Text(runtime),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Gênero: $genre',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                'Diretor: $director',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                'Elenco: $actors',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              const Text(
                'Sinopse:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(plot),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _addMovieToCollection(movie);
            },
            icon: const Icon(Icons.add),
            label: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }
}