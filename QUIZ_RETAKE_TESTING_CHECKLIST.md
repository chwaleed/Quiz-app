# Quiz Retake Fix - Testing Checklist

## Test Environment Setup

- [ ] Clean database state or use test quiz
- [ ] Have admin account ready
- [ ] Have student account ready
- [ ] Test quiz should be active and have questions

---

## Test Case 1: First Attempt (No Prior Attempts)

### Steps:

1. [ ] Login as student
2. [ ] Navigate to quiz details page
3. [ ] Verify "Start Quiz" button is visible and enabled
4. [ ] Click "Start Quiz"
5. [ ] Complete the quiz and submit

### Expected Results:

- [ ] Quiz submission succeeds
- [ ] New attempt created with `canRetake = false`
- [ ] After submission, navigate back to quiz details
- [ ] "Already Attempted" message should be displayed
- [ ] "Start Quiz" button should NOT be visible

---

## Test Case 2: Admin Allows Reattempt

### Steps:

1. [ ] Login as admin
2. [ ] Navigate to Quiz Submissions page for the test quiz
3. [ ] Find the student's first attempt
4. [ ] Toggle "Allow Reattempt" switch to ON (green)
5. [ ] Verify the switch shows enabled state
6. [ ] Logout and login as student
7. [ ] Navigate to quiz details page

### Expected Results:

- [ ] "Start Quiz" button should be visible again
- [ ] "Already Attempted" message should NOT be shown
- [ ] Student can click "Start Quiz"

---

## Test Case 3: Second Attempt (Retake)

### Steps:

1. [ ] Student (already has permission) navigates to quiz details
2. [ ] Verify "Start Quiz" button is visible
3. [ ] Click "Start Quiz" and complete the quiz
4. [ ] Submit the quiz

### Expected Results:

- [ ] Quiz submission succeeds
- [ ] New (second) attempt created with `canRetake = false`
- [ ] Previous (first) attempt's `canRetake` should be set to `false`
- [ ] After submission, "Already Attempted" message displays
- [ ] "Start Quiz" button should NOT be visible

---

## Test Case 4: Verify Cannot Take Third Attempt

### Steps:

1. [ ] Student navigates to quiz details page
2. [ ] Verify UI state

### Expected Results:

- [ ] "Already Attempted" message is displayed
- [ ] "Start Quiz" button is NOT visible
- [ ] Message suggests contacting admin for retake permission

---

## Test Case 5: Admin Tries to Allow Reattempt Again

### Steps:

1. [ ] Login as admin
2. [ ] Navigate to Quiz Submissions page
3. [ ] Find the student's submissions (should see 2 attempts now)
4. [ ] Check the most recent (second) attempt
5. [ ] Toggle "Allow Reattempt" switch to ON

### Expected Results:

- [ ] Admin can toggle the switch on the second attempt
- [ ] If toggled ON, student should be able to take quiz again
- [ ] This allows for exceptions (e.g., technical issues)

---

## Test Case 6: Multiple Students (Isolation Test)

### Steps:

1. [ ] Have Student A complete quiz (first attempt)
2. [ ] Have Student B complete quiz (first attempt)
3. [ ] Admin allows reattempt for Student A only
4. [ ] Student A can retake → verify ✓
5. [ ] Student B cannot retake → verify ✓
6. [ ] Student A completes retake
7. [ ] Student A cannot take again → verify ✓
8. [ ] Student B still cannot retake → verify ✓

### Expected Results:

- [ ] Each student's retake permission is independent
- [ ] Allowing retake for one student doesn't affect others
- [ ] Each student can only have 1 retake when allowed

---

## Database Verification

### Check After Each Test Case:

#### Query 1: Check User's Attempts

```
Collection: quiz_attempts
Filter: userId == <student_uid> AND quizId == <quiz_id>
Order by: completedAt DESC
```

**After Test Case 1:**

- [ ] 1 document exists
- [ ] `canRetake = false`

**After Test Case 2:**

- [ ] 1 document exists
- [ ] `canRetake = true` (after admin allows)

**After Test Case 3:**

- [ ] 2 documents exist
- [ ] Most recent: `canRetake = false`
- [ ] Previous: `canRetake = false` (was reset)

**After Test Case 4:**

- [ ] Still 2 documents
- [ ] Both have `canRetake = false`

---

## Edge Cases to Test

### Edge Case 1: Network Interruption During Submission

- [ ] Start quiz
- [ ] Disable network before submitting
- [ ] Try to submit
- [ ] Re-enable network
- [ ] Verify state is correct

### Edge Case 2: Concurrent Admin Actions

- [ ] Two admins try to toggle retake permission simultaneously
- [ ] Verify final state is consistent

### Edge Case 3: User Refreshes During Quiz

- [ ] Start quiz
- [ ] Refresh browser
- [ ] Verify quiz state is maintained or properly reset

---

## Code Review Checklist

- [x] `getUserQuizAttempt` returns most recent attempt
- [x] `getUserQuizAttemptCount` method added for future use
- [x] `hasUserAttemptedQuiz` checks most recent attempt's `canRetake`
- [x] `submitQuiz` disables previous attempt's `canRetake` before creating new
- [x] New attempts always created with `canRetake = false`
- [x] UI properly shows/hides "Start Quiz" based on `hasUserAttemptedQuiz`

---

## Performance Considerations

- [ ] Test with user who has 0 attempts (should be fast)
- [ ] Test with user who has 2 attempts (should still be fast)
- [ ] Test with 10+ attempts (edge case, should still work)

---

## Regression Testing

- [ ] First-time quiz takers can still take quiz normally
- [ ] Admin can still view all submissions
- [ ] Leaderboard still works correctly
- [ ] Quiz results screen displays correctly
- [ ] User profile stats update correctly after attempts

---

## Sign-off

- [ ] All test cases passed
- [ ] Edge cases handled
- [ ] No regressions found
- [ ] Documentation updated
- [ ] Code reviewed

**Tested by:** ********\_********  
**Date:** ********\_********  
**Version:** ********\_********

---

## Known Limitations

1. **Manual Admin Intervention**: Admins can manually allow unlimited retakes by toggling the switch multiple times. This is by design for flexibility.

2. **Historical Data**: Old attempts before this fix won't have explicit `canRetake` values (will default to `false`).

3. **Firestore Queries**: Getting all attempts to find most recent requires reading multiple documents. Consider adding index on `completedAt` if performance becomes an issue.

---

## Quick Debug Commands

### Check Firestore for User's Attempts:

```dart
// In Dart Debug Console
final attempts = await FirebaseFirestore.instance
  .collection('quiz_attempts')
  .where('userId', isEqualTo: '<USER_ID>')
  .where('quizId', isEqualTo: '<QUIZ_ID>')
  .get();

for (var doc in attempts.docs) {
  print('${doc.data()['completedAt']}: canRetake=${doc.data()['canRetake']}');
}
```

### Reset Test State:

```dart
// Delete all attempts for a user/quiz (admin only!)
final attempts = await FirebaseFirestore.instance
  .collection('quiz_attempts')
  .where('userId', isEqualTo: '<USER_ID>')
  .where('quizId', isEqualTo: '<QUIZ_ID>')
  .get();

for (var doc in attempts.docs) {
  await doc.reference.delete();
}
```
