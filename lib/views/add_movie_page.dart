import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../controllers/movie_controller.dart';

class AddMoviePage extends StatefulWidget {
  final MovieController controller;

  const AddMoviePage({Key? key, required this.controller}) : super(key: key);

  @override
  State<AddMoviePage> createState() => _AddMoviePageState();
}

class _AddMoviePageState extends State<AddMoviePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  void _saveMovie() {
    if (_formKey.currentState!.validate()) {
      final newMovie = Movie(
        title: _titleController.text,
        genre: _genreController.text,
        year: int.parse(_yearController.text),
      );

      widget.controller.addMovie(newMovie);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Filme adicionado com sucesso!")),
      );

      Navigator.pop(context); // Volta para a HomePage
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Adicionar Filme")),
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
                  labelText: "Título",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "O título é obrigatório";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo Gênero
              TextFormField(
                controller: _genreController,
                decoration: const InputDecoration(
                  labelText: "Gênero",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "O gênero é obrigatório";
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
                  labelText: "Ano de lançamento",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "O ano é obrigatório";
                  }
                  final year = int.tryParse(value);
                  if (year == null || year < 1900) {
                    return "Digite um ano válido (>= 1900)";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Botão Salvar
              ElevatedButton.icon(
                onPressed: _saveMovie,
                icon: const Icon(Icons.save),
                label: const Text("Salvar Filme"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}