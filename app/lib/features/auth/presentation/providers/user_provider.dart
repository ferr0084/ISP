import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/usecases/get_user.dart';
import '../../domain/usecases/login_with_email_and_password.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/sign_up.dart';

class UserProvider extends ChangeNotifier {
  final GetUser _getUser;
  final SignUp _signUp;
  final LoginWithEmailAndPassword _signIn;
  final Logout _signOut;

  User? _user;

  UserProvider(this._getUser, this._signUp, this._signIn, this._signOut) {
    _user = _getUser();
  }

  User? get user => _user;

  Future<void> signUp(String email, String password) async {
    _user = await _signUp(email, password);
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    _user = await _signIn(email, password);
    notifyListeners();
  }

  Future<void> signOut() async {
    await _signOut();
    _user = null;
    notifyListeners();
  }
}
