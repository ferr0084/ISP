import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/profile_repository.dart';

class UploadAvatar implements UseCase<String, UploadAvatarParams> {
  final ProfileRepository repository;

  UploadAvatar(this.repository);

  @override
  Future<Either<Failure, String>> call(UploadAvatarParams params) async {
    return await repository.uploadAvatar(params.file);
  }
}

class UploadAvatarParams extends Equatable {
  final File file;

  const UploadAvatarParams({required this.file});

  @override
  List<Object?> get props => [file];
}
