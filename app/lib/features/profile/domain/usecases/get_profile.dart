import 'dart:async';

import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class GetProfile {
  final ProfileRepository repository;

  GetProfile(this.repository);

  Future<Profile> call(String id) {
    return repository.getProfile(id);
  }
}
