import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/idiot_game/domain/entities/achievement.dart';
import 'package:app/features/idiot_game/domain/entities/game.dart';
import 'package:app/features/idiot_game/domain/entities/game_with_details.dart';
import 'package:app/features/idiot_game/domain/entities/user_stats.dart';
import 'package:app/features/idiot_game/domain/usecases/create_game.dart';
import 'package:app/features/idiot_game/domain/usecases/get_game_details.dart';
import 'package:app/features/idiot_game/domain/usecases/get_game_history.dart';
import 'package:app/features/idiot_game/domain/usecases/get_group_games.dart';
import 'package:app/features/idiot_game/domain/usecases/get_potential_players.dart';
import 'package:app/features/idiot_game/domain/usecases/get_recent_games.dart';
import 'package:app/features/idiot_game/domain/usecases/get_user_achievements.dart';
import 'package:app/features/idiot_game/domain/usecases/get_user_stats.dart';
import 'package:app/features/profile/domain/entities/user_profile.dart';
import 'package:flutter/foundation.dart';

class IdiotGameProvider with ChangeNotifier {
  final GetPotentialPlayers getPotentialPlayers;
  final CreateGame createGame;
  final GetRecentGames getRecentGames;
  final GetGameHistory getGameHistory;
  final GetGameDetails getGameDetails;
  final GetUserStats getUserStats;
  final GetUserAchievements getUserAchievements;

  final GetGroupGames getGroupGames;

  IdiotGameProvider({
    required this.getPotentialPlayers,
    required this.createGame,
    required this.getRecentGames,
    required this.getGameHistory,
    required this.getGameDetails,
    required this.getUserStats,
    required this.getUserAchievements,
    required this.getGroupGames,
  });

  List<UserProfile> _potentialPlayers = [];
  List<Game> _recentGames = [];
  List<Game> _gameHistory = [];
  GameWithDetails? _selectedGameDetails;
  UserStats? _userStats;
  List<Achievement> _achievements = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<UserProfile> get potentialPlayers => _potentialPlayers;
  List<Game> get recentGames => _recentGames;
  List<Game> get gameHistory => _gameHistory;
  GameWithDetails? get selectedGameDetails => _selectedGameDetails;
  UserStats? get userStats => _userStats;
  List<Achievement> get achievements => _achievements;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchPotentialPlayersData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final failureOrPlayers = await getPotentialPlayers(NoParams());

    failureOrPlayers.fold(
      (failure) {
        _errorMessage = 'Failed to fetch players';
      },
      (players) {
        _potentialPlayers = players;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createNewGame(
    List<String> userIds,
    String description,
    String loserId,
    String? groupId,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final params = CreateGameParams(
      userIds: userIds,
      description: description,
      loserId: loserId,
      groupId: groupId,
    );
    final failureOrGame = await createGame(params);

    failureOrGame.fold(
      (failure) {
        _errorMessage = 'Failed to create game';
      },
      (game) {
        // Refresh recent games after creating a new one
        fetchRecentGamesData();
        // Refresh group games if we have a group context
        if (groupId != null) {
          fetchGroupGamesData(groupId);
        }
        // We need the current user ID to fetch stats.
        // Assuming `loserId` is the current user's ID for simplicity here,
        // or this should be passed from a user session.
        fetchUserStatsData(loserId); // Refresh stats too
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchRecentGamesData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final failureOrGames = await getRecentGames(NoParams());

    failureOrGames.fold(
      (failure) {
        _errorMessage = 'Failed to fetch recent games';
      },
      (games) {
        _recentGames = games;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  List<Game> _groupGames = [];
  List<Game> get groupGames => _groupGames;

  Future<void> fetchGroupGamesData(String groupId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final params = GetGroupGamesParams(groupId: groupId);
    final failureOrGames = await getGroupGames(params);

    failureOrGames.fold(
      (failure) {
        _errorMessage = 'Failed to fetch group games';
      },
      (games) {
        _groupGames = games;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchGameHistoryData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final failureOrGames = await getGameHistory(NoParams());

    failureOrGames.fold(
      (failure) {
        _errorMessage = 'Failed to fetch game history';
      },
      (games) {
        _gameHistory = games;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchGameDetailsData(String gameId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final params = GetGameDetailsParams(gameId: gameId);
    final failureOrGameDetails = await getGameDetails(params);

    failureOrGameDetails.fold(
      (failure) {
        _errorMessage = 'Failed to fetch game details';
      },
      (gameDetails) {
        _selectedGameDetails = gameDetails;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchUserStatsData(String userId) async {
    // Don't set loading to true to avoid full screen loader if just refreshing stats
    // Or maybe we want it? Let's keep it simple for now.

    // We need the current user ID. Ideally this should be passed or obtained from auth service.
    // For now, we assume the auth provider or similar is handling user session.
    // But wait, GetUserStatsParams needs userId.
    // I'll assume the repository or data source handles getting current user if I pass a special ID or I need to get it here.
    // The remote data source uses `supabaseClient.auth.currentUser!.id`.
    // So I can pass that ID. But I don't have access to supabase client here.
    // I should probably pass the user ID from the UI or have a way to get current user ID.
    // For now, let's assume the UI will pass it or I'll fetch it from a user provider if I had one.
    // Actually, `IdiotGameRemoteDataSourceImpl` uses `supabaseClient.auth.currentUser!.id` for `createGame`.
    // But `getUserStats` takes `userId`.
    // I'll add `userId` as parameter to `fetchUserStats`.
    final params = GetUserStatsParams(userId: userId);
    final failureOrStats = await getUserStats(params);

    failureOrStats.fold(
      (failure) {
        // silently fail or log?
      },
      (stats) {
        _userStats = stats;
        notifyListeners();
      },
    );
  }

  Future<void> fetchUserAchievementsData(String userId) async {
    final params = GetUserAchievementsParams(userId: userId);
    final failureOrAchievements = await getUserAchievements(params);

    failureOrAchievements.fold(
      (failure) {
        // silently fail?
      },
      (achievements) {
        _achievements = achievements;
        notifyListeners();
      },
    );
  }
}
