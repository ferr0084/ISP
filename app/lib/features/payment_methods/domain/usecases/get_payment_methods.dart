import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/payment_method.dart';
import '../repositories/payment_method_repository.dart';

class GetPaymentMethods {
  final PaymentMethodRepository repository;

  GetPaymentMethods(this.repository);

  Future<Either<Failure, List<PaymentMethod>>> call(String userId) async {
    try {
      final paymentMethods = await repository.getPaymentMethods(userId);
      return Right(paymentMethods);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}