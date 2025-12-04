import 'package:flutter/material.dart';
import 'dart:io';
import '../models/movie.dart';
import 'add_movie_page.dart';
import '../controllers/movie_controller.dart';
import '../services/image_service.dart';
import 'package:intl/intl.dart';

class MovieDetailPage extends StatefulWidget {
  final Movie movie;
  final MovieController controller;
  final int index;
  final String userId; // Adiciona userId

  const MovieDetailPage({
    Key? key,
    required this.movie,
    required this.controller,
    required this.index,
    required this.userId,
  }) : super(key: key);

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  late Movie _currentMovie;
  final ImageService _imageService = ImageService();

  @override
  void initState() {
    super.initState();
    _currentMovie = widget.movie;
  }

  void _deleteMovie(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir "${_currentMovie.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              widget.controller.deleteMovie(widget.index);
              Navigator.pop(context); // Fecha o dialog
              Navigator.pop(context); // Volta para a home
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Filme '${_currentMovie.title}' removido.")),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleWatched() async {
    await widget.controller.toggleWatched(widget.index);
    setState(() {
      _currentMovie = widget.controller.movies[widget.index];
    });
  }

  Future<void> _toggleFavorite() async {
    await widget.controller.toggleFavorite(widget.index);
    setState(() {
      _currentMovie = widget.controller.movies[widget.index];
    });
  }

  Future<void> _addOrChangePoster() async {
    final source = await ImageService.showImageSourceDialog(context);

    if (source == null) return;

    try {
      String? imagePath;

      if (source == 'camera') {
        imagePath = await _imageService.takePicture();
      } else if (source == 'gallery') {
        imagePath = await _imageService.pickFromGallery();
      }

      if (imagePath != null) {
        // Atualiza o filme com a nova foto
        final updatedMovie = _currentMovie.copyWith(
          localPosterPath: imagePath,
        );

        final error = await widget.controller.updateMovie(widget.index, updatedMovie);

        if (error == null) {
          setState(() {
            _currentMovie = updatedMovie;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Foto atualizada com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao capturar imagem: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editMovie() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddMoviePage(
          userId: widget.userId, // Passa o userId
          movieToEdit: _currentMovie,
          onSave: (updatedMovie) async {
            final error = await widget.controller.updateMovie(widget.index, updatedMovie);
            if (error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error)),
              );
            } else {
              setState(() {
                _currentMovie = updatedMovie;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filme atualizado com sucesso!')),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar com imagem de fundo
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _currentMovie.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3.0,
                      color: Colors.black87,
                    ),
                  ],
                ),
              ),
              background: _currentMovie.displayPosterPath != null
                  ? Stack(
                fit: StackFit.expand,
                children: [
                  _currentMovie.hasLocalPoster
                      ? Image.file(
                    File(_currentMovie.localPosterPath!),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.movie,
                          size: 100,
                          color: Colors.grey,
                        ),
                      );
                    },
                  )
                      : Image.network(
                    _currentMovie.posterUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.movie,
                          size: 100,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              )
                  : Container(
                color: Colors.grey[300],
                child: const Icon(
                  Icons.movie,
                  size: 100,
                  color: Colors.grey,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.camera_alt),
                onPressed: _addOrChangePoster,
                tooltip: _currentMovie.hasLocalPoster ? 'Alterar Foto' : 'Tirar Foto',
              ),
              IconButton(
                icon: Icon(
                  _currentMovie.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _currentMovie.isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: _toggleFavorite,
                tooltip: 'Favoritar',
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Excluir', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    _editMovie();
                  } else if (value == 'delete') {
                    _deleteMovie(context);
                  }
                },
              ),
            ],
          ),

          // Conteúdo
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges de status
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (_currentMovie.isWatched)
                        Chip(
                          avatar: const Icon(Icons.check_circle, size: 18, color: Colors.white),
                          label: const Text('Assistido', style: TextStyle(color: Colors.white)),
                          backgroundColor: Colors.green,
                        ),
                      if (_currentMovie.isFavorite)
                        Chip(
                          avatar: const Icon(Icons.favorite, size: 18, color: Colors.white),
                          label: const Text('Favorito', style: TextStyle(color: Colors.white)),
                          backgroundColor: Colors.red,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Avaliação
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star, color: Colors.white, size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  _currentMovie.ratingFormatted,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Avaliação',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  '${_currentMovie.ratingFormatted} de 10',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Informações básicas
                  _buildInfoRow(Icons.category, 'Gênero', _currentMovie.genre),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.calendar_today, 'Ano', _currentMovie.yearString),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.date_range,
                    'Adicionado em',
                    dateFormat.format(_currentMovie.dateAdded),
                  ),
                  const SizedBox(height: 24),

                  // Sinopse
                  const Text(
                    'Sinopse',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentMovie.description.isEmpty
                        ? 'Sem descrição disponível.'
                        : _currentMovie.description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 24),

                  // Botão de Assistido
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _toggleWatched,
                      icon: Icon(_currentMovie.isWatched ? Icons.check_circle : Icons.visibility),
                      label: Text(
                        _currentMovie.isWatched
                            ? 'Marcar como não assistido'
                            : 'Marcar como assistido',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentMovie.isWatched ? Colors.green : null,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}