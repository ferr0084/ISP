import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/friend_status_provider.dart';

class FriendStatusScreen extends StatefulWidget {
  const FriendStatusScreen({super.key});

  @override
  State<FriendStatusScreen> createState() => _FriendStatusScreenState();
}

class _FriendStatusScreenState extends State<FriendStatusScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch statuses when screen loads to ensure fresh data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FriendStatusProvider>(
        context,
        listen: false,
      ).fetchFriendStatuses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend Statuses'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: Consumer<FriendStatusProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }

          if (provider.friendStatuses.isEmpty) {
            return const Center(child: Text('No friend statuses found.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: provider.friendStatuses.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final status = provider.friendStatuses[index];
              return ListTile(
                leading: Stack(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: status.avatarUrl != null
                          ? NetworkImage(status.avatarUrl!)
                          : const AssetImage('assets/images/avatar_s.png')
                                as ImageProvider,
                    ),
                    if (status.isOnline)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                title: Text(
                  status.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: status.lastActiveAt != null
                    ? Text(
                        status.isOnline
                            ? 'Online'
                            : 'Last seen ${_formatLastSeen(status.lastActiveAt!)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: status.isOnline ? Colors.green : null,
                        ),
                      )
                    : null,
                onTap: () {
                  context.push('/users/${status.id}');
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
