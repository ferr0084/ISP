import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/providers/user_provider.dart';
import '../../features/auth/presentation/screens/login_callback_screen.dart';
import '../../features/auth/presentation/screens/login_or_create_account_screen.dart';
import '../../features/chats/presentation/screens/chat_detail_screen.dart';
import '../../features/chats/presentation/screens/chat_list_screen.dart';
import '../../features/common/presentation/pages/settings_page.dart';
import '../../features/events/presentation/screens/events_dashboard_screen.dart';
import '../../features/expenses/presentation/screens/expenses_home_screen.dart';
import '../../features/groups/presentation/providers/group_detail_provider.dart';
import '../../features/groups/presentation/screens/create_group_screen.dart';
import '../../features/groups/presentation/screens/edit_group_screen.dart';
import '../../features/groups/presentation/screens/group_home_screen.dart';
import '../../features/groups/presentation/screens/group_invite_screen.dart';
import '../../features/groups/presentation/screens/group_members_screen.dart';
import '../../features/groups/presentation/screens/invite_accept_screen.dart';
import '../../features/groups/presentation/screens/my_groups_overview_screen.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/idiot_game/presentation/screens/idiot_game_dashboard_screen.dart';
import '../../features/profile/presentation/screens/profile_editing_screen.dart';
import '../../features/profile/presentation/screens/profile_view_screen.dart';

class AppRouter {
  final UserProvider _userProvider;

  AppRouter(this._userProvider);

  late final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    refreshListenable: _userProvider,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LoginOrCreateAccountScreen(),
      ),
      GoRoute(
        path: '/login-callback',
        builder: (context, state) => const LoginCallbackScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
      GoRoute(
        path: '/chats',
        builder: (context, state) => const ChatListScreen(),
        routes: [
          GoRoute(
            path: ':chatId',
            builder: (context, state) {
              final chatId = state.pathParameters['chatId']!;
              final chatName = state.extra as String?;
              return ChatDetailScreen(
                chatId: chatId,
                chatName: chatName ?? 'Group Chat',
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/groups',
        builder: (context, state) => const MyGroupsOverviewScreen(),
        routes: [
          GoRoute(
            path: 'create',
            builder: (context, state) => const CreateGroupScreen(),
          ),
          GoRoute(
            path: 'edit',
            builder: (context, state) {
              final groupId = state.extra as String;
              return EditGroupScreen(groupId: groupId);
            },
          ),
          GoRoute(
            path: 'detail/:groupId',
            builder: (context, state) {
              final groupId = state.pathParameters['groupId']!;
              return GroupHomeScreen(groupId: groupId);
            },
            routes: [
              GoRoute(
                path: 'members',
                builder: (context, state) {
                  final groupId = state.pathParameters['groupId']!;
                  final groupDetailProvider =
                      state.extra as GroupDetailProvider;
                  return ChangeNotifierProvider.value(
                    value: groupDetailProvider,
                    child: GroupMembersScreen(groupId: groupId),
                  );
                },
              ),
              GoRoute(
                path: 'invite',
                builder: (context, state) {
                  final groupId = state.pathParameters['groupId']!;
                  return GroupInviteScreen(groupId: groupId);
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/events',
        builder: (context, state) => const EventsDashboardScreen(),
      ),
      GoRoute(
        path: '/expenses',
        builder: (context, state) => const ExpensesHomeScreen(),
      ),
      GoRoute(
        path: '/idiot-game',
        builder: (context, state) => const IdiotGameDashboardScreen(),
      ),

      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/invite-accept',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'];
          final groupId = state.uri.queryParameters['groupId'];
          return InviteAcceptScreen(token: token, groupId: groupId);
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
