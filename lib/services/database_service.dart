import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/quiz_model.dart';
import '../models/question_model.dart';
import '../models/quiz_attempt_model.dart';
import '../models/user_answer_model.dart';
import '../core/constants/firebase_constants.dart';

/// Service class for handling all Firestore database operations
class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== USER OPERATIONS ====================

  /// Get user by ID
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .get();

      if (!doc.exists || doc.data() == null) return null;

      return UserModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  /// Update user data
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .update(user.toJson());
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  /// Update user statistics after completing a quiz
  Future<void> updateUserStats({
    required String userId,
    required int pointsEarned,
    required double percentage,
    required bool isPassed,
  }) async {
    try {
      final userDoc = _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId);

      await _firestore.runTransaction((transaction) async {
        final userSnapshot = await transaction.get(userDoc);

        if (!userSnapshot.exists) {
          throw Exception('User not found');
        }

        final userData = userSnapshot.data()!;
        final currentTotalPoints =
            userData[FirebaseConstants.userTotalPointsField] as int? ?? 0;
        final currentQuizzesAttempted =
            userData[FirebaseConstants.userQuizzesCompletedField] as int? ?? 0;
        final currentQuizzesPassed = userData['quizzesPassed'] as int? ?? 0;
        final currentAverageScore =
            (userData[FirebaseConstants.userAverageScoreField] as num?)
                ?.toDouble() ??
            0.0;

        // Calculate new average score
        final totalScore =
            (currentAverageScore * currentQuizzesAttempted) + percentage;
        final newQuizzesAttempted = currentQuizzesAttempted + 1;
        final newAverageScore = totalScore / newQuizzesAttempted;

        transaction.update(userDoc, {
          FirebaseConstants.userTotalPointsField:
              currentTotalPoints + pointsEarned,
          FirebaseConstants.userQuizzesCompletedField: newQuizzesAttempted,
          'quizzesPassed': isPassed
              ? currentQuizzesPassed + 1
              : currentQuizzesPassed,
          FirebaseConstants.userAverageScoreField: newAverageScore,
          FirebaseConstants.userLastActiveField: Timestamp.now(),
        });
      });
    } catch (e) {
      throw Exception('Failed to update user stats: $e');
    }
  }

  /// Get all users (for leaderboard)
  Future<List<UserModel>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  // ==================== QUIZ OPERATIONS ====================

  /// Create a new quiz (admin only)
  Future<String> createQuiz(QuizModel quiz) async {
    try {
      final docRef = await _firestore
          .collection(FirebaseConstants.quizzesCollection)
          .add(quiz.toJson());

      // Update the quiz with its generated ID
      await docRef.update({FirebaseConstants.quizIdField: docRef.id});

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create quiz: $e');
    }
  }

  /// Get quiz by ID
  Future<QuizModel?> getQuiz(String quizId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConstants.quizzesCollection)
          .doc(quizId)
          .get();

      if (!doc.exists || doc.data() == null) return null;

      return QuizModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get quiz: $e');
    }
  }

  /// Get all active quizzes
  Future<List<QuizModel>> getAllQuizzes() async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseConstants.quizzesCollection)
          .where(FirebaseConstants.quizIsActiveField, isEqualTo: true)
          .get();

      // Sort in memory instead of using Firestore orderBy (to avoid index requirement)
      final quizzes = querySnapshot.docs
          .map((doc) => QuizModel.fromJson(doc.data()))
          .toList();

      // Sort by createdAt in descending order
      quizzes.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return quizzes;
    } catch (e) {
      throw Exception('Failed to get quizzes: $e');
    }
  }

  /// Get quizzes by category
  Future<List<QuizModel>> getQuizzesByCategory(String category) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseConstants.quizzesCollection)
          .where(FirebaseConstants.quizIsActiveField, isEqualTo: true)
          .where(FirebaseConstants.quizCategoryField, isEqualTo: category)
          .get();

      // Sort in memory instead of using Firestore orderBy (to avoid index requirement)
      final quizzes = querySnapshot.docs
          .map((doc) => QuizModel.fromJson(doc.data()))
          .toList();

      // Sort by createdAt in descending order
      quizzes.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return quizzes;
    } catch (e) {
      throw Exception('Failed to get quizzes by category: $e');
    }
  }

  /// Get quizzes by difficulty
  Future<List<QuizModel>> getQuizzesByDifficulty(String difficulty) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseConstants.quizzesCollection)
          .where(FirebaseConstants.quizIsActiveField, isEqualTo: true)
          .where(FirebaseConstants.quizDifficultyField, isEqualTo: difficulty)
          .get();

      // Sort in memory instead of using Firestore orderBy (to avoid index requirement)
      final quizzes = querySnapshot.docs
          .map((doc) => QuizModel.fromJson(doc.data()))
          .toList();

      // Sort by createdAt in descending order
      quizzes.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return quizzes;
    } catch (e) {
      throw Exception('Failed to get quizzes by difficulty: $e');
    }
  }

  /// Search quizzes by title
  Future<List<QuizModel>> searchQuizzes(String searchTerm) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseConstants.quizzesCollection)
          .where(FirebaseConstants.quizIsActiveField, isEqualTo: true)
          .get();

      // Filter results by search term (Firestore doesn't support full-text search)
      return querySnapshot.docs
          .map((doc) => QuizModel.fromJson(doc.data()))
          .where(
            (quiz) =>
                quiz.title.toLowerCase().contains(searchTerm.toLowerCase()),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to search quizzes: $e');
    }
  }

  /// Update quiz (admin only)
  Future<void> updateQuiz(QuizModel quiz) async {
    try {
      await _firestore
          .collection(FirebaseConstants.quizzesCollection)
          .doc(quiz.id)
          .update(quiz.toJson());
    } catch (e) {
      throw Exception('Failed to update quiz: $e');
    }
  }

  /// Delete quiz (admin only)
  Future<void> deleteQuiz(String quizId) async {
    try {
      // Delete all questions associated with this quiz
      final questionsSnapshot = await _firestore
          .collection(FirebaseConstants.questionsCollection)
          .where(FirebaseConstants.questionQuizIdField, isEqualTo: quizId)
          .get();

      final batch = _firestore.batch();

      for (var doc in questionsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete the quiz
      batch.delete(
        _firestore.collection(FirebaseConstants.quizzesCollection).doc(quizId),
      );

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete quiz: $e');
    }
  }

  /// Increment quiz attempt count
  Future<void> incrementQuizAttemptCount(String quizId) async {
    try {
      await _firestore
          .collection(FirebaseConstants.quizzesCollection)
          .doc(quizId)
          .update({
            FirebaseConstants.quizAttemptCountField: FieldValue.increment(1),
          });
    } catch (e) {
      throw Exception('Failed to increment attempt count: $e');
    }
  }

  // ==================== QUESTION OPERATIONS ====================

  /// Add question to quiz (admin only)
  Future<String> addQuestion(QuestionModel question) async {
    try {
      final docRef = await _firestore
          .collection(FirebaseConstants.questionsCollection)
          .add(question.toJson());

      // Update the question with its generated ID
      await docRef.update({FirebaseConstants.questionIdField: docRef.id});

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add question: $e');
    }
  }

  /// Get all questions for a quiz
  Future<List<QuestionModel>> getQuizQuestions(String quizId) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseConstants.questionsCollection)
          .where(FirebaseConstants.questionQuizIdField, isEqualTo: quizId)
          .get();

      final questions = querySnapshot.docs
          .map((doc) => QuestionModel.fromJson(doc.data()))
          .toList();

      // Sort in-memory by order field
      questions.sort((a, b) => a.order.compareTo(b.order));

      return questions;
    } catch (e) {
      throw Exception('Failed to get quiz questions: $e');
    }
  }

  /// Get question by ID
  Future<QuestionModel?> getQuestion(String questionId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConstants.questionsCollection)
          .doc(questionId)
          .get();

      if (!doc.exists || doc.data() == null) return null;

      return QuestionModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get question: $e');
    }
  }

  /// Update question (admin only)
  Future<void> updateQuestion(QuestionModel question) async {
    try {
      await _firestore
          .collection(FirebaseConstants.questionsCollection)
          .doc(question.id)
          .update(question.toJson());
    } catch (e) {
      throw Exception('Failed to update question: $e');
    }
  }

  /// Delete question (admin only)
  Future<void> deleteQuestion(String questionId) async {
    try {
      await _firestore
          .collection(FirebaseConstants.questionsCollection)
          .doc(questionId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete question: $e');
    }
  }

  // ==================== QUIZ ATTEMPT OPERATIONS ====================

  /// Save quiz attempt
  Future<String> saveQuizAttempt(QuizAttemptModel attempt) async {
    try {
      final docRef = await _firestore
          .collection(FirebaseConstants.quizAttemptsCollection)
          .add(attempt.toJson());

      // Update the attempt with its generated ID
      await docRef.update({FirebaseConstants.attemptIdField: docRef.id});

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save quiz attempt: $e');
    }
  }

  /// Get user's quiz attempts
  Future<List<QuizAttemptModel>> getUserQuizAttempts(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseConstants.quizAttemptsCollection)
          .where(FirebaseConstants.attemptUserIdField, isEqualTo: userId)
          .get();

      final attempts = querySnapshot.docs
          .map((doc) => QuizAttemptModel.fromJson(doc.data()))
          .toList();

      // Sort in-memory by completedAt (most recent first)
      attempts.sort((a, b) => b.completedAt.compareTo(a.completedAt));

      return attempts;
    } catch (e) {
      throw Exception('Failed to get user quiz attempts: $e');
    }
  }

  /// Get all attempts for a specific quiz
  Future<List<QuizAttemptModel>> getQuizAttempts(String quizId) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseConstants.quizAttemptsCollection)
          .where(FirebaseConstants.attemptQuizIdField, isEqualTo: quizId)
          .get();

      final attempts = querySnapshot.docs
          .map((doc) => QuizAttemptModel.fromJson(doc.data()))
          .toList();

      // Sort in-memory by completedAt (most recent first)
      attempts.sort((a, b) => b.completedAt.compareTo(a.completedAt));

      return attempts;
    } catch (e) {
      throw Exception('Failed to get quiz attempts: $e');
    }
  }

  /// Get user's best attempt for a quiz
  Future<QuizAttemptModel?> getUserBestAttempt({
    required String userId,
    required String quizId,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseConstants.quizAttemptsCollection)
          .where(FirebaseConstants.attemptUserIdField, isEqualTo: userId)
          .where(FirebaseConstants.attemptQuizIdField, isEqualTo: quizId)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      final attempts = querySnapshot.docs
          .map((doc) => QuizAttemptModel.fromJson(doc.data()))
          .toList();

      // Sort in-memory by percentage (highest first) and return the best
      attempts.sort((a, b) => b.percentage.compareTo(a.percentage));

      return attempts.first;
    } catch (e) {
      throw Exception('Failed to get user best attempt: $e');
    }
  }

  /// Get quiz attempt by ID
  Future<QuizAttemptModel?> getQuizAttempt(String attemptId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConstants.quizAttemptsCollection)
          .doc(attemptId)
          .get();

      if (!doc.exists) return null;

      return QuizAttemptModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get quiz attempt: $e');
    }
  }

  /// Check if user has attempted a quiz
  /// Returns the MOST RECENT attempt for proper retake tracking
  Future<QuizAttemptModel?> getUserQuizAttempt({
    required String userId,
    required String quizId,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseConstants.quizAttemptsCollection)
          .where(FirebaseConstants.attemptUserIdField, isEqualTo: userId)
          .where(FirebaseConstants.attemptQuizIdField, isEqualTo: quizId)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      // Get all attempts and sort by completedAt to get the most recent
      final attempts = querySnapshot.docs
          .map((doc) => QuizAttemptModel.fromJson(doc.data()))
          .toList();

      // Sort by completedAt (most recent first)
      attempts.sort((a, b) => b.completedAt.compareTo(a.completedAt));

      return attempts.first; // Return most recent attempt
    } catch (e) {
      throw Exception('Failed to check user quiz attempt: $e');
    }
  }

  /// Get count of user's attempts for a specific quiz
  Future<int> getUserQuizAttemptCount({
    required String userId,
    required String quizId,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseConstants.quizAttemptsCollection)
          .where(FirebaseConstants.attemptUserIdField, isEqualTo: userId)
          .where(FirebaseConstants.attemptQuizIdField, isEqualTo: quizId)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get user quiz attempt count: $e');
    }
  }

  /// Get all quiz submissions with user details (admin only)
  Future<List<Map<String, dynamic>>> getAllQuizSubmissions(
    String quizId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseConstants.quizAttemptsCollection)
          .where(FirebaseConstants.attemptQuizIdField, isEqualTo: quizId)
          .get();

      final submissions = <Map<String, dynamic>>[];

      for (var doc in querySnapshot.docs) {
        final attempt = QuizAttemptModel.fromJson(doc.data());

        // Get user details
        final userDoc = await _firestore
            .collection(FirebaseConstants.usersCollection)
            .doc(attempt.userId)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;
          submissions.add({
            'attempt': attempt,
            'userName': userData['username'] ?? 'Unknown',
            'userEmail': userData['email'] ?? '',
            'fullName': userData['fullName'] ?? '',
          });
        }
      }

      // Sort by completedAt (most recent first)
      submissions.sort(
        (a, b) => (b['attempt'] as QuizAttemptModel).completedAt.compareTo(
          (a['attempt'] as QuizAttemptModel).completedAt,
        ),
      );

      return submissions;
    } catch (e) {
      throw Exception('Failed to get quiz submissions: $e');
    }
  }

  /// Update retake permission for a specific attempt (admin only)
  Future<void> updateRetakePermission(String attemptId, bool canRetake) async {
    try {
      await _firestore
          .collection(FirebaseConstants.quizAttemptsCollection)
          .doc(attemptId)
          .update({'canRetake': canRetake});
    } catch (e) {
      throw Exception('Failed to update retake permission: $e');
    }
  }

  /// Request retake for a specific attempt (user)
  Future<void> requestRetake(String attemptId) async {
    try {
      await _firestore
          .collection(FirebaseConstants.quizAttemptsCollection)
          .doc(attemptId)
          .update({
            'retakeRequested': true,
            'retakeRequestedAt': Timestamp.now(),
          });
    } catch (e) {
      throw Exception('Failed to request retake: $e');
    }
  }

  /// Cancel retake request for a specific attempt (user or admin)
  Future<void> cancelRetakeRequest(String attemptId) async {
    try {
      await _firestore
          .collection(FirebaseConstants.quizAttemptsCollection)
          .doc(attemptId)
          .update({
            'retakeRequested': false,
            'retakeRequestedAt': FieldValue.delete(),
          });
    } catch (e) {
      throw Exception('Failed to cancel retake request: $e');
    }
  }

  /// Get all quizzes (including inactive) for admin
  Future<List<QuizModel>> getAllQuizzesForAdmin() async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseConstants.quizzesCollection)
          .get();

      // Sort in memory instead of using Firestore orderBy
      final quizzes = querySnapshot.docs
          .map((doc) => QuizModel.fromJson(doc.data()))
          .toList();

      // Sort by createdAt in descending order
      quizzes.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return quizzes;
    } catch (e) {
      throw Exception('Failed to get quizzes: $e');
    }
  }

  // ==================== USER ANSWER OPERATIONS ====================

  /// Save user answer
  Future<String> saveUserAnswer(UserAnswerModel answer) async {
    try {
      final docRef = await _firestore
          .collection(FirebaseConstants.userAnswersCollection)
          .add(answer.toJson());

      // Update the answer with its generated ID
      await docRef.update({FirebaseConstants.answerIdField: docRef.id});

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save user answer: $e');
    }
  }

  /// Save multiple user answers in a batch
  Future<void> saveUserAnswers(List<UserAnswerModel> answers) async {
    try {
      final batch = _firestore.batch();

      for (var answer in answers) {
        final docRef = _firestore
            .collection(FirebaseConstants.userAnswersCollection)
            .doc();
        batch.set(docRef, answer.toJson());
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to save user answers: $e');
    }
  }

  /// Get user answers for a quiz attempt
  Future<List<UserAnswerModel>> getUserAnswers(String attemptId) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseConstants.userAnswersCollection)
          .where(FirebaseConstants.answerAttemptIdField, isEqualTo: attemptId)
          .get();

      return querySnapshot.docs
          .map((doc) => UserAnswerModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user answers: $e');
    }
  }

  /// Get a specific quiz attempt by ID
  Future<QuizAttemptModel?> getQuizAttemptById(String attemptId) async {
    try {
      final docSnapshot = await _firestore
          .collection(FirebaseConstants.quizAttemptsCollection)
          .doc(attemptId)
          .get();

      if (!docSnapshot.exists) return null;

      return QuizAttemptModel.fromJson(docSnapshot.data()!);
    } catch (e) {
      throw Exception('Failed to get quiz attempt: $e');
    }
  }

  // ==================== LEADERBOARD OPERATIONS ====================

  /// Get top users by total points
  Future<List<UserModel>> getLeaderboard({int limit = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .get();

      final users = querySnapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();

      // Sort in-memory by totalPoints (highest first)
      users.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

      // Return only the top 'limit' users
      return users.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to get leaderboard: $e');
    }
  }

  /// Get user's rank
  Future<int> getUserRank(String userId) async {
    try {
      final userDoc = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .get();

      if (!userDoc.exists) return 0;

      final userData = userDoc.data()!;
      final userPoints =
          userData[FirebaseConstants.userTotalPointsField] as int? ?? 0;

      // Count users with more points
      final querySnapshot = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .where(
            FirebaseConstants.userTotalPointsField,
            isGreaterThan: userPoints,
          )
          .get();

      return querySnapshot.docs.length + 1; // +1 because rank starts at 1
    } catch (e) {
      throw Exception('Failed to get user rank: $e');
    }
  }

  /// Get leaderboard for a specific quiz
  Future<List<Map<String, dynamic>>> getQuizLeaderboard({
    required String quizId,
    int limit = 10,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseConstants.quizAttemptsCollection)
          .where(FirebaseConstants.attemptQuizIdField, isEqualTo: quizId)
          .get();

      final attempts = querySnapshot.docs
          .map((doc) => QuizAttemptModel.fromJson(doc.data()))
          .toList();

      // Sort in-memory by percentage (highest first)
      attempts.sort((a, b) => b.percentage.compareTo(a.percentage));

      // Take only top 'limit' attempts
      final topAttempts = attempts.take(limit);

      final List<Map<String, dynamic>> leaderboard = [];

      for (var attempt in topAttempts) {
        final user = await getUser(attempt.userId);

        if (user != null) {
          leaderboard.add({'user': user, 'attempt': attempt});
        }
      }

      return leaderboard;
    } catch (e) {
      throw Exception('Failed to get quiz leaderboard: $e');
    }
  }

  // ==================== UTILITY OPERATIONS ====================

  /// Stream of real-time quiz updates
  Stream<List<QuizModel>> watchQuizzes() {
    return _firestore
        .collection(FirebaseConstants.quizzesCollection)
        .where(FirebaseConstants.quizIsActiveField, isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final quizzes = snapshot.docs
              .map((doc) => QuizModel.fromJson(doc.data()))
              .toList();

          // Sort in-memory by createdAt (most recent first)
          quizzes.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return quizzes;
        });
  }

  /// Stream of real-time user data updates
  Stream<UserModel?> watchUser(String userId) {
    return _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(userId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) return null;
          return UserModel.fromJson(snapshot.data()!);
        });
  }

  /// Stream of real-time leaderboard updates
  Stream<List<UserModel>> watchLeaderboard({int limit = 10}) {
    return _firestore
        .collection(FirebaseConstants.usersCollection)
        .snapshots()
        .map((snapshot) {
          final users = snapshot.docs
              .map((doc) => UserModel.fromJson(doc.data()))
              .toList();

          // Sort in-memory by totalPoints (highest first)
          users.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

          // Return only top 'limit' users
          return users.take(limit).toList();
        });
  }
}
