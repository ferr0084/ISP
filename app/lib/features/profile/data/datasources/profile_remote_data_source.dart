import 'dart:io';

import '../../domain/entities/profile.dart';

abstract class ProfileRemoteDataSource {
  Future<Profile> getProfile(String id);
  Future<void> updateProfile(Profile profile);
  Future<String> uploadAvatar(File file);
  Future<void> updateLastSeen(String userId);
}
