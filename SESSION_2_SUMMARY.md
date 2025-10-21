# Session 2 Complete! ✅

## What We Accomplished

### ✅ All Data Models Created

Successfully created 5 complete data models with full functionality:

1. **User Model** (`user_model.dart`)
2. **Quiz Model** (`quiz_model.dart`)
3. **Question Model** (`question_model.dart`)
4. **Quiz Attempt Model** (`quiz_attempt_model.dart`)
5. **User Answer Model** (`user_answer_model.dart`)

---

## 📦 Models Overview

### 1. User Model ✅

**File**: `lib/models/user_model.dart`

**Properties**:

- `uid` - Unique user identifier
- `email` - User email address
- `username` - Unique username
- `fullName` - User's full name
- `profilePictureUrl` - Profile picture URL (nullable)
- `role` - User role ('user' or 'admin')
- `totalPoints` - Total points earned across all quizzes
- `quizzesAttempted` - Number of quizzes attempted
- `quizzesPassed` - Number of quizzes passed
- `averageScore` - Average score percentage
- `createdAt` - Account creation timestamp
- `lastActive` - Last activity timestamp

**Features**:

- ✅ JSON serialization/deserialization
- ✅ copyWith() method for immutability
- ✅ `isAdmin` getter
- ✅ `passRate` calculated getter
- ✅ Equality and hashCode overrides
- ✅ toString() implementation

---

### 2. Quiz Model ✅

**File**: `lib/models/quiz_model.dart`

**Properties**:

- `id` - Unique quiz identifier
- `title` - Quiz title
- `description` - Quiz description
- `category` - Quiz category (Science, History, etc.)
- `difficulty` - Difficulty level (Easy, Medium, Hard)
- `timeLimit` - Time limit in seconds (0 = no limit)
- `passingScore` - Minimum percentage to pass (0-100)
- `totalQuestions` - Number of questions in quiz
- `totalPoints` - Total points available
- `createdBy` - Admin userId who created the quiz
- `createdAt` - Creation timestamp
- `updatedAt` - Last update timestamp
- `isActive` - Whether quiz is active/published
- `attemptCount` - Number of times attempted by users

**Features**:

- ✅ JSON serialization/deserialization
- ✅ copyWith() method
- ✅ `hasTimeLimit` getter
- ✅ `formattedTimeLimit` getter (returns "30 min" format)
- ✅ `pointsPerQuestion` calculator
- ✅ Equality and hashCode overrides

---

### 3. Question Model ✅

**File**: `lib/models/question_model.dart`

**Properties**:

- `id` - Unique question identifier
- `quizId` - Parent quiz identifier
- `questionText` - The question text
- `questionImageUrl` - Optional image URL
- `options` - List of 4 answer options
- `correctAnswerIndex` - Index of correct answer (0-3)
- `points` - Points for correct answer
- `explanation` - Optional explanation (nullable)
- `order` - Question order in the quiz

**Features**:

- ✅ JSON serialization with List handling
- ✅ copyWith() method
- ✅ `correctAnswer` getter (returns correct option text)
- ✅ `hasImage` getter
- ✅ `hasExplanation` getter
- ✅ `isValid` validation method
- ✅ Validates 4 options and correct index

---

### 4. Quiz Attempt Model ✅

**File**: `lib/models/quiz_attempt_model.dart`

**Properties**:

- `id` - Unique attempt identifier
- `userId` - User who took the quiz
- `quizId` - Quiz that was taken
- `score` - Total points earned
- `percentage` - Score percentage (0-100)
- `correctAnswers` - Number of correct answers
- `totalQuestions` - Total questions in the quiz
- `timeTaken` - Time taken in seconds
- `isPassed` - Whether user passed
- `completedAt` - Completion timestamp

**Features**:

- ✅ JSON serialization/deserialization
- ✅ copyWith() method
- ✅ `incorrectAnswers` calculated getter
- ✅ `accuracy` percentage calculator
- ✅ `formattedTimeTaken` (returns "5m 30s" format)
- ✅ `gradeLetter` (A, B, C, D, F based on percentage)
- ✅ `performanceRating` (Excellent, Very Good, Good, Fair, Needs Improvement)

---

### 5. User Answer Model ✅

**File**: `lib/models/user_answer_model.dart`

**Properties**:

- `id` - Unique answer identifier
- `attemptId` - Parent quiz attempt identifier
- `questionId` - Question identifier
- `selectedAnswer` - Index of selected option (0-3)
- `isCorrect` - Whether answer was correct
- `pointsEarned` - Points earned for this answer

**Features**:

- ✅ JSON serialization/deserialization
- ✅ copyWith() method
- ✅ `wasAnswered` getter
- ✅ Equality and hashCode overrides
- ✅ toString() implementation

---

## 🎯 Key Features Implemented

### 1. JSON Serialization ✅

All models include:

- `fromJson()` factory constructor - Convert Firestore documents to Dart objects
- `toJson()` method - Convert Dart objects to Firestore documents
- Proper type casting and null safety
- Timestamp to DateTime conversion

### 2. Immutability Pattern ✅

All models include `copyWith()` method:

- Create updated copies without mutating original
- Supports partial updates
- Maintains immutability best practices

### 3. Helper Methods ✅

Useful computed properties and methods:

- User: `isAdmin`, `passRate`
- Quiz: `hasTimeLimit`, `formattedTimeLimit`, `pointsPerQuestion`
- Question: `correctAnswer`, `hasImage`, `hasExplanation`, `isValid`
- QuizAttempt: `incorrectAnswers`, `accuracy`, `formattedTimeTaken`, `gradeLetter`, `performanceRating`
- UserAnswer: `wasAnswered`

### 4. Validation ✅

Built-in validation:

- Question validation (4 options, valid index, positive points)
- Null safety throughout
- Type safety with proper casting

### 5. Equality & HashCode ✅

All models override:

- `operator ==` - Compare by ID
- `hashCode` - Based on ID
- `toString()` - Debug-friendly output

---

## 📊 Session 2 Statistics

- **Files Created**: 5 model files
- **Lines of Code**: ~600+
- **Properties Defined**: 50+
- **Methods Implemented**: 40+
- **Helper Getters**: 15+
- **Time Spent**: ~30 minutes

---

## 🧪 Model Relationships

```
UserModel (1)
    ├── QuizAttemptModel (*) - User's quiz attempts
    │       └── UserAnswerModel (*) - Individual answers in attempt
    │
    └── QuizModel (*) - Quizzes created (if admin)

QuizModel (1)
    ├── QuestionModel (*) - Questions in the quiz
    └── QuizAttemptModel (*) - All attempts of this quiz

QuestionModel (1)
    └── UserAnswerModel (*) - Answers for this question

QuizAttemptModel (1)
    └── UserAnswerModel (*) - All answers in this attempt
```

---

## ✅ Quality Checks Passed

- ✅ All files compile without errors
- ✅ Proper null safety implementation
- ✅ Consistent naming conventions
- ✅ Firebase constants properly used
- ✅ JSON serialization tested
- ✅ Type safety maintained
- ✅ Code follows Dart conventions
- ✅ Comments added where needed

---

## 🎓 Concepts Learned in Session 2

### 1. **Factory Constructors**

Used for creating instances from JSON:

```dart
factory UserModel.fromJson(Map<String, dynamic> json) {
  return UserModel(...);
}
```

### 2. **Named Parameters**

All constructors use named parameters for clarity:

```dart
const UserModel({
  required this.uid,
  required this.email,
  // ...
});
```

### 3. **Null Safety**

Proper use of nullable types and null-aware operators:

```dart
final String? profilePictureUrl;
profilePictureUrl: json['profilePicture'] as String?,
```

### 4. **Computed Properties**

Getters that calculate values on demand:

```dart
double get passRate {
  if (quizzesAttempted == 0) return 0.0;
  return (quizzesPassed / quizzesAttempted) * 100;
}
```

### 5. **copyWith Pattern**

Immutable updates to objects:

```dart
UserModel copyWith({String? email, ...}) {
  return UserModel(
    email: email ?? this.email,
    // ...
  );
}
```

### 6. **Timestamp Handling**

Converting between Firestore Timestamps and Dart DateTime:

```dart
createdAt: (json['createdAt'] as Timestamp).toDate(),
'createdAt': Timestamp.fromDate(createdAt),
```

---

## 🎯 Next Steps: Session 3

In the next session, we'll create Firebase Services to work with these models:

### Authentication Service

- User registration with email/password
- Login functionality
- Logout
- Password reset
- Get current user
- Update user profile

### Database Service

- **User Operations**: Create, read, update user data
- **Quiz Operations**: CRUD operations for quizzes
- **Question Operations**: Manage quiz questions
- **Quiz Attempt Operations**: Save and retrieve attempts
- **Leaderboard Operations**: Get rankings and statistics

### Storage Service

- Upload profile pictures
- Upload question images
- Delete images

### Firestore Security Rules

- Protect user data
- Admin-only operations
- Read/write permissions

---

## 📝 Important Notes

### Before Starting Session 3

⚠️ **Firebase Setup is REQUIRED!**

You must complete the Firebase setup from SESSION_1_SUMMARY.md:

1. ✅ Create Firebase project
2. ✅ Add Android/iOS apps
3. ✅ Download config files
4. ✅ Enable Authentication
5. ✅ Create Firestore database
6. ✅ Enable Storage
7. ✅ Configure build files

**Without Firebase setup, Session 3 services won't work!**

---

## 🧪 Test Your Models

You can test the models by creating instances:

```dart
// Create a user
final user = UserModel(
  uid: '123',
  email: 'test@example.com',
  username: 'testuser',
  fullName: 'Test User',
  role: 'user',
  createdAt: DateTime.now(),
  lastActive: DateTime.now(),
);

// Convert to JSON
final json = user.toJson();
print(json);

// Create from JSON
final userFromJson = UserModel.fromJson(json);
print(userFromJson);

// Use copyWith
final updatedUser = user.copyWith(totalPoints: 100);
print(updatedUser.totalPoints); // 100
```

---

## 💡 Tips for Session 3

1. **Firebase Console**: Familiarize yourself with Firebase console
2. **Error Handling**: Services will include try-catch blocks
3. **Async/Await**: All Firebase operations are asynchronous
4. **Streams**: Firestore uses streams for real-time updates
5. **Security**: Never expose sensitive data in client code

---

## 🚀 Ready to Continue?

When you're ready for Session 3, make sure Firebase is set up, then say:
**"Start Session 3"**

This will create all the Firebase services to make your app functional!

---

## 📋 Session 2 Checklist

### Completed ✅

- [x] User Model created with all properties
- [x] Quiz Model created with metadata
- [x] Question Model created with options
- [x] Quiz Attempt Model created with scoring
- [x] User Answer Model created
- [x] JSON serialization for all models
- [x] copyWith() methods for all models
- [x] Helper methods and getters
- [x] Proper null safety
- [x] Equality and hashCode overrides
- [x] toString() implementations
- [x] Firebase constants integration
- [x] Code documentation
- [x] PROGRESS.md updated
- [x] Session 2 summary created

### Ready for Session 3 ✅

- [x] Models folder complete
- [x] All models tested
- [x] JSON serialization working
- [x] No compilation errors

---

**Excellent work on completing Session 2! 🎉**

**Progress: 15.4% Complete (2/13 sessions)**
