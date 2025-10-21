import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firebase_constants.dart';

class QuizModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String difficulty; // 'Easy', 'Medium', 'Hard'
  final int timeLimit; // in seconds (0 means no time limit)
  final int passingScore; // percentage (0-100)
  final int totalQuestions;
  final int totalPoints;
  final String createdBy; // userId of admin who created it
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final int attemptCount; // number of times attempted by users

  const QuizModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.timeLimit,
    required this.passingScore,
    required this.totalQuestions,
    required this.totalPoints,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.attemptCount = 0,
  });

  // Factory constructor to create QuizModel from Firestore document
  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json[FirebaseConstants.quizIdField] as String,
      title: json[FirebaseConstants.quizTitleField] as String,
      description: json[FirebaseConstants.quizDescriptionField] as String,
      category: json[FirebaseConstants.quizCategoryField] as String,
      difficulty: json[FirebaseConstants.quizDifficultyField] as String,
      timeLimit: json[FirebaseConstants.quizTimeLimitField] as int? ?? 0,
      passingScore: json[FirebaseConstants.quizPassingScoreField] as int? ?? 60,
      totalQuestions:
          json[FirebaseConstants.quizTotalQuestionsField] as int? ?? 0,
      totalPoints: json[FirebaseConstants.quizTotalPointsField] as int? ?? 0,
      createdBy: json[FirebaseConstants.quizCreatedByField] as String? ?? '',
      createdAt:
          (json[FirebaseConstants.quizCreatedAtField] as Timestamp?)
              ?.toDate() ??
          DateTime.now(),
      updatedAt:
          (json[FirebaseConstants.quizUpdatedAtField] as Timestamp?)
              ?.toDate() ??
          DateTime.now(),
      isActive: json[FirebaseConstants.quizIsActiveField] as bool? ?? true,
      attemptCount: json[FirebaseConstants.quizAttemptCountField] as int? ?? 0,
    );
  }

  // Convert QuizModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      FirebaseConstants.quizIdField: id,
      FirebaseConstants.quizTitleField: title,
      FirebaseConstants.quizDescriptionField: description,
      FirebaseConstants.quizCategoryField: category,
      FirebaseConstants.quizDifficultyField: difficulty,
      FirebaseConstants.quizTimeLimitField: timeLimit,
      FirebaseConstants.quizPassingScoreField: passingScore,
      FirebaseConstants.quizTotalQuestionsField: totalQuestions,
      FirebaseConstants.quizTotalPointsField: totalPoints,
      FirebaseConstants.quizCreatedByField: createdBy,
      FirebaseConstants.quizCreatedAtField: Timestamp.fromDate(createdAt),
      FirebaseConstants.quizUpdatedAtField: Timestamp.fromDate(updatedAt),
      FirebaseConstants.quizIsActiveField: isActive,
      FirebaseConstants.quizAttemptCountField: attemptCount,
    };
  }

  // Create a copy of QuizModel with updated fields
  QuizModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? difficulty,
    int? timeLimit,
    int? passingScore,
    int? totalQuestions,
    int? totalPoints,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    int? attemptCount,
  }) {
    return QuizModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      timeLimit: timeLimit ?? this.timeLimit,
      passingScore: passingScore ?? this.passingScore,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      totalPoints: totalPoints ?? this.totalPoints,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      attemptCount: attemptCount ?? this.attemptCount,
    );
  }

  // Check if quiz has time limit
  bool get hasTimeLimit => timeLimit > 0;

  // Get formatted time limit (e.g., "30 min")
  String get formattedTimeLimit {
    if (!hasTimeLimit) return 'No time limit';
    if (timeLimit < 60) return '$timeLimit sec';
    final minutes = timeLimit ~/ 60;
    return '$minutes min';
  }

  // Get points per question average
  double get pointsPerQuestion {
    if (totalQuestions == 0) return 0.0;
    return totalPoints / totalQuestions;
  }

  @override
  String toString() {
    return 'QuizModel(id: $id, title: $title, category: $category, difficulty: $difficulty, totalQuestions: $totalQuestions)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is QuizModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
