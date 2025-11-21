import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Profile>> getProfile(String id) async {
    try {
      final profile = await remoteDataSource.getProfile(id);
      return Right(profile);
    } on ServerException {
      return Left(ServerFailure('Server Failure'));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile(Profile profile) async {
    try {
      await remoteDataSource.updateProfile(profile);
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure('Server Failure'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadAvatar(File file) async {
    try {
      final avatarUrl = await remoteDataSource.uploadAvatar(file);
      return Right(avatarUrl);
    } on ServerException {
      return Left(ServerFailure('Server Failure'));
    }
  }
}
