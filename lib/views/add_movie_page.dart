import 'package:flutter/material.dart';
import '../models/movie.dart';

/// Página para adicionar ou editar um filme.
/// Recebe um callback [onSave] que será chamado com o Movie a ser salvo.
/// Se [movieToEdit] for fornecido, o formulário será inicializado para edição.
class AddMoviePage extends StatefulWidget {
  final Function(Movie) onSave;
  final Movie? movieToEdit;

  const AddMoviePage({
    Key? key,
    required this.onSave,
    this.movieToEdit,
  }) : super(key: key);

  @override
  _AddMoviePageState createState() => _AddMoviePageState();
}

class _AddMoviePageState extends State<AddMoviePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Se vier um movieToEdit, preenche os campos para edição
    if (widget.movieToEdit != null) {
      _titleController.text = widget.movieToEdit!.title;
      _genreController.text = widget.movieToEdit!.genre;
      _yearController.text = widget.movieToEdit!.year.toString();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _genreController.dispose();
    _yearController.dispose();
    super.dispose();
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
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'O título é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo Gênero
              TextFormField(
                controller: _genreController,
                decoration: const InputDecoration(
                  labelText: 'Gênero',
                  border: OutlineInputBorder(),
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
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'O ano é obrigatório';
                  }
                  final year = int.tryParse(value);
                  if (year == null || year < 1900) {
                    return 'Digite um ano válido (>= 1900)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Botão Salvar
              ElevatedButton(
                onPressed: _handleSave,
                child: Text(isEditing ? 'Salvar Alterações' : 'Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
