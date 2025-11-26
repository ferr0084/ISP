import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/payment_method_model.dart';

abstract class PaymentMethodRemoteDataSource {
  Future<List<PaymentMethodModel>> getPaymentMethods(String userId);
  Future<PaymentMethodModel> getPaymentMethod(String paymentMethodId);
  Future<PaymentMethodModel> addPaymentMethod(PaymentMethodModel paymentMethod);
  Future<PaymentMethodModel> updatePaymentMethod(PaymentMethodModel paymentMethod);
  Future<void> deletePaymentMethod(String paymentMethodId);
  Future<void> setDefaultPaymentMethod(String paymentMethodId, String userId);
}

class PaymentMethodRemoteDataSourceImpl implements PaymentMethodRemoteDataSource {
  final SupabaseClient supabaseClient;

  PaymentMethodRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<PaymentMethodModel>> getPaymentMethods(String userId) async {
    final response = await supabaseClient
        .from('payment_methods')
        .select()
        .eq('user_id', userId)
        .order('is_default', ascending: false)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => PaymentMethodModel.fromJson(json))
        .toList();
  }

  @override
  Future<PaymentMethodModel> getPaymentMethod(String paymentMethodId) async {
    final response = await supabaseClient
        .from('payment_methods')
        .select()
        .eq('id', paymentMethodId)
        .single();

    return PaymentMethodModel.fromJson(response);
  }

  @override
  Future<PaymentMethodModel> addPaymentMethod(PaymentMethodModel paymentMethod) async {
    final response = await supabaseClient
        .from('payment_methods')
        .insert(paymentMethod.toJson())
        .select()
        .single();

    return PaymentMethodModel.fromJson(response);
  }

  @override
  Future<PaymentMethodModel> updatePaymentMethod(PaymentMethodModel paymentMethod) async {
    final response = await supabaseClient
        .from('payment_methods')
        .update(paymentMethod.toJson())
        .eq('id', paymentMethod.id)
        .select()
        .single();

    return PaymentMethodModel.fromJson(response);
  }

  @override
  Future<void> deletePaymentMethod(String paymentMethodId) async {
    await supabaseClient
        .from('payment_methods')
        .delete()
        .eq('id', paymentMethodId);
  }

  @override
  Future<void> setDefaultPaymentMethod(String paymentMethodId, String userId) async {
    // First, unset all default payment methods for this user
    await supabaseClient
        .from('payment_methods')
        .update({'is_default': false})
        .eq('user_id', userId);

    // Then set the specified payment method as default
    await supabaseClient
        .from('payment_methods')
        .update({'is_default': true})
        .eq('id', paymentMethodId)
        .eq('user_id', userId);
  }
}