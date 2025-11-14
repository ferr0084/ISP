import 'package:supabase_flutter/supabase_flutter.dart';

import '../repositories/auth_repository.dart';

class GetUser {
  final AuthRepository repository;

  GetUser(this.repository);

  User? call() {
    return repository.currentUser;
  }
}
