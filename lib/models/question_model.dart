import '../core/constants/firebase_constants.dart';

class QuestionModel {
  final String id;
  final String quizId;
  final String questionText;
  final String? questionImageUrl;
  final List<String> options; // 4 options
  final int correctAnswerIndex; // 0-3
  final int points;
  final String? explanation;
  final int order; // question order in the quiz

  const QuestionModel({
    required this.id,
    required this.quizId,
    required this.questionText,
    this.questionImageUrl,
    required this.options,
    required this.correctAnswerIndex,
    required this.points,
    this.explanation,
    required this.order,
  });

  // Factory constructor to create QuestionModel from Firestore document
  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json[FirebaseConstants.questionIdField] as String? ?? '',
      quizId: json[FirebaseConstants.questionQuizIdField] as String? ?? '',
      questionText: json[FirebaseConstants.questionTextField] as String? ?? '',
      questionImageUrl: json[FirebaseConstants.questionImageField] as String?,
      options: json[FirebaseConstants.questionOptionsField] != null
          ? List<String>.from(
              json[FirebaseConstants.questionOptionsField] as List,
            )
          : <String>[],
      correctAnswerIndex:
          json[FirebaseConstants.questionCorrectAnswerIndexField] as int? ?? 0,
      points: json[FirebaseConstants.questionPointsField] as int? ?? 1,
      explanation: json[FirebaseConstants.questionExplanationField] as String?,
      order: json[FirebaseConstants.questionOrderField] as int? ?? 0,
    );
  }

  // Convert QuestionModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      FirebaseConstants.questionIdField: id,
      FirebaseConstants.questionQuizIdField: quizId,
      FirebaseConstants.questionTextField: questionText,
      FirebaseConstants.questionImageField: questionImageUrl,
      FirebaseConstants.questionOptionsField: options,
      FirebaseConstants.questionCorrectAnswerIndexField: correctAnswerIndex,
      FirebaseConstants.questionPointsField: points,
      FirebaseConstants.questionExplanationField: explanation,
      FirebaseConstants.questionOrderField: order,
    };
  }

  // Create a copy of QuestionModel with updated fields
  QuestionModel copyWith({
    String? id,
    String? quizId,
    String? questionText,
    String? questionImageUrl,
    List<String>? options,
    int? correctAnswerIndex,
    int? points,
    String? explanation,
    int? order,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      quizId: quizId ?? this.quizId,
      questionText: questionText ?? this.questionText,
      questionImageUrl: questionImageUrl ?? this.questionImageUrl,
      options: options ?? this.options,
      correctAnswerIndex: correctAnswerIndex ?? this.correctAnswerIndex,
      points: points ?? this.points,
      explanation: explanation ?? this.explanation,
      order: order ?? this.order,
    );
  }

  // Get the correct answer text
  String get correctAnswer {
    if (correctAnswerIndex >= 0 && correctAnswerIndex < options.length) {
      return options[correctAnswerIndex];
    }
    return '';
  }

  // Check if question has an image
  bool get hasImage => questionImageUrl != null && questionImageUrl!.isNotEmpty;

  // Check if question has an explanation
  bool get hasExplanation => explanation != null && explanation!.isNotEmpty;

  // Validate question (returns true if valid)
  bool get isValid {
    return questionText.isNotEmpty &&
        options.length == 4 &&
        options.every((option) => option.isNotEmpty) &&
        correctAnswerIndex >= 0 &&
        correctAnswerIndex < 4 &&
        points > 0;
  }

  @override
  String toString() {
    return 'QuestionModel(id: $id, quizId: $quizId, questionText: $questionText, order: $order)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is QuestionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
