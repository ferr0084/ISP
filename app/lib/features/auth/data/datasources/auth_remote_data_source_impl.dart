import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import 'auth_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<User> signUp(String email, String password) async {
    try {
      final response =
          await supabaseClient.auth.signUp(email: email, password: password);
      if (response.user == null) {
        throw ServerException();
      }
      return response.user!;
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<User> signIn(String email, String password) async {
    try {
      final response = await supabaseClient.auth
          .signInWithPassword(email: email, password: password);
      if (response.user == null) {
        throw ServerException();
      }
      return response.user!;
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  User? get currentUser => supabaseClient.auth.currentUser;
}
