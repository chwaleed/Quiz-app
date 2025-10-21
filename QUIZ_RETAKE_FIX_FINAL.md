# Quiz Retake Fix - Preventing Infinite Attempts

## Problem

Users were able to attempt quizzes multiple times even after the admin allowed only ONE reattempt. The system was not properly enforcing the "one reattempt only" rule.

## Root Cause

1. **Database Query Issue**: The `getUserQuizAttempt` method was using `limit(1)` which could return any attempt (not necessarily the most recent)
2. **Missing Retake Token Consumption**: When a user took a retake, the previous attempt's `canRetake` flag wasn't being reset to `false`
3. **Incomplete Logic**: The system wasn't checking the most recent attempt to determine if a user could retake

## Solution

### 1. Fixed Database Service (`database_service.dart`)

#### Updated `getUserQuizAttempt` Method

```dart
Future<QuizAttemptModel?> getUserQuizAttempt({
  required String userId,
  required String quizId,
}) async {
  // Get ALL attempts and return the MOST RECENT one
  final querySnapshot = await _firestore
      .collection(FirebaseConstants.quizAttemptsCollection)
      .where(FirebaseConstants.attemptUserIdField, isEqualTo: userId)
      .where(FirebaseConstants.attemptQuizIdField, isEqualTo: quizId)
      .get();

  if (querySnapshot.docs.isEmpty) return null;

  // Sort by completedAt to get the most recent attempt
  final attempts = querySnapshot.docs
      .map((doc) => QuizAttemptModel.fromJson(doc.data()))
      .toList();

  attempts.sort((a, b) => b.completedAt.compareTo(a.completedAt));

  return attempts.first; // Return most recent
}
```

#### Added `getUserQuizAttemptCount` Method

```dart
Future<int> getUserQuizAttemptCount({
  required String userId,
  required String quizId,
}) async {
  final querySnapshot = await _firestore
      .collection(FirebaseConstants.quizAttemptsCollection)
      .where(FirebaseConstants.attemptUserIdField, isEqualTo: userId)
      .where(FirebaseConstants.attemptQuizIdField, isEqualTo: quizId)
      .get();

  return querySnapshot.docs.length;
}
```

### 2. Updated Quiz Provider (`quiz_provider.dart`)

#### Enhanced `hasUserAttemptedQuiz` Method

```dart
Future<bool> hasUserAttemptedQuiz(String userId, String quizId) async {
  // Get the most recent attempt
  final attempt = await _dbService.getUserQuizAttempt(
    userId: userId,
    quizId: quizId,
  );

  if (attempt == null) {
    // No attempt exists - user can take the quiz
    return false;
  }

  if (attempt.canRetake) {
    // User has permission to retake - allow access
    return false;
  }

  // User has attempted and doesn't have retake permission
  return true;
}
```

#### Fixed `submitQuiz` Method

```dart
Future<QuizAttemptModel?> submitQuiz(String userId) async {
  // ... (calculation logic) ...

  // IMPORTANT: Check for previous attempts
  final previousAttempt = await _dbService.getUserQuizAttempt(
    userId: userId,
    quizId: _currentQuiz!.id,
  );

  // If previous attempt has canRetake=true, disable it
  // This consumes the retake token
  if (previousAttempt != null && previousAttempt.canRetake) {
    await _dbService.updateRetakePermission(previousAttempt.id, false);
  }

  // Create new attempt with canRetake=false (always)
  final attempt = QuizAttemptModel(
    // ... other fields ...
    canRetake: false, // Always false for new attempts
  );

  // ... (save attempt and answers) ...
}
```

## How It Works Now

### Scenario 1: First Attempt

1. User takes quiz for the first time
2. Attempt is saved with `canRetake = false`
3. User cannot retake (blocked by UI)

### Scenario 2: Admin Allows Reattempt

1. Admin sets `canRetake = true` on user's first attempt
2. System checks most recent attempt → finds `canRetake = true`
3. User is allowed to take the quiz again

### Scenario 3: User Takes Reattempt

1. User starts quiz (allowed because most recent attempt has `canRetake = true`)
2. User completes and submits quiz
3. **System disables previous attempt**: Sets `canRetake = false` on the previous attempt
4. **New attempt created**: Saved with `canRetake = false`
5. User can no longer retake (most recent attempt has `canRetake = false`)

### Scenario 4: User Tries to Take Again (Blocked)

1. System checks most recent attempt → finds `canRetake = false`
2. `hasUserAttemptedQuiz` returns `true`
3. UI blocks the "Start Quiz" button
4. User cannot take the quiz again

## Key Changes Summary

| Component                 | Change                                                           | Purpose                                     |
| ------------------------- | ---------------------------------------------------------------- | ------------------------------------------- |
| `getUserQuizAttempt`      | Returns most recent attempt instead of arbitrary first           | Ensures correct retake permission check     |
| `getUserQuizAttemptCount` | New method to count total attempts                               | Future-proofing for attempt limit features  |
| `submitQuiz`              | Disables `canRetake` on previous attempt before creating new one | Consumes the retake token                   |
| `submitQuiz`              | Always creates new attempts with `canRetake = false`             | Ensures new attempts don't have auto-retake |
| `hasUserAttemptedQuiz`    | Checks most recent attempt's `canRetake` flag                    | Proper access control                       |

## Testing Steps

1. **Test First Attempt**:

   - User takes quiz → Attempt saved with `canRetake = false`
   - User should NOT be able to retake

2. **Test Admin Allow Reattempt**:

   - Admin toggles "Allow Reattempt" for user's first attempt
   - Verify `canRetake = true` in database
   - User should see "Start Quiz" button enabled

3. **Test Second Attempt (Retake)**:

   - User takes quiz again
   - Verify previous attempt has `canRetake = false`
   - Verify new attempt has `canRetake = false`
   - User should NOT be able to take quiz again

4. **Test Multiple Users**:
   - Ensure fix doesn't affect other users' attempts
   - Each user should have independent retake permissions

## Database Impact

- **No migration needed**: Existing attempts work with the new logic
- **Backward compatible**: Old attempts without explicit `canRetake` default to `false`
- **Performance**: Slightly more queries but necessary for correctness

## Files Modified

1. `lib/services/database_service.dart`

   - Updated `getUserQuizAttempt` method
   - Added `getUserQuizAttemptCount` method

2. `lib/providers/quiz_provider.dart`
   - Updated `hasUserAttemptedQuiz` method
   - Fixed `submitQuiz` method with retake token consumption

## Status

✅ **FIXED** - Users can now only attempt quiz once, plus one additional attempt if admin allows it.

## Date

October 19, 2025
