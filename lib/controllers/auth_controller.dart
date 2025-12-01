import 'package:hive/hive.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user.dart';

class AuthController {
  late Box<User> _userBox;
  late Box _sessionBox;

  Future<void> init() async {
    _userBox = await Hive.openBox<User>('users');
    _sessionBox = await Hive.openBox('session');
  }

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  // Cadastro de novo usuário
  Future<String?> register(String username, String password) async {
    // Validação: username não pode estar vazio
    if (username.trim().isEmpty) {
      return 'O nome de usuário não pode estar vazio';
    }

    // Validação: username deve ter pelo menos 3 caracteres
    if (username.trim().length < 3) {
      return 'O nome de usuário deve ter pelo menos 3 caracteres';
    }

    // Validação: username não pode conter espaços
    if (username.contains(' ')) {
      return 'O nome de usuário não pode conter espaços';
    }

    // Validação: senha deve ter pelo menos 4 caracteres
    if (password.length < 4) {
      return 'A senha deve ter pelo menos 4 caracteres';
    }

    // Verifica se já existe (case-insensitive)
    if (_userBox.values.any((u) => u.username.toLowerCase() == username.toLowerCase())) {
      return 'Nome de usuário já cadastrado';
    }

    final hashed = _hashPassword(password);
    await _userBox.add(User(username: username.toLowerCase(), password: hashed));
    return null; // null indica sucesso
  }

  // Login de usuário
  Future<String?> login(String username, String password) async {
    if (username.trim().isEmpty || password.trim().isEmpty) {
      return 'Preencha todos os campos';
    }

    final hashed = _hashPassword(password);

    try {
      final user = _userBox.values.firstWhere(
            (u) => u.username.toLowerCase() == username.toLowerCase() && u.password == hashed,
        orElse: () => User(username: '', password: ''),
      );

      if (user.username.isEmpty) {
        return 'Credenciais inválidas';
      }

      await _sessionBox.put('currentUser', user.username);
      return null;
    } catch (e) {
      return 'Erro ao fazer login: ${e.toString()}';
    }
  }

  // Logout
  Future<void> logout() async {
    await _sessionBox.delete('currentUser');
  }

  // Usuário logado atualmente (username)
  String? get currentUser => _sessionBox.get('currentUser');

  bool get isLoggedIn => _sessionBox.containsKey('currentUser');
}