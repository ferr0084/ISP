import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, Profile>> getProfile(String id);
  Future<Either<Failure, void>> updateProfile(Profile profile);
  Future<Either<Failure, String>> uploadAvatar(File file);
}
