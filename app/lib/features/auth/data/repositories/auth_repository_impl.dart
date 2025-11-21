import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, User>> signUp(String email, String password) async {
    try {
      final user = await remoteDataSource.signUp(email, password);
      return Right(user);
    } on ServerException {
      return Left(ServerFailure('Server Failure'));
    }
  }

  @override
  Future<Either<Failure, User>> signIn(String email, String password) async {
    try {
      final user = await remoteDataSource.signIn(email, password);
      return Right(user);
    } on ServerException {
      return Left(ServerFailure('Server Failure'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure('Server Failure'));
    }
  }

  @override
  User? get currentUser => remoteDataSource.currentUser;

  @override
  Future<void> updateProfile(String name) {
    // TODO: implement updateProfile
    throw UnimplementedError();
  }
}
