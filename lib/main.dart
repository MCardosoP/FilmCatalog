import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'views/home_page.dart';
import 'models/movie.dart';

/// Ponto de entrada do aplicativo.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter(); // Inicializa o Hive
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(MovieAdapter());
  }
  runApp(const MovieApp());
}

/// Widget raiz do aplicativo.
class MovieApp extends StatelessWidget {
  const MovieApp({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Catálogo de Filmes',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(), // Tela inicial do app
    );
  }
}