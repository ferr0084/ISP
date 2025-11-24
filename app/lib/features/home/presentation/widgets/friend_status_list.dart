import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/friend_status_provider.dart';

class FriendStatusList extends StatelessWidget {
  const FriendStatusList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FriendStatusProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.error != null) {
          return SizedBox(
            height: 100,
            child: Center(child: Text('Error: ${provider.error}')),
          );
        }

        final friendStatuses = provider.friendStatuses;

        if (friendStatuses.isEmpty) {
          return const SizedBox(
            height: 100,
            child: Center(child: Text('No active friends found.')),
          );
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
                    'Friend Statuses',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.push('/friend-statuses');
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
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: friendStatuses.length,
                itemBuilder: (context, index) {
                  final friend = friendStatuses[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            context.push('/users/${friend.id}');
                          },
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage:
                                    friend.avatarUrl != null &&
                                        friend.avatarUrl!.isNotEmpty
                                    ? NetworkImage(friend.avatarUrl!)
                                    : const AssetImage(
                                            'assets/images/avatar_placeholder.png',
                                          )
                                          as ImageProvider,
                                child:
                                    friend.avatarUrl == null ||
                                        friend.avatarUrl!.isEmpty
                                    ? const Icon(Icons.person)
                                    : null,
                              ),
                              if (friend.isOnline)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 15,
                                    height: 15,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Theme.of(
                                          context,
                                        ).scaffoldBackgroundColor,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          friend.name,
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
