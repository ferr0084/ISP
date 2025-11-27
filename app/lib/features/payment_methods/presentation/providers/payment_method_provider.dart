import 'package:flutter/material.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/usecases/add_payment_method.dart';
import '../../domain/usecases/delete_payment_method.dart' as delete_usecase;
import '../../domain/usecases/get_payment_methods.dart';
import '../../domain/usecases/set_default_payment_method.dart' as set_default_usecase;
import '../../domain/usecases/update_payment_method.dart' as update_usecase;

class PaymentMethodProvider with ChangeNotifier {
  final GetPaymentMethods _getPaymentMethods;
  final AddPaymentMethod _addPaymentMethod;
  final update_usecase.UpdatePaymentMethod _updatePaymentMethod;
  final delete_usecase.DeletePaymentMethod _deletePaymentMethod;
  final set_default_usecase.SetDefaultPaymentMethod _setDefaultPaymentMethod;

  PaymentMethodProvider(
    this._getPaymentMethods,
    this._addPaymentMethod,
    this._updatePaymentMethod,
    this._deletePaymentMethod,
    this._setDefaultPaymentMethod,
  );

  List<PaymentMethod> _paymentMethods = [];
  bool _isLoading = false;
  String? _error;

  List<PaymentMethod> get paymentMethods => _paymentMethods;
  bool get isLoading => _isLoading;
  String? get error => _error;

  PaymentMethod? get defaultPaymentMethod =>
      _paymentMethods.where((pm) => pm.isDefault).firstOrNull;

  Future<void> fetchPaymentMethods(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _getPaymentMethods(userId);
    result.fold(
      (failure) {
        if (failure is ServerFailure) {
          _error = failure.message;
        } else {
          _error = 'An error occurred';
        }
        _paymentMethods = [];
      },
      (paymentMethods) {
        _paymentMethods = paymentMethods;
        _error = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addPaymentMethod(PaymentMethod paymentMethod) async {
    final result = await _addPaymentMethod(paymentMethod);
    return result.fold(
      (failure) {
        _error = failure is ServerFailure ? failure.message : 'Failed to add payment method';
        notifyListeners();
        return false;
      },
      (addedPaymentMethod) {
        _paymentMethods.add(addedPaymentMethod);
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> updatePaymentMethod(PaymentMethod paymentMethod) async {
    final result = await _updatePaymentMethod(paymentMethod);
    return result.fold(
      (failure) {
        _error = failure is ServerFailure ? failure.message : 'Failed to update payment method';
        notifyListeners();
        return false;
      },
      (updatedPaymentMethod) {
        final index = _paymentMethods.indexWhere((pm) => pm.id == updatedPaymentMethod.id);
        if (index != -1) {
          _paymentMethods[index] = updatedPaymentMethod;
          notifyListeners();
        }
        return true;
      },
    );
  }

  Future<bool> deletePaymentMethod(String paymentMethodId) async {
    final result = await _deletePaymentMethod(paymentMethodId);
    return result.fold(
      (failure) {
        _error = failure is ServerFailure ? failure.message : 'Failed to delete payment method';
        notifyListeners();
        return false;
      },
      (_) {
        _paymentMethods.removeWhere((pm) => pm.id == paymentMethodId);
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> setDefaultPaymentMethod(String paymentMethodId, String userId) async {
    final result = await _setDefaultPaymentMethod(paymentMethodId, userId);
    return result.fold(
      (failure) {
        _error = failure is ServerFailure ? failure.message : 'Failed to set default payment method';
        notifyListeners();
        return false;
      },
      (_) {
        // Update local state
        for (var i = 0; i < _paymentMethods.length; i++) {
          _paymentMethods[i] = _paymentMethods[i].copyWith(
            isDefault: _paymentMethods[i].id == paymentMethodId,
          );
        }
        notifyListeners();
        return true;
      },
    );
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearData() {
    _paymentMethods = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}