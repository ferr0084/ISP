import 'dart:async';

import '../entities/profile.dart';

abstract class ProfileRepository {
  Future<Profile> getProfile(String id);
  Future<void> updateProfile(Profile profile);
}
