import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/payment_method.dart';
import '../repositories/payment_method_repository.dart';

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