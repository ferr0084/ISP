import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app/features/groups/presentation/providers/group_detail_provider.dart';
import 'package:app/features/groups/domain/entities/group_member.dart';

class GroupMembersScreen extends StatelessWidget {
  final String groupId;

  const GroupMembersScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Members'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              // Navigate to the invite screen for this group
              context.push('/groups/detail/$groupId/invite');
            },
          ),
        ],
      ),
      body: Consumer<GroupDetailProvider>(
        builder: (context, groupDetailProvider, child) {
          if (groupDetailProvider.isLoading && groupDetailProvider.members.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (groupDetailProvider.hasError) {
            return Center(child: Text('Error: ${groupDetailProvider.errorMessage!}'));
          }

          final List<GroupMember> members = groupDetailProvider.members;

          if (members.isEmpty) {
            return const Center(child: Text('No members in this group yet.'));
          }

          return ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: member.avatarUrl != null
                      ? NetworkImage(member.avatarUrl!)
                      : null,
                  child: member.avatarUrl == null
                      ? Text(member.name[0].toUpperCase())
                      : null,
                ),
                title: Text(member.name),
                subtitle: Text(member.email),
                trailing: Text(member.role),
                onTap: () {
                  // TODO: Implement member detail view or actions
                  // For example: context.push('/profile/${member.userId}');
                },
              );
            },
          );
        },
      ),
    );
  }
}
