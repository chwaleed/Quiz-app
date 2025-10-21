import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:testproject/models/user_model.dart';
import 'package:testproject/models/quiz_attempt_model.dart';
import 'package:testproject/services/database_service.dart';

/// Provider for managing user profile state and quiz history
///
/// This provider handles:
/// - User profile data
/// - User statistics
/// - Quiz attempt history
/// - User performance analytics
/// - Real-time user data updates
class UserProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  // User data state
  UserModel? _user;
  bool _isLoadingUser = false;
  String? _userError;

  // Quiz history state
  List<QuizAttemptModel> _quizHistory = [];
  bool _isLoadingHistory = false;
  String? _historyError;

  // Filtered history
  List<QuizAttemptModel> _filteredHistory = [];
  String? _historyFilter; // 'all', 'passed', 'failed'
  String? _historySortBy; // 'date', 'score', 'quiz'

  // User statistics
  Map<String, dynamic>? _statistics;
  bool _isLoadingStatistics = false;

  // Real-time stream subscription
  StreamSubscription<UserModel?>? _userSubscription;

  // Getters - User Data
  UserModel? get user => _user;
  bool get isLoadingUser => _isLoadingUser;
  String? get userError => _userError;

  // Getters - Quiz History
  List<QuizAttemptModel> get quizHistory => _filteredHistory;
  bool get isLoadingHistory => _isLoadingHistory;
  String? get historyError => _historyError;
  String? get historyFilter => _historyFilter;
  String? get historySortBy => _historySortBy;

  // Getters - Statistics
  Map<String, dynamic>? get statistics => _statistics;
  bool get isLoadingStatistics => _isLoadingStatistics;

  // Convenience getters
  int get totalPoints => _user?.totalPoints ?? 0;
  int get quizzesAttempted => _user?.quizzesAttempted ?? 0;
  int get quizzesPassed => _user?.quizzesPassed ?? 0;
  double get averageScore => _user?.averageScore ?? 0.0;
  double get passRate => _user?.passRate ?? 0.0;
  bool get hasAttemptedQuizzes => quizzesAttempted > 0;

  /// Load user data by user ID
  Future<bool> loadUser(String userId, {bool forceRefresh = false}) async {
    if (_isLoadingUser && !forceRefresh) return false;

    try {
      _isLoadingUser = true;
      _userError = null;
      notifyListeners();

      final userData = await _dbService.getUser(userId);
      if (userData != null) {
        _user = userData;
        return true;
      }

      _userError = 'User not found';
      return false;
    } catch (e) {
      _userError = 'Failed to load user: ${e.toString()}';
      return false;
    } finally {
      _isLoadingUser = false;
      notifyListeners();
    }
  }

  /// Enable real-time updates for user data
  void enableRealtimeUserUpdates(String userId) {
    _userSubscription?.cancel();
    _userSubscription = _dbService
        .watchUser(userId)
        .listen(
          (userData) {
            if (userData != null) {
              _user = userData;
              notifyListeners();
            }
          },
          onError: (error) {
            _userError = 'Real-time update error: ${error.toString()}';
            notifyListeners();
          },
        );
  }

  /// Disable real-time updates for user data
  void disableRealtimeUserUpdates() {
    _userSubscription?.cancel();
    _userSubscription = null;
  }

  /// Load quiz attempt history for the current user
  Future<void> loadQuizHistory(
    String userId, {
    bool forceRefresh = false,
  }) async {
    if (_isLoadingHistory && !forceRefresh) return;

    try {
      _isLoadingHistory = true;
      _historyError = null;
      notifyListeners();

      _quizHistory = await _dbService.getUserQuizAttempts(userId);
      _applyHistoryFilters();
      _calculateStatistics();
    } catch (e) {
      _historyError = 'Failed to load quiz history: ${e.toString()}';
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  /// Filter quiz history by pass/fail status
  ///
  /// [filter] can be 'all', 'passed', or 'failed'
  void filterHistory(String? filter) {
    _historyFilter = filter;
    _applyHistoryFilters();
  }

  /// Sort quiz history
  ///
  /// [sortBy] can be 'date' (newest first), 'score' (highest first), or 'quiz' (alphabetical)
  void sortHistory(String sortBy) {
    _historySortBy = sortBy;
    _applyHistoryFilters();
  }

  /// Clear all history filters and sorting
  void clearHistoryFilters() {
    _historyFilter = null;
    _historySortBy = null;
    _applyHistoryFilters();
  }

  /// Get attempts for a specific quiz
  List<QuizAttemptModel> getQuizAttempts(String quizId) {
    return _quizHistory.where((attempt) => attempt.quizId == quizId).toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
  }

  /// Get the best attempt for a specific quiz
  QuizAttemptModel? getBestAttempt(String quizId) {
    final attempts = getQuizAttempts(quizId);
    if (attempts.isEmpty) return null;

    return attempts.reduce((a, b) => a.percentage > b.percentage ? a : b);
  }

  /// Get the latest attempt for a specific quiz
  QuizAttemptModel? getLatestAttempt(String quizId) {
    final attempts = getQuizAttempts(quizId);
    if (attempts.isEmpty) return null;

    return attempts.first; // Already sorted by date
  }

  /// Check if user has attempted a specific quiz
  bool hasAttemptedQuiz(String quizId) {
    return _quizHistory.any((attempt) => attempt.quizId == quizId);
  }

  /// Get total attempts count for a specific quiz
  int getQuizAttemptCount(String quizId) {
    return _quizHistory.where((attempt) => attempt.quizId == quizId).length;
  }

  /// Calculate and cache user statistics
  void _calculateStatistics() {
    if (_quizHistory.isEmpty) {
      _statistics = {
        'totalAttempts': 0,
        'totalPassed': 0,
        'totalFailed': 0,
        'passRate': 0.0,
        'averageScore': 0.0,
        'averageTimePerQuiz': 0,
        'bestScore': 0.0,
        'worstScore': 0.0,
        'totalTimeTaken': 0,
        'recentActivity': <QuizAttemptModel>[],
      };
      return;
    }

    final totalAttempts = _quizHistory.length;
    final passedAttempts = _quizHistory.where((a) => a.isPassed).length;
    final failedAttempts = totalAttempts - passedAttempts;

    final totalScore = _quizHistory.fold<double>(
      0,
      (sum, attempt) => sum + attempt.percentage,
    );

    final totalTime = _quizHistory.fold<int>(
      0,
      (sum, attempt) => sum + attempt.timeTaken,
    );

    final sortedByScore = [..._quizHistory]
      ..sort((a, b) => b.percentage.compareTo(a.percentage));

    final recentActivity = [..._quizHistory]
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

    _statistics = {
      'totalAttempts': totalAttempts,
      'totalPassed': passedAttempts,
      'totalFailed': failedAttempts,
      'passRate': (passedAttempts / totalAttempts) * 100,
      'averageScore': totalScore / totalAttempts,
      'averageTimePerQuiz': totalTime ~/ totalAttempts,
      'bestScore': sortedByScore.first.percentage,
      'worstScore': sortedByScore.last.percentage,
      'totalTimeTaken': totalTime,
      'recentActivity': recentActivity.take(5).toList(),
    };
  }

  /// Get statistics for a specific time period
  Map<String, dynamic> getStatisticsForPeriod(
    DateTime startDate,
    DateTime endDate,
  ) {
    final periodAttempts = _quizHistory.where((attempt) {
      return attempt.completedAt.isAfter(startDate) &&
          attempt.completedAt.isBefore(endDate);
    }).toList();

    if (periodAttempts.isEmpty) {
      return {'totalAttempts': 0, 'totalPassed': 0, 'averageScore': 0.0};
    }

    final passedCount = periodAttempts.where((a) => a.isPassed).length;
    final totalScore = periodAttempts.fold<double>(
      0,
      (sum, attempt) => sum + attempt.percentage,
    );

    return {
      'totalAttempts': periodAttempts.length,
      'totalPassed': passedCount,
      'averageScore': totalScore / periodAttempts.length,
      'passRate': (passedCount / periodAttempts.length) * 100,
    };
  }

  /// Get quiz history for the last N days
  List<QuizAttemptModel> getRecentHistory(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _quizHistory
        .where((attempt) => attempt.completedAt.isAfter(cutoffDate))
        .toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
  }

  /// Get performance trend (improving, declining, stable)
  String getPerformanceTrend() {
    if (_quizHistory.length < 3) return 'insufficient_data';

    final recent = [..._quizHistory]
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

    final recentScores = recent.take(3).map((a) => a.percentage).toList();
    final olderScores = recent
        .skip(3)
        .take(3)
        .map((a) => a.percentage)
        .toList();

    if (olderScores.isEmpty) return 'insufficient_data';

    final recentAvg =
        recentScores.reduce((a, b) => a + b) / recentScores.length;
    final olderAvg = olderScores.reduce((a, b) => a + b) / olderScores.length;

    final difference = recentAvg - olderAvg;

    if (difference > 5) return 'improving';
    if (difference < -5) return 'declining';
    return 'stable';
  }

  /// Refresh all user data
  Future<void> refreshAll(String userId) async {
    await Future.wait([
      loadUser(userId, forceRefresh: true),
      loadQuizHistory(userId, forceRefresh: true),
    ]);
  }

  /// Clear all user data (for logout)
  void clearUserData() {
    _user = null;
    _quizHistory.clear();
    _filteredHistory.clear();
    _statistics = null;
    _historyFilter = null;
    _historySortBy = null;
    disableRealtimeUserUpdates();
    notifyListeners();
  }

  // Private methods
  void _applyHistoryFilters() {
    _filteredHistory = _quizHistory;

    // Apply filter
    if (_historyFilter != null) {
      switch (_historyFilter) {
        case 'passed':
          _filteredHistory = _filteredHistory.where((a) => a.isPassed).toList();
          break;
        case 'failed':
          _filteredHistory = _filteredHistory
              .where((a) => !a.isPassed)
              .toList();
          break;
        default: // 'all'
          break;
      }
    }

    // Apply sorting
    switch (_historySortBy) {
      case 'score':
        _filteredHistory.sort((a, b) => b.percentage.compareTo(a.percentage));
        break;
      case 'quiz':
        _filteredHistory.sort((a, b) => a.quizId.compareTo(b.quizId));
        break;
      case 'date':
      default:
        _filteredHistory.sort((a, b) => b.completedAt.compareTo(a.completedAt));
        break;
    }

    notifyListeners();
  }

  /// Clear error messages
  void clearErrors() {
    _userError = null;
    _historyError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}
