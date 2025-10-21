import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:testproject/models/quiz_model.dart';
import 'package:testproject/models/question_model.dart';
import 'package:testproject/models/quiz_attempt_model.dart';
import 'package:testproject/models/user_answer_model.dart';
import 'package:testproject/services/database_service.dart';

/// Provider for managing quiz-related state and operations
///
/// This provider handles:
/// - Loading and caching quizzes
/// - Filtering and searching quizzes
/// - Quiz taking state management
/// - Answer tracking and scoring
/// - Quiz attempt submission
class QuizProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  // Quiz list state
  List<QuizModel> _quizzes = [];
  List<QuizModel> _filteredQuizzes = [];
  bool _isLoadingQuizzes = false;
  String? _quizzesError;

  // Quiz detail state
  QuizModel? _currentQuiz;
  List<QuestionModel> _currentQuestions = [];
  bool _isLoadingQuizDetail = false;
  String? _quizDetailError;

  // Quiz taking state
  bool _isQuizActive = false;
  int _currentQuestionIndex = 0;
  Map<int, int> _selectedAnswers = {}; // questionIndex -> selectedOptionIndex
  DateTime? _quizStartTime;
  int _timeRemaining = 0;
  Timer? _quizTimer;

  // Filters
  String? _selectedCategory;
  String? _selectedDifficulty;
  String _searchQuery = '';

  // Real-time stream subscription
  StreamSubscription<List<QuizModel>>? _quizzesSubscription;

  // Getters - Quiz List
  List<QuizModel> get quizzes => _filteredQuizzes;
  bool get isLoadingQuizzes => _isLoadingQuizzes;
  String? get quizzesError => _quizzesError;
  List<String> get categories =>
      _quizzes.map((q) => q.category).toSet().toList();

  // Getters - Quiz Detail
  QuizModel? get currentQuiz => _currentQuiz;
  List<QuestionModel> get currentQuestions => _currentQuestions;
  bool get isLoadingQuizDetail => _isLoadingQuizDetail;
  String? get quizDetailError => _quizDetailError;

  // Getters - Quiz Taking
  bool get isQuizActive => _isQuizActive;
  int get currentQuestionIndex => _currentQuestionIndex;
  QuestionModel? get currentQuestion =>
      _currentQuestions.isNotEmpty &&
          _currentQuestionIndex < _currentQuestions.length
      ? _currentQuestions[_currentQuestionIndex]
      : null;
  int get totalQuestions => _currentQuestions.length;
  int get answeredQuestionsCount => _selectedAnswers.length;
  bool get isQuizComplete =>
      _selectedAnswers.length == _currentQuestions.length;
  int get timeRemaining => _timeRemaining;
  double get progress =>
      totalQuestions > 0 ? _currentQuestionIndex / totalQuestions : 0.0;

  // Getters - Filters
  String? get selectedCategory => _selectedCategory;
  String? get selectedDifficulty => _selectedDifficulty;
  String get searchQuery => _searchQuery;

  /// Load all active quizzes from the database
  Future<void> loadQuizzes({
    bool forceRefresh = false,
    bool isAdmin = false,
  }) async {
    if (_isLoadingQuizzes && !forceRefresh) return;

    try {
      _isLoadingQuizzes = true;
      _quizzesError = null;
      notifyListeners();

      // Load all quizzes for admin, only active for regular users
      if (isAdmin) {
        _quizzes = await _dbService.getAllQuizzesForAdmin();
      } else {
        _quizzes = await _dbService.getAllQuizzes();
      }
      _applyFilters();
    } catch (e) {
      _quizzesError = 'Failed to load quizzes: ${e.toString()}';
    } finally {
      _isLoadingQuizzes = false;
      notifyListeners();
    }
  }

  /// Enable real-time quiz updates
  void enableRealtimeUpdates() {
    _quizzesSubscription?.cancel();
    _quizzesSubscription = _dbService.watchQuizzes().listen(
      (quizzes) {
        _quizzes = quizzes;
        _applyFilters();
      },
      onError: (error) {
        _quizzesError = 'Real-time update error: ${error.toString()}';
        notifyListeners();
      },
    );
  }

  /// Disable real-time quiz updates
  void disableRealtimeUpdates() {
    _quizzesSubscription?.cancel();
    _quizzesSubscription = null;
  }

  /// Search quizzes by title or description
  Future<void> searchQuizzes(String query) async {
    _searchQuery = query.trim();

    if (_searchQuery.isEmpty) {
      _applyFilters();
      return;
    }

    try {
      _isLoadingQuizzes = true;
      notifyListeners();

      _quizzes = await _dbService.searchQuizzes(_searchQuery);
      _applyFilters();
    } catch (e) {
      _quizzesError = 'Search failed: ${e.toString()}';
    } finally {
      _isLoadingQuizzes = false;
      notifyListeners();
    }
  }

  /// Filter quizzes by category
  void filterByCategory(String? category) {
    _selectedCategory = category;
    _applyFilters();
  }

  /// Filter quizzes by difficulty
  void filterByDifficulty(String? difficulty) {
    _selectedDifficulty = difficulty;
    _applyFilters();
  }

  /// Clear all filters and search
  void clearFilters() {
    _selectedCategory = null;
    _selectedDifficulty = null;
    _searchQuery = '';
    _applyFilters();
  }

  /// Load a specific quiz with its questions
  Future<bool> loadQuizDetail(String quizId) async {
    try {
      _isLoadingQuizDetail = true;
      _quizDetailError = null;
      notifyListeners();

      final quiz = await _dbService.getQuiz(quizId);
      if (quiz == null) {
        _quizDetailError = 'Quiz not found';
        return false;
      }

      final questions = await _dbService.getQuizQuestions(quizId);
      if (questions.isEmpty) {
        _quizDetailError = 'No questions found for this quiz';
        return false;
      }

      _currentQuiz = quiz;
      _currentQuestions = questions;
      return true;
    } catch (e) {
      _quizDetailError = 'Failed to load quiz: ${e.toString()}';
      return false;
    } finally {
      _isLoadingQuizDetail = false;
      notifyListeners();
    }
  }

  /// Start taking the current quiz
  bool startQuiz() {
    if (_currentQuiz == null || _currentQuestions.isEmpty) {
      return false;
    }

    _isQuizActive = true;
    _currentQuestionIndex = 0;
    _selectedAnswers.clear();
    _quizStartTime = DateTime.now();

    // Start timer if quiz has time limit
    if (_currentQuiz!.hasTimeLimit) {
      _timeRemaining = _currentQuiz!.timeLimit;
      _startTimer();
    }

    notifyListeners();
    return true;
  }

  /// Navigate to the next question
  void nextQuestion() {
    if (_currentQuestionIndex < _currentQuestions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  /// Navigate to the previous question
  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  /// Jump to a specific question by index
  void goToQuestion(int index) {
    if (index >= 0 && index < _currentQuestions.length) {
      _currentQuestionIndex = index;
      notifyListeners();
    }
  }

  /// Select an answer for the current question
  void selectAnswer(int optionIndex) {
    if (!_isQuizActive || currentQuestion == null) return;

    _selectedAnswers[_currentQuestionIndex] = optionIndex;
    print(
      'Selected answer for Q${_currentQuestionIndex + 1}: option $optionIndex (${currentQuestion!.options[optionIndex]})',
    );
    notifyListeners();
  }

  /// Get the selected answer for a specific question
  int? getSelectedAnswer(int questionIndex) {
    final answer = _selectedAnswers[questionIndex];
    print('Getting answer for Q${questionIndex + 1}: $answer');
    return answer;
  }

  /// Check if a specific question has been answered
  bool isQuestionAnswered(int questionIndex) {
    return _selectedAnswers.containsKey(questionIndex);
  }

  /// Submit the quiz and calculate results
  Future<QuizAttemptModel?> submitQuiz(String userId) async {
    if (_currentQuiz == null || !_isQuizActive) return null;

    try {
      _stopTimer();

      final timeTaken = DateTime.now().difference(_quizStartTime!).inSeconds;
      int totalScore = 0;
      int correctAnswers = 0;

      // Calculate score
      for (int i = 0; i < _currentQuestions.length; i++) {
        final question = _currentQuestions[i];
        final selectedAnswer = _selectedAnswers[i];

        if (selectedAnswer != null &&
            selectedAnswer == question.correctAnswerIndex) {
          totalScore += question.points;
          correctAnswers++;
        }
      }

      // Calculate percentage
      final percentage = (_currentQuiz!.totalPoints > 0)
          ? (totalScore / _currentQuiz!.totalPoints) * 100
          : 0.0;

      // Check if passed
      final isPassed = percentage >= _currentQuiz!.passingScore;

      // IMPORTANT: Check for previous attempts to handle retake logic
      final previousAttempt = await _dbService.getUserQuizAttempt(
        userId: userId,
        quizId: _currentQuiz!.id,
      );

      // If a previous attempt exists with canRetake=true, disable it
      // This ensures the retake token is consumed
      if (previousAttempt != null && previousAttempt.canRetake) {
        await _dbService.updateRetakePermission(previousAttempt.id, false);
      }

      // Create quiz attempt (always with canRetake=false for new attempts)
      final attempt = QuizAttemptModel(
        id: '',
        userId: userId,
        quizId: _currentQuiz!.id,
        score: totalScore,
        percentage: percentage,
        correctAnswers: correctAnswers,
        totalQuestions: _currentQuestions.length,
        timeTaken: timeTaken,
        isPassed: isPassed,
        completedAt: DateTime.now(),
        canRetake: false, // Always false for new attempts
      );

      // Save attempt to database
      final attemptId = await _dbService.saveQuizAttempt(attempt);
      final savedAttempt = attempt.copyWith(id: attemptId);

      // Save user answers
      final userAnswers = <UserAnswerModel>[];
      for (int i = 0; i < _currentQuestions.length; i++) {
        final question = _currentQuestions[i];
        final selectedAnswer = _selectedAnswers[i] ?? -1;
        final isCorrect = selectedAnswer == question.correctAnswerIndex;
        final pointsEarned = isCorrect ? question.points : 0;

        userAnswers.add(
          UserAnswerModel(
            id: '',
            attemptId: attemptId,
            questionId: question.id,
            selectedAnswer: selectedAnswer,
            isCorrect: isCorrect,
            pointsEarned: pointsEarned,
          ),
        );
      }

      await _dbService.saveUserAnswers(userAnswers);

      // Update user stats
      await _dbService.updateUserStats(
        userId: userId,
        pointsEarned: totalScore,
        percentage: percentage,
        isPassed: isPassed,
      );

      // Increment quiz attempt count
      await _dbService.incrementQuizAttemptCount(_currentQuiz!.id);

      // End quiz
      _endQuiz();

      return savedAttempt;
    } catch (e) {
      _quizDetailError = 'Failed to submit quiz: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  /// Exit the quiz without submitting
  void exitQuiz() {
    _stopTimer();
    _endQuiz();
  }

  /// Get user's best attempt for a specific quiz
  Future<QuizAttemptModel?> getUserBestAttempt(
    String userId,
    String quizId,
  ) async {
    try {
      return await _dbService.getUserBestAttempt(
        userId: userId,
        quizId: quizId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if user has attempted a quiz (without retake permission)
  /// Returns true if user has attempted and cannot retake
  Future<bool> hasUserAttemptedQuiz(String userId, String quizId) async {
    try {
      // Get the most recent attempt
      final attempt = await _dbService.getUserQuizAttempt(
        userId: userId,
        quizId: quizId,
      );

      if (attempt == null) {
        // No attempt exists - user can take the quiz
        return false;
      }

      // Check if user can retake
      if (attempt.canRetake) {
        // User has permission to retake - allow access
        return false;
      }

      // User has attempted and doesn't have retake permission
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get all quiz submissions (admin only)
  Future<List<Map<String, dynamic>>> getQuizSubmissions(String quizId) async {
    try {
      return await _dbService.getAllQuizSubmissions(quizId);
    } catch (e) {
      return [];
    }
  }

  /// Update retake permission for a user (admin only)
  Future<void> updateRetakePermission(String attemptId, bool canRetake) async {
    try {
      await _dbService.updateRetakePermission(attemptId, canRetake);
    } catch (e) {
      throw Exception('Failed to update retake permission: ${e.toString()}');
    }
  }

  /// Get all attempts for a specific quiz
  Future<List<QuizAttemptModel>> getQuizAttempts(String quizId) async {
    try {
      return await _dbService.getQuizAttempts(quizId);
    } catch (e) {
      return [];
    }
  }

  // Private methods
  void _applyFilters() {
    _filteredQuizzes = _quizzes.where((quiz) {
      // Category filter
      if (_selectedCategory != null && quiz.category != _selectedCategory) {
        return false;
      }

      // Difficulty filter
      if (_selectedDifficulty != null &&
          quiz.difficulty != _selectedDifficulty) {
        return false;
      }

      return true;
    }).toList();

    notifyListeners();
  }

  void _startTimer() {
    _quizTimer?.cancel();
    _quizTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        _timeRemaining--;
        notifyListeners();
      } else {
        // Time's up - auto submit
        timer.cancel();
        // Note: Auto-submit should be handled by the UI listening to timeRemaining
      }
    });
  }

  void _stopTimer() {
    _quizTimer?.cancel();
    _quizTimer = null;
  }

  void _endQuiz() {
    _isQuizActive = false;
    _currentQuestionIndex = 0;
    _selectedAnswers.clear();
    _quizStartTime = null;
    _timeRemaining = 0;
    notifyListeners();
  }

  /// Clear error messages
  void clearErrors() {
    _quizzesError = null;
    _quizDetailError = null;
    notifyListeners();
  }

  /// Delete a quiz (admin only)
  Future<void> deleteQuiz(String quizId) async {
    try {
      // Delete quiz from database
      await _dbService.deleteQuiz(quizId);

      // Remove from local lists
      _quizzes.removeWhere((quiz) => quiz.id == quizId);
      _filteredQuizzes.removeWhere((quiz) => quiz.id == quizId);

      // If the deleted quiz was the current quiz, clear it
      if (_currentQuiz?.id == quizId) {
        _currentQuiz = null;
        _currentQuestions.clear();
      }

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to delete quiz: ${e.toString()}');
    }
  }

  /// Create a new quiz with questions (admin only)
  Future<void> createQuizWithQuestions(
    QuizModel quiz,
    List<QuestionModel> questions,
  ) async {
    try {
      // Create the quiz first
      final quizId = await _dbService.createQuiz(quiz);

      // Add all questions to the quiz
      for (var question in questions) {
        await _dbService.addQuestion(question.copyWith(quizId: quizId));
      }

      // Reload quizzes to include the new one
      await loadQuizzes(forceRefresh: true);
    } catch (e) {
      throw Exception('Failed to create quiz: ${e.toString()}');
    }
  }

  /// Update an existing quiz with questions (admin only)
  Future<void> updateQuizWithQuestions(
    QuizModel quiz,
    List<QuestionModel> questions,
  ) async {
    try {
      // Update the quiz
      await _dbService.updateQuiz(quiz);

      // Get existing questions
      final existingQuestions = await _dbService.getQuizQuestions(quiz.id);

      // Delete removed questions
      for (var existing in existingQuestions) {
        final stillExists = questions.any(
          (q) => q.id == existing.id && q.id.isNotEmpty,
        );
        if (!stillExists) {
          await _dbService.deleteQuestion(existing.id);
        }
      }

      // Add or update questions
      for (var question in questions) {
        if (question.id.isEmpty) {
          // New question - add it
          await _dbService.addQuestion(question.copyWith(quizId: quiz.id));
        } else {
          // Existing question - update it
          await _dbService.updateQuestion(question);
        }
      }

      // Reload quizzes to reflect changes
      await loadQuizzes(forceRefresh: true);
    } catch (e) {
      throw Exception('Failed to update quiz: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    _quizTimer?.cancel();
    _quizzesSubscription?.cancel();
    super.dispose();
  }
}
