# Quiz Retake and Submissions Feature - Implementation Summary

## Overview

This document summarizes the implementation of three major features:

1. **Admin Quiz Visibility**: Admins can see both published and draft quizzes
2. **One-Time Quiz Attempt**: Users can only attempt a quiz once unless admin enables retake
3. **Admin Quiz Submissions Management**: Admins can view all quiz submissions and grant retake permissions

## Changes Made

### 1. Model Updates

#### `QuizAttemptModel` (lib/models/quiz_attempt_model.dart)

- **Added Field**: `canRetake` (bool) - Indicates if admin has granted retake permission
- **Updated Methods**:
  - `fromJson()` - Now reads `canRetake` field from Firestore
  - `toJson()` - Now saves `canRetake` field to Firestore
  - `copyWith()` - Now supports updating `canRetake` field

### 2. Database Service Updates (lib/services/database_service.dart)

#### New Methods:

1. **`getUserQuizAttempt(userId, quizId)`**

   - Checks if a specific user has attempted a specific quiz
   - Returns the user's attempt if exists, null otherwise

2. **`getAllQuizSubmissions(quizId)`**

   - Gets all submissions for a quiz with user details
   - Returns list of maps containing attempt and user information
   - Used by admin to view all submissions

3. **`updateRetakePermission(attemptId, canRetake)`**

   - Updates the retake permission for a specific attempt
   - Only accessible by admin

4. **`getAllQuizzesForAdmin()`**
   - Returns ALL quizzes (both active and inactive)
   - Used for admin dashboard to show draft quizzes

### 3. Quiz Provider Updates (lib/providers/quiz_provider.dart)

#### Updated Methods:

1. **`loadQuizzes({forceRefresh, isAdmin})`**
   - Added `isAdmin` parameter
   - Loads all quizzes for admin, only active for regular users

#### New Methods:

1. **`hasUserAttemptedQuiz(userId, quizId)`**

   - Returns true if user has attempted without retake permission
   - Used to disable quiz for users who already attempted

2. **`getQuizSubmissions(quizId)`**

   - Gets all quiz submissions (admin only)
   - Returns submission data with user information

3. **`updateRetakePermission(attemptId, canRetake)`**
   - Updates retake permission (admin only)

### 4. UI Updates

#### Admin Dashboard (lib/screens/admin/admin_dashboard_screen.dart)

- **Updated**: Loads quizzes with `isAdmin: true` flag
- **Added**: "Submissions" button on each quiz card
- **Shows**: Both published and draft quizzes in the list
- **Statistics**: Shows counts for Total/Published/Draft quizzes

#### New Screen: Quiz Submissions (lib/screens/admin/quiz_submissions_screen.dart)

**Features:**

- Displays all user submissions for a specific quiz
- Shows user details (name, email, avatar)
- Shows attempt details (score, grade, time, date)
- **Retake Toggle**: Admin can enable/disable retake for each user
- Color-coded pass/fail badges
- Refresh functionality
- Empty state when no submissions

**Submission Card Shows:**

- User information (name, email)
- Score percentage and grade
- Points earned
- Correct/incorrect answers
- Time taken
- Submission date
- Pass/Fail status
- Retake permission toggle switch

#### Quiz Detail Screen (lib/screens/quiz/quiz_detail_screen.dart)

- **Updated**: Checks if user has attempted the quiz
- **Shows**: "Already Attempted" message if user cannot retake
- **Disables**: Start button if user has already attempted
- **Message**: Instructs user to contact admin for retake permission

#### Quiz Card Widget (lib/widgets/quiz_card.dart)

- **Added Field**: `hasAttempted` parameter
- **Visual Changes**:
  - Shows "ATTEMPTED" badge in orange on top-right corner
  - Reduces opacity to 0.6 for attempted quizzes
  - Disables tap interaction for attempted quizzes
  - Badge has shadow for better visibility

#### Home Screen (lib/screens/home/home_screen.dart)

- **Updated**: Uses FutureBuilder to check attempt status for each quiz
- **Shows**: Best score and attempted badge on quiz cards
- **Method Added**: `_getQuizAttemptStatus()` to fetch user's quiz status

### 5. Route Configuration (lib/config/routes.dart)

- **Added Route**: `/admin/quiz-submissions` for the submissions screen
- **Imports**: Added QuizSubmissionsScreen import

## User Flow

### For Regular Users:

1. **Viewing Quizzes**:

   - Users see only active/published quizzes
   - Quiz cards show "ATTEMPTED" badge if already taken
   - Shows best score if quiz was attempted

2. **Taking Quizzes**:

   - Can start quiz if not attempted
   - If already attempted (and no retake permission):
     - "Already Attempted" message displayed
     - Start button is disabled
     - Message suggests contacting admin

3. **After Submission**:
   - Quiz is marked as attempted
   - Cannot retake unless admin enables it

### For Admin Users:

1. **Dashboard View**:

   - Sees ALL quizzes (published + drafts)
   - Statistics show Total/Published/Draft counts
   - Each quiz card has "Submissions" button

2. **Managing Drafts**:

   - Draft quizzes shown with orange "Draft" badge
   - Can edit drafts before publishing
   - Can toggle `isActive` to publish/unpublish

3. **Viewing Submissions**:

   - Click "Submissions" on any quiz
   - See all user attempts with details
   - View user information and scores

4. **Managing Retakes**:
   - Toggle switch on each submission
   - Enable retake for specific users
   - User receives permission immediately
   - Can revoke retake permission anytime

## Database Schema

### Quiz Attempts Collection

```
quiz_attempts/
  {attemptId}/
    - id: string
    - userId: string
    - quizId: string
    - score: number
    - percentage: number
    - correctAnswers: number
    - totalQuestions: number
    - timeTaken: number (seconds)
    - isPassed: boolean
    - completedAt: timestamp
    - canRetake: boolean  // NEW FIELD
```

## Security Considerations

1. **Admin-Only Operations**:

   - `getAllQuizzesForAdmin()` should be protected
   - `updateRetakePermission()` should verify admin role
   - `getAllQuizSubmissions()` should be admin-only

2. **Firestore Rules** (Recommended):

```javascript
// Quiz Attempts
match /quiz_attempts/{attemptId} {
  allow read: if request.auth != null &&
    (request.auth.uid == resource.data.userId ||
     get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');

  allow write: if request.auth != null && request.auth.uid == resource.data.userId;

  allow update: if request.auth != null &&
    get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin' &&
    request.resource.data.diff(resource.data).affectedKeys().hasOnly(['canRetake']);
}

// Quizzes
match /quizzes/{quizId} {
  allow read: if request.auth != null &&
    (resource.data.isActive == true ||
     get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');

  allow write: if request.auth != null &&
    get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
}
```

## Testing Checklist

- [ ] Admin can see both published and draft quizzes
- [ ] Regular users see only published quizzes
- [ ] User can attempt quiz for the first time
- [ ] After attempting, quiz shows "ATTEMPTED" badge
- [ ] User cannot start quiz again without retake permission
- [ ] Admin can view all submissions for a quiz
- [ ] Admin can enable retake for a user
- [ ] After retake enabled, user can attempt quiz again
- [ ] Admin can disable retake permission
- [ ] Statistics on admin dashboard are correct
- [ ] Submission screen shows all user details correctly
- [ ] Pass/Fail badges display correctly
- [ ] Best score shows on quiz cards
- [ ] Quiz list properly refreshes after changes

## Future Enhancements

1. **Bulk Operations**: Allow admin to enable retake for multiple users at once
2. **Notifications**: Notify users when retake permission is granted
3. **Analytics**: Add charts/graphs to show quiz performance trends
4. **Export**: Allow admin to export submissions to CSV/Excel
5. **Comments**: Allow admin to add notes to submissions
6. **Attempt History**: Show all attempts for a user (if multiple retakes given)
7. **Time-Based Retakes**: Auto-enable retake after X days
8. **Quiz Scheduling**: Schedule when quizzes become active/inactive

## Dependencies Added

- `intl` package (for date formatting in submissions screen)

## Files Modified

1. `lib/models/quiz_attempt_model.dart`
2. `lib/services/database_service.dart`
3. `lib/providers/quiz_provider.dart`
4. `lib/screens/admin/admin_dashboard_screen.dart`
5. `lib/screens/quiz/quiz_detail_screen.dart`
6. `lib/widgets/quiz_card.dart`
7. `lib/screens/home/home_screen.dart`
8. `lib/config/routes.dart`

## Files Created

1. `lib/screens/admin/quiz_submissions_screen.dart`

## Summary

This implementation provides a complete quiz retake management system where:

- Admins have full control over quiz visibility (drafts/published)
- Users can attempt quizzes only once by default
- Admins can view all submissions with detailed information
- Admins can grant/revoke retake permissions per user
- UI clearly indicates attempted quizzes
- The system is secure and follows best practices

The feature is production-ready and can be deployed after proper testing and Firestore rules configuration.
