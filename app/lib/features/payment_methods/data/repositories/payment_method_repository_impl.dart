import '../../domain/entities/payment_method.dart';
import '../../domain/repositories/payment_method_repository.dart';
import '../datasources/payment_method_remote_data_source.dart';
import '../models/payment_method_model.dart';

class PaymentMethodRepositoryImpl implements PaymentMethodRepository {
  final PaymentMethodRemoteDataSource remoteDataSource;

  PaymentMethodRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<PaymentMethod>> getPaymentMethods(String userId) async {
    return await remoteDataSource.getPaymentMethods(userId);
  }

  @override
  Future<PaymentMethod> getPaymentMethod(String paymentMethodId) async {
    return await remoteDataSource.getPaymentMethod(paymentMethodId);
  }

  @override
  Future<PaymentMethod> addPaymentMethod(PaymentMethod paymentMethod) async {
    final model = PaymentMethodModel(
      id: paymentMethod.id,
      userId: paymentMethod.userId,
      type: paymentMethod.type,
      name: paymentMethod.name,
      cardBrand: paymentMethod.cardBrand,
      cardLast4: paymentMethod.cardLast4,
      cardExpiryMonth: paymentMethod.cardExpiryMonth,
      cardExpiryYear: paymentMethod.cardExpiryYear,
      bankName: paymentMethod.bankName,
      bankAccountLast4: paymentMethod.bankAccountLast4,
      bankRoutingNumber: paymentMethod.bankRoutingNumber,
      isDefault: paymentMethod.isDefault,
      isVerified: paymentMethod.isVerified,
      createdAt: paymentMethod.createdAt,
      updatedAt: paymentMethod.updatedAt,
    );
    return await remoteDataSource.addPaymentMethod(model);
  }

  @override
  Future<PaymentMethod> updatePaymentMethod(PaymentMethod paymentMethod) async {
    final model = PaymentMethodModel(
      id: paymentMethod.id,
      userId: paymentMethod.userId,
      type: paymentMethod.type,
      name: paymentMethod.name,
      cardBrand: paymentMethod.cardBrand,
      cardLast4: paymentMethod.cardLast4,
      cardExpiryMonth: paymentMethod.cardExpiryMonth,
      cardExpiryYear: paymentMethod.cardExpiryYear,
      bankName: paymentMethod.bankName,
      bankAccountLast4: paymentMethod.bankAccountLast4,
      bankRoutingNumber: paymentMethod.bankRoutingNumber,
      isDefault: paymentMethod.isDefault,
      isVerified: paymentMethod.isVerified,
      createdAt: paymentMethod.createdAt,
      updatedAt: paymentMethod.updatedAt,
    );
    return await remoteDataSource.updatePaymentMethod(model);
  }

  @override
  Future<void> deletePaymentMethod(String paymentMethodId) async {
    await remoteDataSource.deletePaymentMethod(paymentMethodId);
  }

  @override
  Future<void> setDefaultPaymentMethod(String paymentMethodId, String userId) async {
    await remoteDataSource.setDefaultPaymentMethod(paymentMethodId, userId);
  }
}