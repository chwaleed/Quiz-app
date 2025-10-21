import '../core/constants/firebase_constants.dart';

class UserAnswerModel {
  final String id;
  final String attemptId;
  final String questionId;
  final int selectedAnswer; // index of selected option (0-3)
  final bool isCorrect;
  final int pointsEarned;

  const UserAnswerModel({
    required this.id,
    required this.attemptId,
    required this.questionId,
    required this.selectedAnswer,
    required this.isCorrect,
    required this.pointsEarned,
  });

  // Factory constructor to create UserAnswerModel from Firestore document
  factory UserAnswerModel.fromJson(Map<String, dynamic> json) {
    return UserAnswerModel(
      id: json[FirebaseConstants.answerIdField] as String? ?? '',
      attemptId: json[FirebaseConstants.answerAttemptIdField] as String? ?? '',
      questionId:
          json[FirebaseConstants.answerQuestionIdField] as String? ?? '',
      selectedAnswer:
          json[FirebaseConstants.answerSelectedAnswerField] as int? ?? -1,
      isCorrect: json[FirebaseConstants.answerIsCorrectField] as bool? ?? false,
      pointsEarned:
          json[FirebaseConstants.answerPointsEarnedField] as int? ?? 0,
    );
  }

  // Convert UserAnswerModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      FirebaseConstants.answerIdField: id,
      FirebaseConstants.answerAttemptIdField: attemptId,
      FirebaseConstants.answerQuestionIdField: questionId,
      FirebaseConstants.answerSelectedAnswerField: selectedAnswer,
      FirebaseConstants.answerIsCorrectField: isCorrect,
      FirebaseConstants.answerPointsEarnedField: pointsEarned,
    };
  }

  // Create a copy of UserAnswerModel with updated fields
  UserAnswerModel copyWith({
    String? id,
    String? attemptId,
    String? questionId,
    int? selectedAnswer,
    bool? isCorrect,
    int? pointsEarned,
  }) {
    return UserAnswerModel(
      id: id ?? this.id,
      attemptId: attemptId ?? this.attemptId,
      questionId: questionId ?? this.questionId,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
      isCorrect: isCorrect ?? this.isCorrect,
      pointsEarned: pointsEarned ?? this.pointsEarned,
    );
  }

  // Check if answer was selected
  bool get wasAnswered => selectedAnswer >= 0;

  @override
  String toString() {
    return 'UserAnswerModel(id: $id, attemptId: $attemptId, questionId: $questionId, selectedAnswer: $selectedAnswer, isCorrect: $isCorrect)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserAnswerModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
