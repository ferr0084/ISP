import 'package:app/features/profile/domain/entities/profile.dart';
import 'package:app/features/profile/domain/usecases/get_profile.dart';
import 'package:app/features/profile/domain/usecases/update_profile.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/login_with_email_and_password.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/sign_up.dart';

class UserProvider extends ChangeNotifier {
  final SignUp _signUp;
  final LoginWithEmailAndPassword _signIn;
  final Logout _signOut;
  final UpdateProfile _updateProfile;
  final GetProfile _getProfile;

  User? _user;
  Profile? _profile;

  UserProvider(
    this._signUp,
    this._signIn,
    this._signOut,
    this._updateProfile,
    this._getProfile,
  ) {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      _user = data.session?.user;
      if (_user != null) {
        final result = await _getProfile(_user!.id);
        result.fold(
          (failure) => _profile = null,
          (profile) => _profile = profile,
        );
      } else {
        _profile = null;
      }
      notifyListeners();
    });
  }

  User? get user => _user;
  Profile? get profile => _profile;

  void setProfile(Profile profile) {
    _profile = profile;
    notifyListeners();
  }

  Future<void> signUp(String email, String password) async {
    final result = await _signUp(
      SignUpParams(email: email, password: password),
    );
    result.fold((failure) => _user = null, (user) => _user = user);
    if (_user != null) {
      final profileResult = await _getProfile(_user!.id);
      profileResult.fold(
        (failure) => _profile = null,
        (profile) => _profile = profile,
      );
    }
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    final result = await _signIn(
      LoginWithEmailAndPasswordParams(email: email, password: password),
    );
    result.fold((failure) => _user = null, (user) => _user = user);
    if (_user != null) {
      final profileResult = await _getProfile(_user!.id);
      profileResult.fold(
        (failure) => _profile = null,
        (profile) => _profile = profile,
      );
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    await _signOut(NoParams());
    _user = null;
    _profile = null;
    notifyListeners();
  }

  Future<void> updateUserProfile(Profile updatedProfile) async {
    if (_user == null) return;

    final result = await _updateProfile(updatedProfile);
    result.fold(
      (failure) {
        // TODO: Handle failure
      },
      (_) async {
        final profileResult = await _getProfile(_user!.id);
        profileResult.fold(
          (failure) => _profile = null,
          (profile) => _profile = profile,
        );
      },
    );
    notifyListeners();
  }
}
