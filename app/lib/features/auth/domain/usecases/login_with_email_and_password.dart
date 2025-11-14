import 'package:supabase_flutter/supabase_flutter.dart';

import '../repositories/auth_repository.dart';

class LoginWithEmailAndPassword {
  final AuthRepository repository;

  LoginWithEmailAndPassword(this.repository);

  Future<User?> call(String email, String password) {
    return repository.signIn(email, password);
  }
}
