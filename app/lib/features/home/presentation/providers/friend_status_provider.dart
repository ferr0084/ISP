import 'package:flutter/material.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/friend_status.dart';
import '../../domain/usecases/get_friend_statuses.dart';

class FriendStatusProvider extends ChangeNotifier {
  final GetFriendStatuses getFriendStatuses;

  FriendStatusProvider(this.getFriendStatuses);

  List<FriendStatus> _friendStatuses = [];
  List<FriendStatus> get friendStatuses => _friendStatuses;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchFriendStatuses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getFriendStatuses();

    result.fold(
      (failure) {
        // Assuming failure is ServerFailure or similar with a message property
        // If not, we fallback to toString()
        if (failure is ServerFailure) {
          _error = failure.message;
        } else {
          _error = failure.toString();
        }
        _isLoading = false;
        notifyListeners();
      },
      (statuses) {
        _friendStatuses = statuses;
        _isLoading = false;
        notifyListeners();
      },
    );
  }
}
