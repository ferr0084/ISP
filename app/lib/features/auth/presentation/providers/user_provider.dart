import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/usecases/login_with_email_and_password.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/sign_up.dart';

class UserProvider extends ChangeNotifier {
  final SignUp _signUp;
  final LoginWithEmailAndPassword _signIn;
  final Logout _signOut;

  User? _user;

  UserProvider(this._signUp, this._signIn, this._signOut) {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      _user = data.session?.user;
      notifyListeners();
    });
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

  Future<void> updateUserProfile(String name) async {
    if (_user == null) return;

    final updates = {
      'id': _user!.id,
      'name': name,
      'updated_at': DateTime.now().toIso8601String(),
    };

    await Supabase.instance.client.from('profiles').upsert(updates);
    _user = Supabase.instance.client.auth.currentUser;
    notifyListeners();
  }
}
