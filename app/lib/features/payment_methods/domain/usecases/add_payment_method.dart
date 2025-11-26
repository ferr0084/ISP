import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/payment_method.dart';
import '../repositories/payment_method_repository.dart';

class AddPaymentMethod {
  final PaymentMethodRepository repository;

  AddPaymentMethod(this.repository);

  Future<Either<Failure, PaymentMethod>> call(PaymentMethod paymentMethod) async {
    try {
      final addedPaymentMethod = await repository.addPaymentMethod(paymentMethod);
      return Right(addedPaymentMethod);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}