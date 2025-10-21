import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:testproject/models/user_model.dart';
import 'package:testproject/services/database_service.dart';

/// Provider for managing leaderboard state and operations
///
/// This provider handles:
/// - Global leaderboard (top users by points)
/// - Quiz-specific leaderboards
/// - User rankings
/// - Real-time leaderboard updates
/// - Time period filtering
class LeaderboardProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  // Global leaderboard state
  List<UserModel> _globalLeaderboard = [];
  bool _isLoadingGlobal = false;
  String? _globalError;
  int _globalLimit = 10;

  // Quiz leaderboard state
  Map<String, List<Map<String, dynamic>>> _quizLeaderboards = {};
  bool _isLoadingQuizLeaderboard = false;
  String? _quizLeaderboardError;
  String? _currentQuizId;

  // User rank state
  Map<String, int> _userRanks = {}; // userId -> rank
  bool _isLoadingUserRank = false;

  // Real-time stream subscription
  StreamSubscription<List<UserModel>>? _leaderboardSubscription;

  // Getters - Global Leaderboard
  List<UserModel> get globalLeaderboard => _globalLeaderboard;
  bool get isLoadingGlobal => _isLoadingGlobal;
  String? get globalError => _globalError;
  int get globalLimit => _globalLimit;

  // Getters - Quiz Leaderboard
  List<Map<String, dynamic>> get currentQuizLeaderboard =>
      _currentQuizId != null ? (_quizLeaderboards[_currentQuizId!] ?? []) : [];
  bool get isLoadingQuizLeaderboard => _isLoadingQuizLeaderboard;
  String? get quizLeaderboardError => _quizLeaderboardError;
  String? get currentQuizId => _currentQuizId;

  // Getters - User Rank
  bool get isLoadingUserRank => _isLoadingUserRank;

  /// Load the global leaderboard
  ///
  /// [limit] - Number of top users to fetch (default: 10)
  /// [forceRefresh] - Force reload even if already loading
  Future<void> loadGlobalLeaderboard({
    int limit = 10,
    bool forceRefresh = false,
  }) async {
    if (_isLoadingGlobal && !forceRefresh) return;

    try {
      _isLoadingGlobal = true;
      _globalError = null;
      _globalLimit = limit;
      notifyListeners();

      _globalLeaderboard = await _dbService.getLeaderboard(limit: limit);
    } catch (e) {
      _globalError = 'Failed to load leaderboard: ${e.toString()}';
    } finally {
      _isLoadingGlobal = false;
      notifyListeners();
    }
  }

  /// Enable real-time updates for the global leaderboard
  ///
  /// [limit] - Number of top users to watch
  void enableRealtimeLeaderboard({int limit = 10}) {
    _leaderboardSubscription?.cancel();
    _globalLimit = limit;

    _leaderboardSubscription = _dbService
        .watchLeaderboard(limit: limit)
        .listen(
          (users) {
            _globalLeaderboard = users;
            notifyListeners();
          },
          onError: (error) {
            _globalError = 'Real-time update error: ${error.toString()}';
            notifyListeners();
          },
        );
  }

  /// Disable real-time updates for the global leaderboard
  void disableRealtimeLeaderboard() {
    _leaderboardSubscription?.cancel();
    _leaderboardSubscription = null;
  }

  /// Load leaderboard for a specific quiz
  ///
  /// Returns list of maps containing 'user' (UserModel) and 'attempt' (QuizAttemptModel)
  Future<void> loadQuizLeaderboard({
    required String quizId,
    int limit = 10,
    bool forceRefresh = false,
  }) async {
    if (_isLoadingQuizLeaderboard && !forceRefresh) return;

    try {
      _isLoadingQuizLeaderboard = true;
      _quizLeaderboardError = null;
      _currentQuizId = quizId;
      notifyListeners();

      final leaderboard = await _dbService.getQuizLeaderboard(
        quizId: quizId,
        limit: limit,
      );

      _quizLeaderboards[quizId] = leaderboard;
    } catch (e) {
      _quizLeaderboardError =
          'Failed to load quiz leaderboard: ${e.toString()}';
    } finally {
      _isLoadingQuizLeaderboard = false;
      notifyListeners();
    }
  }

  /// Get a user's rank on the global leaderboard
  ///
  /// Returns the rank (1-based index) or null if not found
  /// Caches the result for performance
  Future<int?> getUserRank(String userId, {bool forceRefresh = false}) async {
    if (_userRanks.containsKey(userId) && !forceRefresh) {
      return _userRanks[userId];
    }

    try {
      _isLoadingUserRank = true;
      notifyListeners();

      final rank = await _dbService.getUserRank(userId);
      _userRanks[userId] = rank;
      return rank;
    } catch (e) {
      return null;
    } finally {
      _isLoadingUserRank = false;
      notifyListeners();
    }
  }

  /// Get the top N users from the global leaderboard
  List<UserModel> getTopUsers(int count) {
    return _globalLeaderboard.take(count).toList();
  }

  /// Get the top 3 users (podium) from the global leaderboard
  List<UserModel> getPodium() {
    return getTopUsers(3);
  }

  /// Check if a user is in the top N of the global leaderboard
  bool isUserInTop(String userId, int topCount) {
    final topUsers = getTopUsers(topCount);
    return topUsers.any((user) => user.uid == userId);
  }

  /// Find a user's position in the global leaderboard list
  ///
  /// Returns the index (0-based) in the current loaded list, or -1 if not found
  /// Note: This is different from getUserRank which gets the actual global rank
  int findUserInLeaderboard(String userId) {
    return _globalLeaderboard.indexWhere((user) => user.uid == userId);
  }

  /// Get leaderboard statistics
  Map<String, dynamic> getLeaderboardStats() {
    if (_globalLeaderboard.isEmpty) {
      return {
        'totalUsers': 0,
        'averagePoints': 0.0,
        'highestPoints': 0,
        'lowestPoints': 0,
      };
    }

    final totalPoints = _globalLeaderboard.fold<int>(
      0,
      (sum, user) => sum + user.totalPoints,
    );

    return {
      'totalUsers': _globalLeaderboard.length,
      'averagePoints': totalPoints / _globalLeaderboard.length,
      'highestPoints': _globalLeaderboard.first.totalPoints,
      'lowestPoints': _globalLeaderboard.last.totalPoints,
    };
  }

  /// Get a specific user from the quiz leaderboard
  Map<String, dynamic>? getQuizLeaderboardEntry(String quizId, String userId) {
    final leaderboard = _quizLeaderboards[quizId];
    if (leaderboard == null) return null;

    try {
      return leaderboard.firstWhere(
        (entry) => (entry['user'] as UserModel).uid == userId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get rank for a user in a specific quiz leaderboard
  int? getQuizRank(String quizId, String userId) {
    final leaderboard = _quizLeaderboards[quizId];
    if (leaderboard == null) return null;

    for (int i = 0; i < leaderboard.length; i++) {
      final user = leaderboard[i]['user'] as UserModel;
      if (user.uid == userId) {
        return i + 1; // 1-based rank
      }
    }

    return null;
  }

  /// Refresh all cached data
  Future<void> refreshAll() async {
    await loadGlobalLeaderboard(limit: _globalLimit, forceRefresh: true);

    if (_currentQuizId != null) {
      await loadQuizLeaderboard(quizId: _currentQuizId!, forceRefresh: true);
    }

    // Clear rank cache to force refresh
    _userRanks.clear();
  }

  /// Clear a specific quiz leaderboard from cache
  void clearQuizLeaderboard(String quizId) {
    _quizLeaderboards.remove(quizId);
    if (_currentQuizId == quizId) {
      _currentQuizId = null;
    }
    notifyListeners();
  }

  /// Clear all cached quiz leaderboards
  void clearAllQuizLeaderboards() {
    _quizLeaderboards.clear();
    _currentQuizId = null;
    notifyListeners();
  }

  /// Clear error messages
  void clearErrors() {
    _globalError = null;
    _quizLeaderboardError = null;
    notifyListeners();
  }

  /// Update leaderboard limit and reload
  Future<void> updateLimit(int newLimit) async {
    if (newLimit != _globalLimit) {
      await loadGlobalLeaderboard(limit: newLimit, forceRefresh: true);
    }
  }

  @override
  void dispose() {
    _leaderboardSubscription?.cancel();
    super.dispose();
  }
}
