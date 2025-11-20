import 'package:app/features/profile/domain/entities/profile.dart';
import 'package:app/features/profile/domain/usecases/get_profile.dart';
import 'package:app/features/profile/domain/usecases/update_profile.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
        _profile = await _getProfile(_user!.id);
      } else {
        _profile = null;
      }
      notifyListeners();
    });
  }

  User? get user => _user;
  Profile? get profile => _profile;

  Future<void> signUp(String email, String password) async {
    _user = await _signUp(email, password);
    if (_user != null) {
      _profile = await _getProfile(_user!.id);
    }
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    _user = await _signIn(email, password);
    if (_user != null) {
      _profile = await _getProfile(_user!.id);
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    await _signOut();
    _user = null;
    _profile = null;
    notifyListeners();
  }

  Future<void> updateUserProfile(Profile updatedProfile) async {
    if (_user == null) return;

    await _updateProfile(updatedProfile);
    _user = Supabase.instance.client.auth.currentUser;
    if (_user != null) {
      _profile = await _getProfile(_user!.id);
    }
    notifyListeners();
  }
}
