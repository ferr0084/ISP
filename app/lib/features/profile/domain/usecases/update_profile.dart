import 'dart:async';

import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class UpdateProfile {
  final ProfileRepository repository;

  UpdateProfile(this.repository);

  Future<void> call(Profile profile) {
    return repository.updateProfile(profile);
  }
}
