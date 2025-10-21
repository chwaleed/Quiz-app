/// Firebase collection and field names
class FirebaseConstants {
  // Collection Names
  static const String usersCollection = 'users';
  static const String quizzesCollection = 'quizzes';
  static const String questionsCollection = 'questions';
  static const String quizAttemptsCollection = 'quiz_attempts';
  static const String userAnswersCollection = 'user_answers';
  static const String categoriesCollection = 'categories';

  // User Fields
  static const String userIdField = 'uid';
  static const String userEmailField = 'email';
  static const String userUsernameField = 'username';
  static const String userFullNameField = 'fullName';
  static const String userProfilePictureField = 'profilePicture';
  static const String userRoleField = 'role';
  static const String userTotalPointsField = 'totalPoints';
  static const String userQuizzesCompletedField = 'quizzesCompleted';
  static const String userAverageScoreField = 'averageScore';
  static const String userCreatedAtField = 'createdAt';
  static const String userLastActiveField = 'lastActive';

  // Quiz Fields
  static const String quizIdField = 'id';
  static const String quizTitleField = 'title';
  static const String quizDescriptionField = 'description';
  static const String quizCategoryField = 'category';
  static const String quizDifficultyField = 'difficulty';
  static const String quizTimeLimitField = 'timeLimit';
  static const String quizPassingScoreField = 'passingScore';
  static const String quizTotalQuestionsField = 'totalQuestions';
  static const String quizTotalPointsField = 'totalPoints';
  static const String quizCreatedByField = 'createdBy';
  static const String quizCreatedAtField = 'createdAt';
  static const String quizUpdatedAtField = 'updatedAt';
  static const String quizIsActiveField = 'isActive';
  static const String quizAttemptCountField = 'attemptCount';

  // Question Fields
  static const String questionIdField = 'id';
  static const String questionQuizIdField = 'quizId';
  static const String questionTextField = 'questionText';
  static const String questionImageField = 'questionImage';
  static const String questionOptionsField = 'options';
  static const String questionCorrectAnswerIndexField = 'correctAnswerIndex';
  static const String questionPointsField = 'points';
  static const String questionExplanationField = 'explanation';
  static const String questionOrderField = 'order';

  // Quiz Attempt Fields
  static const String attemptIdField = 'id';
  static const String attemptUserIdField = 'userId';
  static const String attemptQuizIdField = 'quizId';
  static const String attemptScoreField = 'score';
  static const String attemptPercentageField = 'percentage';
  static const String attemptCorrectAnswersField = 'correctAnswers';
  static const String attemptTotalQuestionsField = 'totalQuestions';
  static const String attemptTimeTakenField = 'timeTaken';
  static const String attemptIsPassedField = 'isPassed';
  static const String attemptCompletedAtField = 'completedAt';

  // User Answer Fields
  static const String answerIdField = 'id';
  static const String answerAttemptIdField = 'attemptId';
  static const String answerQuestionIdField = 'questionId';
  static const String answerSelectedAnswerField = 'selectedAnswer';
  static const String answerIsCorrectField = 'isCorrect';
  static const String answerPointsEarnedField = 'pointsEarned';

  // Storage Paths
  static const String profilePicturesPath = 'profile_pictures';
  static const String questionImagesPath = 'question_images';
}
