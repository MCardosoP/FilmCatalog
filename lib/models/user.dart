import 'package:hive/hive.dart';
part 'user.g.dart';

@HiveType(typeId: 1)
class User extends HiveObject {
  @HiveField(0)
  String email;

  @HiveField(1)
  String password; // senha criptografada

  User({required this.email, required this.password});
}
