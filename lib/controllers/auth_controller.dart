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
  Future<String?> register(String email, String password) async {
    if (_userBox.values.any((u) => u.email == email)) {
      return 'E-mail já cadastrado';
    }

    final hashed = _hashPassword(password);
    await _userBox.add(User(email: email, password: hashed));
    return null; // null indica sucesso
  }

  // Login de usuário
  Future<String?> login(String email, String password) async {
    final hashed = _hashPassword(password);
    final user = _userBox.values.firstWhere(
          (u) => u.email == email && u.password == hashed,
      orElse: () => User(email: '', password: ''),
    );

    if (user.email.isEmpty) {
      return 'Credenciais inválidas';
    }

    await _sessionBox.put('currentUser', email);
    return null;
  }

  // Logout
  Future<void> logout() async {
    await _sessionBox.delete('currentUser');
  }

  // Usuário logado atualmente
  String? get currentUser => _sessionBox.get('currentUser');
}
