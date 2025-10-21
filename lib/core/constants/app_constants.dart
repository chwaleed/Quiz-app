/// Application-wide constants
class AppConstants {
  // App Info
  static const String appName = 'Quiz Master';
  static const String appVersion = '1.0.0';
  
  // User Roles
  static const String roleUser = 'user';
  static const String roleAdmin = 'admin';
  
  // Quiz Difficulty
  static const String difficultyEasy = 'Easy';
  static const String difficultyMedium = 'Medium';
  static const String difficultyHard = 'Hard';
  
  static const List<String> difficultyLevels = [
    difficultyEasy,
    difficultyMedium,
    difficultyHard,
  ];
  
  // Quiz Categories (can be expanded)
  static const List<String> defaultCategories = [
    'General Knowledge',
    'Science',
    'Mathematics',
    'History',
    'Geography',
    'Technology',
    'Sports',
    'Entertainment',
    'Literature',
    'Arts',
  ];
  
  // Quiz Settings
  static const int minimumQuestionsPerQuiz = 5;
  static const int optionsPerQuestion = 4;
  static const int defaultPointsPerQuestion = 10;
  static const int defaultPassingScore = 60; // percentage
  
  // Leaderboard
  static const int leaderboardTopCount = 100;
  
  // Time Periods for Leaderboard
  static const String periodAllTime = 'All Time';
  static const String periodThisWeek = 'This Week';
  static const String periodThisMonth = 'This Month';
  
  // Password Requirements
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 50;
  
  // Username Requirements
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 20;
  
  // Validation Patterns
  static final RegExp emailPattern = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  
  static final RegExp usernamePattern = RegExp(
    r'^[a-zA-Z0-9_]+$',
  );
  
  // Error Messages
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork = 'Network error. Please check your connection.';
  static const String errorInvalidEmail = 'Please enter a valid email address.';
  static const String errorInvalidPassword = 'Password must be at least 8 characters.';
  static const String errorInvalidUsername = 'Username must be 3-20 characters (letters, numbers, underscore only).';
  static const String errorPasswordMismatch = 'Passwords do not match.';
  static const String errorRequiredField = 'This field is required.';
  static const String errorEmailInUse = 'Email is already in use.';
  static const String errorWeakPassword = 'Password is too weak.';
  static const String errorUserNotFound = 'User not found.';
  static const String errorWrongPassword = 'Incorrect password.';
  static const String errorUnauthorized = 'You do not have permission to perform this action.';
  
  // Success Messages
  static const String successSignup = 'Account created successfully!';
  static const String successLogin = 'Logged in successfully!';
  static const String successLogout = 'Logged out successfully!';
  static const String successPasswordReset = 'Password reset email sent!';
  static const String successQuizCreated = 'Quiz created successfully!';
  static const String successQuizUpdated = 'Quiz updated successfully!';
  static const String successQuizDeleted = 'Quiz deleted successfully!';
  static const String successProfileUpdated = 'Profile updated successfully!';
  
  // Confirmation Messages
  static const String confirmLogout = 'Are you sure you want to logout?';
  static const String confirmDeleteQuiz = 'Are you sure you want to delete this quiz?';
  static const String confirmExitQuiz = 'Are you sure you want to exit? Your progress will be lost.';
  static const String confirmSubmitQuiz = 'Are you sure you want to submit?';
  static const String confirmDeleteAccount = 'Are you sure you want to delete your account? This action cannot be undone.';
  
  // Button Labels
  static const String buttonLogin = 'Login';
  static const String buttonSignup = 'Sign Up';
  static const String buttonLogout = 'Logout';
  static const String buttonSubmit = 'Submit';
  static const String buttonCancel = 'Cancel';
  static const String buttonSave = 'Save';
  static const String buttonDelete = 'Delete';
  static const String buttonEdit = 'Edit';
  static const String buttonRetry = 'Retry';
  static const String buttonStartQuiz = 'Start Quiz';
  static const String buttonRetakeQuiz = 'Retake Quiz';
  static const String buttonBackToHome = 'Back to Home';
  static const String buttonNext = 'Next';
  static const String buttonPrevious = 'Previous';
  static const String buttonFinish = 'Finish';
  
  // Padding & Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  // Border Radius
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;
  
  // Icon Sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;
  
  // Animation Durations
  static const Duration animationShort = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationLong = Duration(milliseconds: 500);
}
