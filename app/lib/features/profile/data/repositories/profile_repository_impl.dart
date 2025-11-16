import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final SupabaseClient _supabaseClient;

  ProfileRepositoryImpl(this._supabaseClient);

  @override
  Future<Profile> getProfile(String id) async {
    final response = await _supabaseClient
        .from('profiles')
        .select()
        .eq('id', id)
        .single();

    return Profile.fromMap(response);
  }

  @override
  Future<void> updateProfile(Profile profile) async {
    await _supabaseClient.from('profiles').upsert(profile.toMap());
  }
}
