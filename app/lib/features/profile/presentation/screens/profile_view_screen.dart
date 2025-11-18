import 'package:app/features/auth/presentation/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ProfileViewScreen extends StatelessWidget {
  const ProfileViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.push('/profile/edit');
            },
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.user;
          final profile = userProvider.profile;
          final userAvatarUrl = user?.userMetadata?['avatar_url'] as String?;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: userAvatarUrl != null
                            ? NetworkImage(userAvatarUrl)
                            : const AssetImage('assets/images/avatar_s.png')
                                  as ImageProvider, // Placeholder image
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        profile?.fullName ?? 'N/A',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        user?.email ?? 'N/A',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(color: Colors.grey),
                      ),
                      const SizedBox(height: 16.0),
                      const Text(
                        'UX Designer and coffee enthusiast.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16.0),
                      ),
                      const SizedBox(height: 32.0),
                      // Removed ElevatedButton since the functionality is moved to AppBar actions
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
