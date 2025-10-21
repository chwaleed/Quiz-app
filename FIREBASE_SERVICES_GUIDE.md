# 🔥 Firebase Services - Quick Reference Guide

## 📚 Service Overview

This guide provides quick examples for using the three Firebase services in your Flutter Quiz App.

---

## 🔐 Authentication Service

### Import:

```dart
import 'package:testproject/services/auth_service.dart';
import 'package:testproject/models/user_model.dart';
```

### Initialize:

```dart
final authService = AuthService();
```

### Common Operations:

#### 1. Sign Up New User

```dart
try {
  final user = await authService.signUp(
    email: 'user@example.com',
    password: 'SecurePassword123',
    username: 'johndoe',
    fullName: 'John Doe',
  );

  if (user != null) {
    print('User created: ${user.username}');
    // Navigate to home screen
  }
} catch (e) {
  print('Sign up error: $e');
  // Show error message to user
}
```

#### 2. Sign In Existing User

```dart
try {
  final user = await authService.signIn(
    email: 'user@example.com',
    password: 'SecurePassword123',
  );

  if (user != null) {
    print('Welcome back, ${user.fullName}!');
    // Navigate to home screen
  }
} catch (e) {
  print('Sign in error: $e');
  // Show error message to user
}
```

#### 3. Get Current User

```dart
try {
  final user = await authService.getCurrentUserData();

  if (user != null) {
    print('Current user: ${user.username}');
    print('Role: ${user.role}');
    print('Is admin: ${user.isAdmin}');
  } else {
    print('No user logged in');
  }
} catch (e) {
  print('Error: $e');
}
```

#### 4. Sign Out

```dart
try {
  await authService.signOut();
  print('User signed out successfully');
  // Navigate to login screen
} catch (e) {
  print('Sign out error: $e');
}
```

#### 5. Reset Password

```dart
try {
  await authService.resetPassword(email: 'user@example.com');
  print('Password reset email sent!');
  // Show success message
} catch (e) {
  print('Error: $e');
}
```

#### 6. Update Profile

```dart
try {
  await authService.updateProfile(
    fullName: 'John Smith',
    username: 'johnsmith',
    profilePictureUrl: 'https://example.com/pic.jpg',
  );
  print('Profile updated successfully');
} catch (e) {
  print('Update error: $e');
}
```

#### 7. Update Email (with verification)

```dart
try {
  await authService.updateEmail(newEmail: 'newemail@example.com');
  print('Verification email sent to new address');
  // Inform user to check their email

  // After user verifies, update Firestore:
  await authService.updateEmailInFirestore(newEmail: 'newemail@example.com');
} catch (e) {
  print('Error: $e');
}
```

#### 8. Update Password

```dart
try {
  await authService.updatePassword(newPassword: 'NewSecurePassword456');
  print('Password updated successfully');
} catch (e) {
  print('Error: $e');
}
```

#### 9. Listen to Auth State Changes

```dart
authService.authStateChanges.listen((user) {
  if (user != null) {
    print('User is signed in: ${user.uid}');
  } else {
    print('User is signed out');
  }
});
```

---

## 💾 Database Service

### Import:

```dart
import 'package:testproject/services/database_service.dart';
import 'package:testproject/models/quiz_model.dart';
import 'package:testproject/models/question_model.dart';
import 'package:testproject/models/quiz_attempt_model.dart';
```

### Initialize:

```dart
final dbService = DatabaseService();
```

### User Operations:

#### 1. Get User by ID

```dart
try {
  final user = await dbService.getUser('userId123');

  if (user != null) {
    print('User: ${user.fullName}');
    print('Points: ${user.totalPoints}');
    print('Pass Rate: ${user.passRate}%');
  }
} catch (e) {
  print('Error: $e');
}
```

#### 2. Update User Statistics

```dart
try {
  await dbService.updateUserStats(
    userId: 'userId123',
    pointsEarned: 85,
    percentage: 85.0,
    isPassed: true,
  );
  print('User stats updated!');
} catch (e) {
  print('Error: $e');
}
```

### Quiz Operations:

#### 3. Create Quiz (Admin Only)

```dart
try {
  final quiz = QuizModel(
    id: '', // Auto-generated
    title: 'Flutter Basics Quiz',
    description: 'Test your Flutter knowledge',
    category: 'Programming',
    difficulty: 'Easy',
    timeLimit: 600, // 10 minutes in seconds
    passingScore: 60,
    totalQuestions: 10,
    totalPoints: 100,
    createdBy: 'adminUserId',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final quizId = await dbService.createQuiz(quiz);
  print('Quiz created with ID: $quizId');
} catch (e) {
  print('Error: $e');
}
```

#### 4. Get All Quizzes

```dart
try {
  final quizzes = await dbService.getAllQuizzes();

  print('Found ${quizzes.length} quizzes');
  for (var quiz in quizzes) {
    print('${quiz.title} - ${quiz.difficulty}');
  }
} catch (e) {
  print('Error: $e');
}
```

#### 5. Search Quizzes

```dart
try {
  final results = await dbService.searchQuizzes('Flutter');

  print('Found ${results.length} matching quizzes');
} catch (e) {
  print('Error: $e');
}
```

#### 6. Get Quizzes by Category

```dart
try {
  final quizzes = await dbService.getQuizzesByCategory('Programming');

  print('Programming quizzes: ${quizzes.length}');
} catch (e) {
  print('Error: $e');
}
```

### Question Operations:

#### 7. Add Question to Quiz

```dart
try {
  final question = QuestionModel(
    id: '', // Auto-generated
    quizId: 'quizId123',
    questionText: 'What is Flutter?',
    options: [
      'A UI framework',
      'A programming language',
      'A database',
      'An IDE',
    ],
    correctAnswerIndex: 0,
    points: 10,
    order: 1,
  );

  final questionId = await dbService.addQuestion(question);
  print('Question added with ID: $questionId');
} catch (e) {
  print('Error: $e');
}
```

#### 8. Get Quiz Questions

```dart
try {
  final questions = await dbService.getQuizQuestions('quizId123');

  print('Quiz has ${questions.length} questions');
  for (var q in questions) {
    print('Q${q.order}: ${q.questionText}');
  }
} catch (e) {
  print('Error: $e');
}
```

### Quiz Attempt Operations:

#### 9. Save Quiz Attempt

```dart
try {
  final attempt = QuizAttemptModel(
    id: '', // Auto-generated
    userId: 'userId123',
    quizId: 'quizId123',
    score: 85,
    percentage: 85.0,
    correctAnswers: 17,
    totalQuestions: 20,
    timeTaken: 480, // 8 minutes in seconds
    isPassed: true,
    completedAt: DateTime.now(),
  );

  final attemptId = await dbService.saveQuizAttempt(attempt);
  print('Attempt saved with ID: $attemptId');

  // Update quiz attempt count
  await dbService.incrementQuizAttemptCount('quizId123');
} catch (e) {
  print('Error: $e');
}
```

#### 10. Get User's Quiz Attempts

```dart
try {
  final attempts = await dbService.getUserQuizAttempts('userId123');

  print('User has ${attempts.length} attempts');
  for (var attempt in attempts) {
    print('Score: ${attempt.percentage}% - ${attempt.gradeLetter}');
  }
} catch (e) {
  print('Error: $e');
}
```

#### 11. Get User's Best Attempt

```dart
try {
  final bestAttempt = await dbService.getUserBestAttempt(
    userId: 'userId123',
    quizId: 'quizId123',
  );

  if (bestAttempt != null) {
    print('Best score: ${bestAttempt.percentage}%');
    print('Grade: ${bestAttempt.gradeLetter}');
  }
} catch (e) {
  print('Error: $e');
}
```

### Leaderboard Operations:

#### 12. Get Global Leaderboard

```dart
try {
  final topUsers = await dbService.getLeaderboard(limit: 10);

  print('Top 10 Users:');
  for (var i = 0; i < topUsers.length; i++) {
    print('${i + 1}. ${topUsers[i].username} - ${topUsers[i].totalPoints} pts');
  }
} catch (e) {
  print('Error: $e');
}
```

#### 13. Get User's Rank

```dart
try {
  final rank = await dbService.getUserRank('userId123');

  print('Your rank: #$rank');
} catch (e) {
  print('Error: $e');
}
```

#### 14. Get Quiz-Specific Leaderboard

```dart
try {
  final leaderboard = await dbService.getQuizLeaderboard(
    quizId: 'quizId123',
    limit: 10,
  );

  print('Top performers in this quiz:');
  for (var i = 0; i < leaderboard.length; i++) {
    final entry = leaderboard[i];
    final user = entry['user'] as UserModel;
    final attempt = entry['attempt'] as QuizAttemptModel;

    print('${i + 1}. ${user.username} - ${attempt.percentage}%');
  }
} catch (e) {
  print('Error: $e');
}
```

### Real-Time Streams:

#### 15. Watch Quiz Updates

```dart
dbService.watchQuizzes().listen((quizzes) {
  print('Quizzes updated: ${quizzes.length} quizzes available');
  // Update UI with new quiz list
});
```

#### 16. Watch User Data

```dart
dbService.watchUser('userId123').listen((user) {
  if (user != null) {
    print('User data updated: ${user.totalPoints} points');
    // Update UI with new user data
  }
});
```

#### 17. Watch Leaderboard

```dart
dbService.watchLeaderboard(limit: 10).listen((topUsers) {
  print('Leaderboard updated: ${topUsers.length} users');
  // Update UI with new rankings
});
```

---

## 📁 Storage Service

### Import:

```dart
import 'dart:io';
import 'package:testproject/services/storage_service.dart';
import 'package:image_picker/image_picker.dart';
```

### Initialize:

```dart
final storageService = StorageService();
```

### Common Operations:

#### 1. Upload Profile Picture

```dart
try {
  // Pick image from gallery
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);

  if (image != null) {
    final File imageFile = File(image.path);

    // Upload to Firebase Storage
    final downloadUrl = await storageService.uploadProfilePicture(
      userId: 'userId123',
      imageFile: imageFile,
    );

    print('Profile picture uploaded!');
    print('URL: $downloadUrl');

    // Update user profile with the URL
    // await authService.updateProfile(profilePictureUrl: downloadUrl);
  }
} catch (e) {
  print('Upload error: $e');
}
```

#### 2. Upload Question Image

```dart
try {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);

  if (image != null) {
    final File imageFile = File(image.path);

    final downloadUrl = await storageService.uploadQuestionImage(
      quizId: 'quizId123',
      questionId: 'questionId456',
      imageFile: imageFile,
    );

    print('Question image uploaded!');
    print('URL: $downloadUrl');
  }
} catch (e) {
  print('Upload error: $e');
}
```

#### 3. Delete Profile Picture

```dart
try {
  final imageUrl = 'https://firebasestorage.googleapis.com/...';

  await storageService.deleteProfilePicture(imageUrl);
  print('Profile picture deleted');
} catch (e) {
  print('Delete error: $e');
}
```

#### 4. Delete Quiz Images

```dart
try {
  await storageService.deleteQuizImages('quizId123');
  print('All quiz images deleted');
} catch (e) {
  print('Delete error: $e');
}
```

#### 5. Check if File Exists

```dart
try {
  final exists = await storageService.fileExists('profile_pictures/user123.jpg');

  if (exists) {
    print('File exists');
  } else {
    print('File not found');
  }
} catch (e) {
  print('Error: $e');
}
```

#### 6. Get File Size

```dart
try {
  final imageUrl = 'https://firebasestorage.googleapis.com/...';
  final size = await storageService.getFileSize(imageUrl);

  final sizeMB = size / (1024 * 1024);
  print('File size: ${sizeMB.toStringAsFixed(2)} MB');
} catch (e) {
  print('Error: $e');
}
```

---

## 🔄 Complete Example: Take a Quiz

Here's a complete example showing how services work together:

```dart
import 'package:testproject/services/auth_service.dart';
import 'package:testproject/services/database_service.dart';
import 'package:testproject/models/quiz_attempt_model.dart';
import 'package:testproject/models/user_answer_model.dart';

Future<void> takeQuiz(String quizId) async {
  final authService = AuthService();
  final dbService = DatabaseService();

  try {
    // 1. Get current user
    final user = await authService.getCurrentUserData();
    if (user == null) {
      print('Please log in first');
      return;
    }

    // 2. Get quiz details
    final quiz = await dbService.getQuiz(quizId);
    if (quiz == null) {
      print('Quiz not found');
      return;
    }

    // 3. Get quiz questions
    final questions = await dbService.getQuizQuestions(quizId);
    print('Quiz: ${quiz.title}');
    print('Questions: ${questions.length}');

    // 4. User answers questions (simulation)
    int correctAnswers = 0;
    int score = 0;
    List<UserAnswerModel> userAnswers = [];

    for (var question in questions) {
      // Simulate user selecting an answer (replace with actual UI logic)
      final selectedAnswer = 0; // User's selected answer index
      final isCorrect = selectedAnswer == question.correctAnswerIndex;

      if (isCorrect) {
        correctAnswers++;
        score += question.points;
      }

      // Create user answer
      final answer = UserAnswerModel(
        id: '',
        attemptId: '', // Will be updated after saving attempt
        questionId: question.id,
        selectedAnswer: selectedAnswer,
        isCorrect: isCorrect,
        pointsEarned: isCorrect ? question.points : 0,
      );

      userAnswers.add(answer);
    }

    // 5. Calculate results
    final percentage = (correctAnswers / questions.length) * 100;
    final isPassed = percentage >= quiz.passingScore;

    // 6. Save quiz attempt
    final attempt = QuizAttemptModel(
      id: '',
      userId: user.uid,
      quizId: quizId,
      score: score,
      percentage: percentage,
      correctAnswers: correctAnswers,
      totalQuestions: questions.length,
      timeTaken: 300, // 5 minutes
      isPassed: isPassed,
      completedAt: DateTime.now(),
    );

    final attemptId = await dbService.saveQuizAttempt(attempt);
    print('Quiz attempt saved!');

    // 7. Save user answers
    for (var answer in userAnswers) {
      final updatedAnswer = answer.copyWith(attemptId: attemptId);
      await dbService.saveUserAnswer(updatedAnswer);
    }

    // 8. Update user statistics
    await dbService.updateUserStats(
      userId: user.uid,
      pointsEarned: score,
      percentage: percentage,
      isPassed: isPassed,
    );

    // 9. Increment quiz attempt count
    await dbService.incrementQuizAttemptCount(quizId);

    // 10. Show results
    print('\n--- Results ---');
    print('Score: $score/${quiz.totalPoints}');
    print('Percentage: ${percentage.toStringAsFixed(1)}%');
    print('Grade: ${attempt.gradeLetter}');
    print('Status: ${isPassed ? "PASSED ✅" : "FAILED ❌"}');
    print('Performance: ${attempt.performanceRating}');

  } catch (e) {
    print('Error taking quiz: $e');
  }
}

// Usage
void main() async {
  await takeQuiz('quiz123');
}
```

---

## 🎯 Best Practices

### 1. Error Handling

Always wrap service calls in try-catch blocks:

```dart
try {
  final result = await service.method();
  // Handle success
} catch (e) {
  // Handle error
  print('Error: $e');
  // Show user-friendly message
}
```

### 2. Loading States

Show loading indicators while waiting for operations:

```dart
setState(() => isLoading = true);
try {
  await service.method();
} finally {
  setState(() => isLoading = false);
}
```

### 3. Real-Time Updates

Use streams for real-time data:

```dart
StreamBuilder<List<QuizModel>>(
  stream: dbService.watchQuizzes(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final quizzes = snapshot.data!;
      return ListView.builder(...);
    }
    return CircularProgressIndicator();
  },
)
```

### 4. Cleanup

Cancel stream subscriptions when done:

```dart
StreamSubscription? _subscription;

void initState() {
  _subscription = dbService.watchQuizzes().listen((quizzes) {
    // Handle updates
  });
}

void dispose() {
  _subscription?.cancel();
  super.dispose();
}
```

---

## 📝 Notes

- All IDs are auto-generated by Firestore (empty string when creating)
- Timestamps are handled automatically
- Security rules enforce permissions
- Batch operations are more efficient for multiple writes
- Real-time streams update automatically

---

**Ready to use these services in Session 4 with Providers!** 🚀
