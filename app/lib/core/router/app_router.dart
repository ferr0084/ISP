import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/user_provider.dart';
import '../../features/auth/presentation/screens/login_callback_screen.dart';
import '../../features/auth/presentation/screens/login_or_create_account_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/chats/presentation/screens/chat_list_screen.dart';
import '../../features/groups/presentation/screens/group_home_screen.dart';
import '../../features/groups/presentation/screens/create_group_screen.dart';
import '../../features/groups/presentation/screens/edit_group_screen.dart';
import '../../features/groups/presentation/screens/my_groups_overview_screen.dart'; // New import
import '../../features/events/presentation/screens/events_dashboard_screen.dart';
import '../../features/expenses/presentation/screens/expenses_home_screen.dart'; // New import
import '../../features/idiot_game/presentation/screens/idiot_game_dashboard_screen.dart'; // New import

import '../../features/contacts/presentation/screens/contact_list_screen.dart';
import '../../features/contacts/presentation/screens/contact_detail_screen.dart'; // Added import
import '../../features/contacts/presentation/screens/invite_friends_screen.dart'; // New import
import '../../features/common/presentation/pages/settings_page.dart';
import '../../features/profile/presentation/screens/profile_editing_screen.dart';
import '../../features/profile/presentation/screens/profile_view_screen.dart';
import '../../features/contacts/presentation/screens/invite_accept_screen.dart'; // Added import

class AppRouter {
  final UserProvider _userProvider;

  AppRouter(this._userProvider);

  late final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    refreshListenable: _userProvider,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => WelcomeScreen(),
        routes: [
          GoRoute(
            path: 'login-or-create-account',
            builder: (context, state) => LoginOrCreateAccountScreen(),
          ),
          GoRoute(
            path: 'login-callback',
            builder: (context, state) => LoginCallbackScreen(),
          ),
        ],
      ),
      GoRoute(path: '/home', builder: (context, state) => HomePage()),
      GoRoute(path: '/chats', builder: (context, state) => ChatListScreen()),
      GoRoute(
        path: '/groups',
        builder: (context, state) =>
            MyGroupsOverviewScreen(), // Changed to MyGroupsOverviewScreen
        routes: [
          GoRoute(
            path: 'create',
            builder: (context, state) => CreateGroupScreen(),
          ),
          GoRoute(
            path: 'edit',
            builder: (context, state) {
              final groupId = state.extra as String;
              return EditGroupScreen(groupId: groupId);
            },
          ),
          GoRoute(
            path: 'detail', // Sub-route for GroupHomeScreen
            builder: (context, state) {
              final groupId = state.extra as String;
              return GroupHomeScreen(groupId: groupId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/events',
        builder: (context, state) => EventsDashboardScreen(),
      ),
      GoRoute(
        path: '/expenses',
        builder: (context, state) => ExpensesHomeScreen(),
      ),
      GoRoute(
        path: '/idiot-game',
        builder: (context, state) => IdiotGameDashboardScreen(),
      ),
      GoRoute(
        path: '/contacts',
        builder: (context, state) => const ContactListScreen(),
        routes: [
          GoRoute(
            path: 'detail/:id',
            builder: (context, state) {
              final contactId = state.pathParameters['id']!;
              return ContactDetailScreen(contactId: contactId);
            },
          ),
          GoRoute(
            path: 'invite',
            builder: (context, state) => const InviteFriendsScreen(),
          ),
        ],
      ),
      GoRoute(path: '/settings', builder: (context, state) => SettingsPage()),
      GoRoute(
        path: '/invite-accept',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'];
          return InviteAcceptScreen(token: token);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileViewScreen(),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, state) => const ProfileEditingScreen(),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final user = _userProvider.user;
      final isLoggingIn =
          state.matchedLocation == '/' ||
          state.matchedLocation == '/login-or-create-account' ||
          state.matchedLocation == '/login-callback';

      if (user == null) {
        return isLoggingIn ? null : '/';
      }

      if (isLoggingIn) {
        return '/home';
      }

      return null;
    },
  );
}
