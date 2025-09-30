import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../controllers/movie_controller.dart';

class EditMoviePage extends StatefulWidget {
  final MovieController controller;
  final int movieIndex;
  final Movie movie;

  const EditMoviePage({
    Key? key,
    required this.controller,
    required this.movieIndex,
    required this.movie,
  }) : super(key: key);

  @override
  State<EditMoviePage> createState() => _EditMoviePageState();
}

class _EditMoviePageState extends State<EditMoviePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _genreController;
  late TextEditingController _yearController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.movie.title);
    _genreController = TextEditingController(text: widget.movie.genre);
    _yearController = TextEditingController(text: widget.movie.year.toString());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _genreController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _editMovie() {
    if (_formKey.currentState!.validate()) {
      final updatedMovie = Movie(
        title: _titleController.text,
        genre: _genreController.text,
        year: int.tryParse(_yearController.text) ?? 0,
      );

      widget.controller.updateMovie(widget.movieIndex, updatedMovie);

      Navigator.pop(context); // volta para detalhes/lista
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Filme")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Título"),
                validator: (value) =>
                value == null || value.isEmpty ? "Informe o título" : null,
              ),
              TextFormField(
                controller: _genreController,
                decoration: const InputDecoration(labelText: "Gênero"),
                validator: (value) =>
                value == null || value.isEmpty ? "Informe o gênero" : null,
              ),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(labelText: "Ano"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Informe o ano";
                  }
                  final year = int.tryParse(value);
                  if (year == null || year < 1900) {
                    return "Ano inválido";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _editMovie,
                child: const Text("Salvar Alterações"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
