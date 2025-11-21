import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class LoginWithEmailAndPassword
    implements UseCase<User, LoginWithEmailAndPasswordParams> {
  final AuthRepository repository;

  LoginWithEmailAndPassword(this.repository);

  @override
  Future<Either<Failure, User>> call(LoginWithEmailAndPasswordParams params) {
    return repository.signIn(params.email, params.password);
  }
}

class LoginWithEmailAndPasswordParams extends Equatable {
  final String email;
  final String password;

  const LoginWithEmailAndPasswordParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}
