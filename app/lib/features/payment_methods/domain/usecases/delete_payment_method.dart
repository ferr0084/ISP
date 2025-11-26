import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/payment_method.dart';
import '../repositories/payment_method_repository.dart';

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