import 'package:flutter/material.dart';
import 'dart:io';
import '../models/movie.dart';
import '../services/image_service.dart';

/// Página para adicionar ou editar um filme.
/// Recebe um callback [onSave] que será chamado com o Movie a ser salvo.
/// Se [movieToEdit] for fornecido, o formulário será inicializado para edição.
class AddMoviePage extends StatefulWidget {
  final Function(Movie) onSave;
  final Movie? movieToEdit;
  final String userId; // ID do usuário que está criando/editando

  const AddMoviePage({
    Key? key,
    required this.onSave,
    required this.userId,
    this.movieToEdit,
  }) : super(key: key);

  @override
  _AddMoviePageState createState() => _AddMoviePageState();
}

class _AddMoviePageState extends State<AddMoviePage> {
  final _formKey = GlobalKey<FormState>();
  final ImageService _imageService = ImageService();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _posterUrlController = TextEditingController();

  double _rating = 0.0;
  bool _isWatched = false;
  bool _isFavorite = false;
  String? _localPosterPath; // Caminho da foto tirada

  @override
  void initState() {
    super.initState();
    // Se vier um movieToEdit, preenche os campos para edição
    if (widget.movieToEdit != null) {
      _titleController.text = widget.movieToEdit!.title;
      _genreController.text = widget.movieToEdit!.genre;
      _yearController.text = widget.movieToEdit!.year.toString();
      _descriptionController.text = widget.movieToEdit!.description;
      _posterUrlController.text = widget.movieToEdit!.posterUrl ?? '';
      _rating = widget.movieToEdit!.rating;
      _isWatched = widget.movieToEdit!.isWatched;
      _isFavorite = widget.movieToEdit!.isFavorite;
      _localPosterPath = widget.movieToEdit!.localPosterPath;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _genreController.dispose();
    _yearController.dispose();
    _descriptionController.dispose();
    _posterUrlController.dispose();
    super.dispose();
  }

  /// Abre dialog para escolher entre câmera ou galeria
  Future<void> _pickImage() async {
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
        setState(() {
          _localPosterPath = imagePath;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto adicionada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao capturar imagem: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Remove a foto local
  void _removeLocalPoster() {
    setState(() {
      _localPosterPath = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Foto removida'),
      ),
    );
  }

  /// Valida o formulário, cria o objeto Movie e chama o callback onSave.
  /// Retorna ao screen anterior com resultado `true` para sinalizar alteração.
  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final int parsedYear = int.parse(_yearController.text);

      final newMovie = Movie(
        title: _titleController.text.trim(),
        genre: _genreController.text.trim(),
        year: parsedYear,
        userId: widget.userId, // Usa o userId passado
        description: _descriptionController.text.trim(),
        rating: _rating,
        posterUrl: _posterUrlController.text.trim().isEmpty
            ? null
            : _posterUrlController.text.trim(),
        isWatched: _isWatched,
        isFavorite: _isFavorite,
        dateAdded: widget.movieToEdit?.dateAdded, // Mantém a data original se for edição
        tmdbId: widget.movieToEdit?.tmdbId, // Mantém o ID do TMDB se existir
        localPosterPath: _localPosterPath, // Adiciona foto local
      );

      // Chama o callback fornecido pela HomePage (ou controller)
      widget.onSave(newMovie);

      // Retorna true para indicar que houve modificação
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.movieToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Filme' : 'Adicionar Filme'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Campo Título
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.movie),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'O título é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Preview da foto local ou poster
              if (_localPosterPath != null || _posterUrlController.text.isNotEmpty)
                Card(
                  elevation: 2,
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _localPosterPath != null
                                ? Image.file(
                              File(_localPosterPath!),
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                                : Image.network(
                              _posterUrlController.text,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 200,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.error, size: 64),
                                );
                              },
                            ),
                          ),
                          if (_localPosterPath != null)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.white),
                                  onPressed: _removeLocalPoster,
                                  tooltip: 'Remover foto',
                                ),
                              ),
                            ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _localPosterPath != null
                              ? 'Foto capturada'
                              : 'Poster da internet',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // Botão de Câmera
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.camera_alt),
                label: Text(
                  _localPosterPath != null
                      ? 'Alterar Foto'
                      : 'Tirar Foto do Poster',
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 24),

              // Campo Gênero
              TextFormField(
                controller: _genreController,
                decoration: const InputDecoration(
                  labelText: 'Gênero',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                  hintText: 'Ex: Ação, Drama, Comédia',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'O gênero é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo Ano
              TextFormField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Ano de lançamento',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'O ano é obrigatório';
                  }
                  final year = int.tryParse(value);
                  if (year == null || year < 1888 || year > DateTime.now().year + 5) {
                    return 'Digite um ano válido (1888 - ${DateTime.now().year + 5})';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo Descrição/Sinopse
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição/Sinopse',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                  hintText: 'Breve resumo sobre o filme',
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'A descrição é obrigatória';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo URL do Poster (Opcional)
              TextFormField(
                controller: _posterUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL do Poster (opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.image),
                  hintText: 'https://exemplo.com/poster.jpg',
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 24),

              // Avaliação (Rating)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Avaliação',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star, size: 20, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  _rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Slider(
                        value: _rating,
                        min: 0,
                        max: 10,
                        divisions: 20,
                        label: _rating.toStringAsFixed(1),
                        onChanged: (value) {
                          setState(() {
                            _rating = value;
                          });
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('0.0', style: TextStyle(color: Colors.grey)),
                          Text('10.0', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Switches para Assistido e Favorito
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Já assisti este filme'),
                        subtitle: const Text('Marcar como assistido'),
                        secondary: Icon(
                          _isWatched ? Icons.check_circle : Icons.visibility,
                          color: _isWatched ? Colors.green : Colors.grey,
                        ),
                        value: _isWatched,
                        onChanged: (value) {
                          setState(() {
                            _isWatched = value;
                          });
                        },
                      ),
                      const Divider(),
                      SwitchListTile(
                        title: const Text('Filme favorito'),
                        subtitle: const Text('Adicionar aos favoritos'),
                        secondary: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite ? Colors.red : Colors.grey,
                        ),
                        value: _isFavorite,
                        onChanged: (value) {
                          setState(() {
                            _isFavorite = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Botão Salvar
              ElevatedButton.icon(
                onPressed: _handleSave,
                icon: const Icon(Icons.save),
                label: Text(isEditing ? 'Salvar Alterações' : 'Adicionar Filme'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}