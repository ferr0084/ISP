import '../entities/payment_method.dart';

abstract class PaymentMethodRepository {
  Future<List<PaymentMethod>> getPaymentMethods(String userId);
  Future<PaymentMethod> getPaymentMethod(String paymentMethodId);
  Future<PaymentMethod> addPaymentMethod(PaymentMethod paymentMethod);
  Future<PaymentMethod> updatePaymentMethod(PaymentMethod paymentMethod);
  Future<void> deletePaymentMethod(String paymentMethodId);
  Future<void> setDefaultPaymentMethod(String paymentMethodId, String userId);
}