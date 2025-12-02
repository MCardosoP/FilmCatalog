import 'dart:convert';
import 'package:http/http.dart' as http;

class MovieAPIService {
  // 🔑 API Key pública da OMDb (pode usar direto, 1000 requests/dia)
  static const String _apiKey = 'c94892a0';
  static const String _baseUrl = 'https://www.omdbapi.com/';

  /// Busca filmes por título
  /// Retorna uma lista de mapas com os dados dos filmes
  Future<List<Map<String, dynamic>>> searchMovies(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      final url = Uri.parse(
        '$_baseUrl?apikey=$_apiKey&s=${Uri.encodeComponent(query)}&type=movie',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['Response'] == 'True') {
          final results = data['Search'] as List;
          return results.map((movie) => movie as Map<String, dynamic>).toList();
        } else {
          // Nenhum resultado encontrado
          return [];
        }
      } else {
        throw Exception('Erro ao buscar filmes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na busca: $e');
    }
  }

  /// Busca detalhes completos de um filme específico pelo ID
  Future<Map<String, dynamic>?> getMovieDetails(String imdbId) async {
    try {
      final url = Uri.parse(
        '$_baseUrl?apikey=$_apiKey&i=$imdbId&plot=full',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['Response'] == 'True') {
          return data;
        }
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar detalhes: $e');
    }
  }

  /// Busca filmes populares (usando uma lista pré-definida)
  Future<List<Map<String, dynamic>>> getPopularMovies() async {
    // Lista de filmes populares para buscar
    final popularTitles = [
      'The Shawshank Redemption',
      'The Godfather',
      'The Dark Knight',
      'Pulp Fiction',
      'Forrest Gump',
      'Inception',
      'The Matrix',
      'Interstellar',
      'Gladiator',
      'The Lion King',
    ];

    final List<Map<String, dynamic>> movies = [];

    for (var title in popularTitles) {
      try {
        final results = await searchMovies(title);
        if (results.isNotEmpty) {
          // Pega apenas o primeiro resultado (mais relevante)
          final details = await getMovieDetails(results[0]['imdbID']);
          if (details != null) {
            movies.add(details);
          }
        }
      } catch (e) {
        // Ignora erros individuais
        continue;
      }
    }

    return movies;
  }

  /// Converte dados da OMDb para o formato do nosso app
  static Map<String, dynamic> convertToAppFormat(Map<String, dynamic> omdbData) {
    return {
      'imdbID': omdbData['imdbID'] ?? '',
      'title': omdbData['Title'] ?? 'Sem título',
      'year': _extractYear(omdbData['Year']),
      'genre': omdbData['Genre'] ?? 'Geral',
      'plot': omdbData['Plot'] ?? 'Sem descrição disponível',
      'poster': omdbData['Poster'] != 'N/A' ? omdbData['Poster'] : null,
      'rating': _extractRating(omdbData['imdbRating']),
      'director': omdbData['Director'] ?? 'Desconhecido',
      'actors': omdbData['Actors'] ?? 'Desconhecido',
      'runtime': omdbData['Runtime'] ?? 'N/A',
    };
  }

  /// Extrai o ano da string (ex: "2010" ou "2010-2015")
  static int _extractYear(String? yearString) {
    if (yearString == null || yearString.isEmpty || yearString == 'N/A') {
      return DateTime.now().year;
    }

    try {
      // Pega apenas os primeiros 4 dígitos
      final yearMatch = RegExp(r'\d{4}').firstMatch(yearString);
      if (yearMatch != null) {
        return int.parse(yearMatch.group(0)!);
      }
    } catch (e) {
      // Ignora erro
    }

    return DateTime.now().year;
  }

  /// Extrai a avaliação e converte para escala 0-10
  static double _extractRating(String? ratingString) {
    if (ratingString == null || ratingString.isEmpty || ratingString == 'N/A') {
      return 0.0;
    }

    try {
      return double.parse(ratingString);
    } catch (e) {
      return 0.0;
    }
  }

  /// Retorna a URL da imagem (poster)
  static String? getPosterUrl(Map<String, dynamic> movie) {
    final poster = movie['Poster'] ?? movie['poster'];
    if (poster == null || poster == 'N/A') return null;
    return poster;
  }
}