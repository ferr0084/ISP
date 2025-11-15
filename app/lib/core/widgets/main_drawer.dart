import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app/features/auth/presentation/providers/user_provider.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouter.of(
      context,
    ).routerDelegate.currentConfiguration.uri.toString();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              final user = userProvider.user;
              final userName =
                  user?.email ?? 'Guest'; // Fallback to email or 'Guest'
              final userAvatarUrl =
                  user?.userMetadata?['avatar_url'] as String?;

              return GestureDetector(
                onTap: () {
                  context.go('/profile');
                },
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: userAvatarUrl != null
                            ? NetworkImage(userAvatarUrl)
                            : const AssetImage('assets/images/avatar_james.png')
                                as ImageProvider, // Default avatar
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      userName,
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: Colors.white),
                    ),
                    InkWell(
                      onTap: () {
                        context.push('/profile');
                        Navigator.pop(context); // Close the drawer
                      },
                      child: Text(
                        'View Profile',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.home,
            title: 'Home Page',
            route: '/home',
            currentRoute: currentRoute,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.chat_bubble_outline,
            title: 'Chats',
            route: '/chats',
            currentRoute: currentRoute,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.group,
            title: 'Groups',
            route: '/groups',
            currentRoute: currentRoute,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.event,
            title: 'Events',
            route: '/events',
            currentRoute: currentRoute,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.receipt_long,
            title: 'Expenses',
            route: '/expenses',
            currentRoute: currentRoute,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.casino, // Placeholder icon for Idiot Game
            title: 'Idiot Game',
            route: '/idiot-game',
            currentRoute: currentRoute,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.contacts,
            title: 'Contacts',
            route: '/contacts',
            currentRoute: currentRoute,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.settings,
            title: 'Settings',
            route: '/settings',
            currentRoute: currentRoute,
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(
                  Icons.dark_mode,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(width: 16.0),
                Text(
                  'Dark Mode',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: Theme.of(context).brightness == Brightness.dark,
                  onChanged: (value) {
                    // TODO: Implement theme switching logic
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    required String currentRoute,
  }) {
    final isSelected = currentRoute == route;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurface,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: isSelected
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSurface,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Theme.of(context).colorScheme.primary,
      onTap: () {
        GoRouter.of(context).push(route);
        Navigator.pop(context); // Close the drawer
      },
    );
  }
}
