import 'package:app/features/groups/data/datasources/group_members_remote_data_source.dart';
import 'package:app/features/groups/domain/entities/group_member.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupMembersRemoteDataSourceImpl implements GroupMembersRemoteDataSource {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  @override
  Future<List<GroupMember>> getGroupMembers(String groupId) async {
    final List<Map<String, dynamic>> response = await _supabaseClient
        .from('group_members')
        .select('''
          user_id,
          joined_at,
          role,
          profiles(full_name, avatar_url, email)
        ''')
        .eq('group_id', groupId)
        .limit(3); // Limit to 3 for preview

    if (response.isEmpty) {
      return [];
    }

    try {
      return response.map((json) {
        final profileData = json['profiles'];
        return GroupMember(
          userId: json['user_id'],
          name: profileData?['full_name'] ?? 'Unknown',
          avatarUrl: profileData?['avatar_url'],
          email: profileData?['email'] ?? 'unknown@example.com',
          joinedAt: DateTime.parse(json['joined_at']),
          role: json['role'],
        );
      }).toList();
    } catch (e) {
      throw Exception('Error parsing group members: $e');
    }
  }
}
