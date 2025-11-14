import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/user_provider.dart';
import '../../features/auth/presentation/screens/login_callback_screen.dart';
import '../../features/auth/presentation/screens/login_or_create_account_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/common/presentation/pages/chats_page.dart';
import '../../features/common/presentation/pages/groups_page.dart';
import '../../features/common/presentation/pages/events_page.dart';
import '../../features/common/presentation/pages/expenses_page.dart';
import '../../features/common/presentation/pages/idiot_game_page.dart';
import '../../features/common/presentation/pages/contacts_page.dart';
import '../../features/common/presentation/pages/settings_page.dart';

class AppRouter {
  final UserProvider _userProvider;

  AppRouter(this._userProvider);

  late final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    refreshListenable: _userProvider,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const WelcomeScreen(),
        routes: [
          GoRoute(
            path: 'login-or-create-account',
            builder: (context, state) => const LoginOrCreateAccountScreen(),
          ),
          GoRoute(
            path: 'login-callback',
            builder: (context, state) => const LoginCallbackScreen(),
          ),
        ],
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
      GoRoute(path: '/chats', builder: (context, state) => const ChatsPage()),
      GoRoute(path: '/groups', builder: (context, state) => const GroupsPage()),
      GoRoute(path: '/events', builder: (context, state) => const EventsPage()),
      GoRoute(path: '/expenses', builder: (context, state) => const ExpensesPage()),
      GoRoute(path: '/idiot-game', builder: (context, state) => const IdiotGamePage()),
      GoRoute(path: '/contacts', builder: (context, state) => const ContactsPage()),
      GoRoute(path: '/settings', builder: (context, state) => const SettingsPage()),
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
