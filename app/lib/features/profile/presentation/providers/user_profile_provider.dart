import 'package:flutter/material.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/profile.dart';
import '../../domain/usecases/get_profile.dart';

class UserProfileProvider extends ChangeNotifier {
  final GetProfile getProfile;

  UserProfileProvider({required this.getProfile});

  Profile? _profile;
  Profile? get profile => _profile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchProfile(String userId) async {
    _isLoading = true;
    _error = null;
    _profile = null; // Clear previous profile
    notifyListeners();

    final result = await getProfile(userId);

    result.fold(
      (failure) {
        if (failure is ServerFailure) {
          _error = failure.message;
        } else {
          _error = failure.toString();
        }
        _isLoading = false;
        notifyListeners();
      },
      (profile) {
        _profile = profile;
        _isLoading = false;
        notifyListeners();
      },
    );
  }
}
