import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthController _authController = AuthController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _authController.init().then((_) {
      setState(() {
        _initialized = true;
      });
    });
  }

  void _register() async {
    if (!_initialized) return; // garante que o Hive foi iniciado
    if (!_formKey.currentState!.validate()) return;

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    final error = await _authController.register(username, password);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuário cadastrado com sucesso!")),
      );

      // Navega de volta para a tela de login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cadastrar Usuário")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                "Crie sua conta para acessar o catálogo de filmes",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Campo Nome de Usuário
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: "Nome de usuário",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                  hintText: "Mínimo 3 caracteres, sem espaços",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Digite um nome de usuário";
                  }
                  if (value.length < 3) {
                    return "Mínimo 3 caracteres";
                  }
                  if (value.contains(' ')) {
                    return "Não pode conter espaços";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo Senha
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: "Senha",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Digite uma senha";
                  }
                  if (value.length < 4) {
                    return "A senha deve ter pelo menos 4 caracteres";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo Confirmar Senha
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: "Confirmar senha",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Confirme sua senha";
                  }
                  if (value != _passwordController.text) {
                    return "As senhas não coincidem";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Botão Cadastrar
              ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  "Cadastrar",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 16),

              // Link para Login
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                child: const Text("Já tem uma conta? Faça login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}