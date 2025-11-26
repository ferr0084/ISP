import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../di/service_locator.dart';
import '../../features/auth/presentation/providers/user_provider.dart';
import '../../features/auth/presentation/screens/login_callback_screen.dart';
import '../../features/auth/presentation/screens/login_or_create_account_screen.dart';
import '../../features/chats/presentation/screens/chat_detail_screen.dart';
import '../../features/chats/presentation/screens/chat_list_screen.dart';
import '../../features/common/presentation/pages/settings_page.dart';
import '../../features/events/presentation/screens/create_event_screen.dart';
import '../../features/events/presentation/screens/event_details_screen.dart';
import '../../features/events/presentation/screens/events_dashboard_screen.dart';
import '../../features/expenses/presentation/screens/expenses_home_screen.dart';
import '../../features/expenses/presentation/providers/expense_transaction_provider.dart';
import '../../features/events/presentation/providers/expense_summary_provider.dart';
import '../../features/groups/presentation/providers/group_detail_provider.dart';
import '../../features/groups/presentation/screens/create_group_screen.dart';
import '../../features/groups/presentation/screens/edit_group_screen.dart';
import '../../features/groups/presentation/screens/group_home_screen.dart';
import '../../features/groups/presentation/screens/group_invite_screen.dart';
import '../../features/groups/presentation/screens/group_members_screen.dart';
import '../../features/groups/presentation/screens/invite_accept_screen.dart';
import '../../features/groups/presentation/screens/my_groups_overview_screen.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/friend_status_screen.dart';
import '../../features/idiot_game/presentation/providers/idiot_game_provider.dart';
import '../../features/idiot_game/presentation/screens/idiot_game_dashboard_screen.dart';
import '../../features/idiot_game/presentation/screens/achievements_stats_screen.dart';
import '../../features/idiot_game/presentation/screens/game_details_screen.dart';
import '../../features/idiot_game/presentation/screens/game_history_screen.dart';
import '../../features/idiot_game/presentation/screens/new_game_screen.dart';
import '../../features/notifications/presentation/providers/notification_provider.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/profile/presentation/screens/profile_editing_screen.dart';
import '../../features/profile/presentation/screens/profile_stats_screen.dart';
import '../../features/profile/presentation/screens/profile_view_screen.dart';
import '../../features/profile/presentation/screens/user_profile_screen.dart';
import '../../features/profile/presentation/providers/user_profile_provider.dart';
import '../../features/events/presentation/providers/expense_summary_provider.dart';
import '../../features/payment_methods/presentation/screens/payment_methods_screen.dart';
import '../../features/payment_methods/presentation/screens/add_card_screen.dart';
import '../../features/payment_methods/presentation/screens/add_bank_account_screen.dart';

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
      GoRoute(path: '/home', builder: (context, state) => ChangeNotifierProvider(
        create: (_) => sl<ExpenseSummaryProvider>(),
        child: const HomePage(),
      )),
      GoRoute(
        path: '/friend-statuses',
        builder: (context, state) => const FriendStatusScreen(),
      ),
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
      ShellRoute(
        builder: (context, state, child) {
          return child;
        },
        routes: [
          GoRoute(
            path: '/events',
            builder: (context, state) => const EventsDashboardScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const CreateEventScreen(),
              ),
              GoRoute(
                path: ':eventId',
                builder: (context, state) {
                  final eventId = state.pathParameters['eventId']!;
                  return EventDetailsScreen(eventId: eventId);
                },
              ),
            ],
          ),
        ],
      ),
       GoRoute(
         path: '/expenses',
         builder: (context, state) => MultiProvider(
           providers: [
             ChangeNotifierProvider(
               create: (_) => sl<ExpenseTransactionProvider>(),
             ),
             ChangeNotifierProvider(
               create: (_) => sl<ExpenseSummaryProvider>(),
             ),
           ],
           child: const ExpensesHomeScreen(),
         ),
       ),
        GoRoute(
          path: '/payment-methods',
          builder: (context, state) => const PaymentMethodsScreen(),
        ),
        GoRoute(
          path: '/add-card',
          builder: (context, state) => const AddCardScreen(),
        ),
        GoRoute(
          path: '/add-bank-account',
          builder: (context, state) => const AddBankAccountScreen(),
        ),
       ShellRoute(
        builder: (context, state, child) {
          return ChangeNotifierProvider(
            create: (_) => sl<IdiotGameProvider>(),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/idiot-game',
            builder: (context, state) => const IdiotGameDashboardScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) {
                  final groupId = state.extra as String?;
                  return NewGameScreen(groupId: groupId);
                },
              ),
              GoRoute(
                path: 'history',
                builder: (context, state) => const GameHistoryScreen(),
              ),
              GoRoute(
                path: 'stats',
                builder: (context, state) => const AchievementsStatsScreen(),
              ),
              GoRoute(
                path: 'details/:gameId',
                builder: (context, state) {
                  final gameId = state.pathParameters['gameId']!;
                  return GameDetailsScreen(gameId: gameId);
                },
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: '/expenses',
        builder: (context, state) => MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => sl<ExpenseTransactionProvider>(),
            ),
            ChangeNotifierProvider(
              create: (_) => sl<ExpenseSummaryProvider>(),
            ),
          ],
          child: const ExpensesHomeScreen(),
        ),
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
          GoRoute(
            path: 'stats',
            builder: (context, state) => const ProfileStatsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/users/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return ChangeNotifierProvider(
            create: (_) => sl<UserProfileProvider>(),
            child: UserProfileScreen(userId: userId),
          );
        },
      ),
      ShellRoute(
        builder: (context, state, child) {
          return ChangeNotifierProvider(
            create: (_) => sl<NotificationProvider>(),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationsScreen(),
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
