import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/profile.dart';
import 'profile_remote_data_source.dart';

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseClient supabaseClient;
  final Uuid uuid;

  ProfileRemoteDataSourceImpl({
    required this.supabaseClient,
    required this.uuid,
  });

  @override
  Future<Profile> getProfile(String id) async {
    try {
      final response = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', id)
          .single();
      return Profile.fromMap(response);
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> updateProfile(Profile profile) async {
    try {
      await supabaseClient.from('profiles').upsert(profile.toMap());
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<String> uploadAvatar(File file) async {
    try {
      final String fileName = uuid.v4();
      await supabaseClient.storage.from('avatars').upload(fileName, file);
      return supabaseClient.storage.from('avatars').getPublicUrl(fileName);
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> updateLastSeen(String userId) async {
    try {
      await supabaseClient
          .from('profiles')
          .update({'last_seen': DateTime.now().toIso8601String()})
          .eq('id', userId);
    } catch (e) {
      throw ServerException();
    }
  }
}
