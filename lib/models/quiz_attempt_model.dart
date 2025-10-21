import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firebase_constants.dart';

class QuizAttemptModel {
  final String id;
  final String userId;
  final String quizId;
  final int score; // total points earned
  final double percentage; // 0-100
  final int correctAnswers;
  final int totalQuestions;
  final int timeTaken; // in seconds
  final bool isPassed;
  final DateTime completedAt;
  final bool canRetake; // admin can enable retake for this user
  final bool retakeRequested; // user has requested a retake

  const QuizAttemptModel({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.score,
    required this.percentage,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.timeTaken,
    required this.isPassed,
    required this.completedAt,
    this.canRetake = false,
    this.retakeRequested = false,
  });

  // Factory constructor to create QuizAttemptModel from Firestore document
  factory QuizAttemptModel.fromJson(Map<String, dynamic> json) {
    return QuizAttemptModel(
      id: json[FirebaseConstants.attemptIdField] as String,
      userId: json[FirebaseConstants.attemptUserIdField] as String,
      quizId: json[FirebaseConstants.attemptQuizIdField] as String,
      score: json[FirebaseConstants.attemptScoreField] as int? ?? 0,
      percentage:
          (json[FirebaseConstants.attemptPercentageField] as num?)
              ?.toDouble() ??
          0.0,
      correctAnswers:
          json[FirebaseConstants.attemptCorrectAnswersField] as int? ?? 0,
      totalQuestions:
          json[FirebaseConstants.attemptTotalQuestionsField] as int? ?? 0,
      timeTaken: json[FirebaseConstants.attemptTimeTakenField] as int? ?? 0,
      isPassed: json[FirebaseConstants.attemptIsPassedField] as bool? ?? false,
      completedAt:
          (json[FirebaseConstants.attemptCompletedAtField] as Timestamp?)
              ?.toDate() ??
          DateTime.now(),
      canRetake: json['canRetake'] as bool? ?? false,
      retakeRequested: json['retakeRequested'] as bool? ?? false,
    );
  }

  // Convert QuizAttemptModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      FirebaseConstants.attemptIdField: id,
      FirebaseConstants.attemptUserIdField: userId,
      FirebaseConstants.attemptQuizIdField: quizId,
      FirebaseConstants.attemptScoreField: score,
      FirebaseConstants.attemptPercentageField: percentage,
      FirebaseConstants.attemptCorrectAnswersField: correctAnswers,
      FirebaseConstants.attemptTotalQuestionsField: totalQuestions,
      FirebaseConstants.attemptTimeTakenField: timeTaken,
      FirebaseConstants.attemptIsPassedField: isPassed,
      FirebaseConstants.attemptCompletedAtField: Timestamp.fromDate(
        completedAt,
      ),
      'canRetake': canRetake,
      'retakeRequested': retakeRequested,
    };
  }

  // Create a copy of QuizAttemptModel with updated fields
  QuizAttemptModel copyWith({
    String? id,
    String? userId,
    String? quizId,
    int? score,
    double? percentage,
    int? correctAnswers,
    int? totalQuestions,
    int? timeTaken,
    bool? isPassed,
    DateTime? completedAt,
    bool? canRetake,
    bool? retakeRequested,
  }) {
    return QuizAttemptModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      quizId: quizId ?? this.quizId,
      score: score ?? this.score,
      percentage: percentage ?? this.percentage,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      timeTaken: timeTaken ?? this.timeTaken,
      isPassed: isPassed ?? this.isPassed,
      completedAt: completedAt ?? this.completedAt,
      canRetake: canRetake ?? this.canRetake,
      retakeRequested: retakeRequested ?? this.retakeRequested,
    );
  }

  // Get incorrect answers count
  int get incorrectAnswers => totalQuestions - correctAnswers;

  // Get accuracy percentage
  double get accuracy {
    if (totalQuestions == 0) return 0.0;
    return (correctAnswers / totalQuestions) * 100;
  }

  // Get formatted time taken (e.g., "5m 30s")
  String get formattedTimeTaken {
    final minutes = timeTaken ~/ 60;
    final seconds = timeTaken % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  // Get grade letter (A, B, C, D, F)
  String get gradeLetter {
    if (percentage >= 90) return 'A';
    if (percentage >= 80) return 'B';
    if (percentage >= 70) return 'C';
    if (percentage >= 60) return 'D';
    return 'F';
  }

  // Get performance rating
  String get performanceRating {
    if (percentage >= 90) return 'Excellent';
    if (percentage >= 80) return 'Very Good';
    if (percentage >= 70) return 'Good';
    if (percentage >= 60) return 'Fair';
    return 'Needs Improvement';
  }

  @override
  String toString() {
    return 'QuizAttemptModel(id: $id, userId: $userId, quizId: $quizId, score: $score, percentage: $percentage%, isPassed: $isPassed)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is QuizAttemptModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
