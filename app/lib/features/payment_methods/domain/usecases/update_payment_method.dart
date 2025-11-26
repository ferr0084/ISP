import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/payment_method.dart';
import '../repositories/payment_method_repository.dart';

class UpdatePaymentMethod {
  final PaymentMethodRepository repository;

  UpdatePaymentMethod(this.repository);

  Future<Either<Failure, PaymentMethod>> call(PaymentMethod paymentMethod) async {
    try {
      final updatedPaymentMethod = await repository.updatePaymentMethod(paymentMethod);
      return Right(updatedPaymentMethod);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

class DeletePaymentMethod {
  final PaymentMethodRepository repository;

  DeletePaymentMethod(this.repository);

  Future<Either<Failure, void>> call(String paymentMethodId) async {
    try {
      await repository.deletePaymentMethod(paymentMethodId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

class SetDefaultPaymentMethod {
  final PaymentMethodRepository repository;

  SetDefaultPaymentMethod(this.repository);

  Future<Either<Failure, void>> call(String paymentMethodId, String userId) async {
    try {
      await repository.setDefaultPaymentMethod(paymentMethodId, userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}