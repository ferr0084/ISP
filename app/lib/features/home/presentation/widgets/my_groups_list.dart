import 'package:app/features/groups/presentation/providers/group_provider.dart';
import 'package:app/features/groups/presentation/widgets/group_avatar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MyGroupsList extends StatelessWidget {
  const MyGroupsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GroupProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.hasError) {
          return Center(child: Text('Error: ${provider.errorMessage}'));
        }

        final myGroups = provider.groups;

        if (myGroups.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Groups',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.go('/groups');
                    },
                    child: Text(
                      'View All',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: myGroups.take(3).length, // Show only top 3
              separatorBuilder: (context, index) => const Divider(height: 24.0),
              itemBuilder: (context, index) {
                final group = myGroups[index];
                return ListTile(
                  leading: GroupAvatar(avatarUrl: group.avatarUrl),
                  title: Text(
                    group.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    group.lastMessage,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16.0),
                  onTap: () {
                    context.push('/groups/detail/${group.id}');
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}
