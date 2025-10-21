# Quiz Retake Flow - Visual Guide

## 🎯 Problem Summary

**Before Fix:** Users could attempt quizzes infinite times after admin allowed one reattempt.  
**After Fix:** Users can attempt quiz once, then ONE additional time if admin allows it.

---

## 📊 Flow Diagram

### Before Fix (BROKEN) ❌

```
User Takes Quiz (1st attempt)
    ↓
Attempt saved: canRetake = false
    ↓
User blocked from retaking ✓
    ↓
Admin allows reattempt: canRetake = true
    ↓
User takes quiz (2nd attempt)
    ↓
[BUG] Attempt saved: canRetake = false BUT old attempt still has canRetake = true
    ↓
[BUG] System checks ANY attempt (gets old one)
    ↓
[BUG] User can retake INFINITELY! ❌
```

### After Fix (WORKING) ✅

```
User Takes Quiz (1st attempt)
    ↓
Attempt saved: canRetake = false
    ↓
User blocked from retaking ✓
    ↓
Admin allows reattempt: canRetake = true on 1st attempt
    ↓
User takes quiz (2nd attempt)
    ↓
[FIX] Before saving: Set old attempt canRetake = false
    ↓
[FIX] New attempt saved: canRetake = false
    ↓
[FIX] System checks MOST RECENT attempt
    ↓
User blocked from retaking ✓
```

---

## 🔄 Detailed State Transitions

### State 1: No Attempts

```
Database: []
UI: "Start Quiz" button visible ✅
User Action: Can take quiz
```

### State 2: After First Attempt

```
Database: [
  Attempt #1: {
    completedAt: 2025-10-19 10:00:00,
    canRetake: false
  }
]
UI: "Already Attempted" message shown
User Action: Cannot take quiz ❌
```

### State 3: Admin Allows Reattempt

```
Database: [
  Attempt #1: {
    completedAt: 2025-10-19 10:00:00,
    canRetake: true ← Changed by admin
  }
]
UI: "Start Quiz" button visible ✅
User Action: Can take quiz
```

### State 4: After Second Attempt (Retake)

```
Database: [
  Attempt #1: {
    completedAt: 2025-10-19 10:00:00,
    canRetake: false ← Reset to false
  },
  Attempt #2: {
    completedAt: 2025-10-19 14:30:00,
    canRetake: false ← New attempt
  }
]
UI: "Already Attempted" message shown
User Action: Cannot take quiz ❌
```

---

## 🔍 Key Function Behaviors

### `getUserQuizAttempt(userId, quizId)`

**Before Fix:**

```dart
// ❌ Used limit(1) - could return ANY attempt
.limit(1)
.get();

// Result: Might return old attempt with canRetake=true
```

**After Fix:**

```dart
// ✅ Gets ALL attempts and returns MOST RECENT
.get(); // Get all
attempts.sort((a, b) => b.completedAt.compareTo(a.completedAt));
return attempts.first; // Return newest

// Result: Always returns the latest attempt
```

### `hasUserAttemptedQuiz(userId, quizId)`

**Logic:**

```dart
Get most recent attempt
↓
No attempt? → return false (can take)
↓
Has canRetake=true? → return false (can take)
↓
Otherwise → return true (cannot take)
```

### `submitQuiz(userId)`

**Step-by-step:**

```
1. Calculate quiz results
   ↓
2. Get previous attempt (if exists)
   ↓
3. If previous has canRetake=true:
   → Set it to false (consume token)
   ↓
4. Create new attempt with canRetake=false
   ↓
5. Save to database
   ↓
6. Update user stats
```

---

## 🎭 User Experience Scenarios

### Scenario A: Normal User (No Retake)

```
Day 1 @ 10:00 AM
├─ User: Takes quiz
├─ System: Saves attempt (canRetake=false)
├─ UI: Shows "Already Attempted"
└─ Result: User blocked ✅

User cannot retake without admin permission
```

### Scenario B: User with Admin Permission

```
Day 1 @ 10:00 AM
├─ User: Takes quiz
├─ System: Saves attempt #1 (canRetake=false)
└─ UI: Shows "Already Attempted"

Day 1 @ 2:00 PM
├─ Admin: Allows reattempt
├─ System: Sets attempt #1 canRetake=true
└─ UI: Shows "Start Quiz" button

Day 2 @ 9:00 AM
├─ User: Takes quiz again
├─ System:
│  ├─ Sets attempt #1 canRetake=false
│  └─ Saves attempt #2 (canRetake=false)
└─ UI: Shows "Already Attempted"

User CANNOT take quiz again ✅
```

### Scenario C: Admin Allows Multiple Times (Edge Case)

```
Day 1: User takes quiz → Attempt #1
Day 2: Admin allows → Attempt #1 canRetake=true
Day 3: User retakes → Attempt #2 (both now canRetake=false)
Day 4: Admin allows AGAIN → Attempt #2 canRetake=true
Day 5: User takes 3rd time → Attempt #3 (all now canRetake=false)

Note: This is allowed by design for special cases
```

---

## 📋 Database Schema

### quiz_attempts Collection

```javascript
{
  id: "abc123",
  userId: "user_001",
  quizId: "quiz_math_001",
  score: 85,
  percentage: 85.0,
  correctAnswers: 17,
  totalQuestions: 20,
  timeTaken: 300, // seconds
  isPassed: true,
  completedAt: Timestamp(2025-10-19 10:00:00),
  canRetake: false, // ← Key field for retake logic
  retakeRequested: false
}
```

**Key Field:**

- `canRetake`: Boolean flag controlled by admin
  - `false` (default): User cannot retake
  - `true`: User can take quiz one more time

---

## 🔐 Security & Integrity

### Prevents:

✅ Infinite quiz attempts  
✅ Users bypassing attempt limits  
✅ Stale permission data

### Allows (by design):

✅ Admin flexibility for special cases  
✅ Multiple manual retake grants  
✅ Override for technical issues

---

## 🎨 UI States

### Quiz Detail Screen

#### State: Can Take Quiz

```
┌─────────────────────────────────┐
│  Quiz Title                     │
│  [Quiz information cards...]    │
│                                 │
│  ┌───────────────────────────┐ │
│  │  ▶ Start Quiz             │ │
│  └───────────────────────────┘ │
└─────────────────────────────────┘
```

#### State: Already Attempted

```
┌─────────────────────────────────┐
│  Quiz Title                     │
│  [Quiz information cards...]    │
│                                 │
│  ┌───────────────────────────┐ │
│  │  ✓ Already Attempted      │ │
│  └───────────────────────────┘ │
│                                 │
│  You have already attempted     │
│  this quiz. Contact admin for   │
│  retake permission.             │
└─────────────────────────────────┘
```

### Admin Submissions Screen

#### Retake Toggle

```
┌─────────────────────────────────────┐
│  Student: John Doe                  │
│  Score: 85%                         │
│  Completed: Oct 19, 2025 10:00 AM  │
│                                     │
│  Allow Reattempt: [○ OFF]          │ ← canRetake=false
│                   or                │
│  Allow Reattempt: [● ON ]          │ ← canRetake=true
└─────────────────────────────────────┘
```

---

## 🧪 Test Scenarios Summary

| Test | Initial State      | Action          | Expected Result            |
| ---- | ------------------ | --------------- | -------------------------- |
| 1    | No attempts        | Take quiz       | 1 attempt, canRetake=false |
| 2    | 1 attempt (false)  | Admin allows    | canRetake=true             |
| 3    | 1 attempt (true)   | Take quiz       | 2 attempts, both false     |
| 4    | 2 attempts (false) | Try to take     | Blocked ✅                 |
| 5    | 2 attempts (false) | Admin allows #2 | Can take again             |

---

## 💡 Key Insights

### Why Check Most Recent?

- Old attempts are historical records
- Only the latest attempt represents current permission state
- Prevents stale data from granting incorrect access

### Why Reset Old Attempt?

- Consumes the "retake token"
- Prevents accidental infinite loops
- Clear audit trail in database

### Why Default to False?

- Secure by default
- Explicit admin action required for retakes
- Prevents accidental permission grants

---

## 🚀 Performance Notes

### Database Reads:

- `hasUserAttemptedQuiz`: 1 read (gets all attempts, sorted in memory)
- `submitQuiz`: 1 read (check previous) + 1 write (disable old) + 1 write (new attempt)

### Optimization Tips:

- Consider adding Firestore index on `completedAt` for large datasets
- Cache attempt status in UI to reduce repeated checks
- Use real-time listeners if multiple admins manage permissions

---

## 📚 Related Files

1. **lib/services/database_service.dart**

   - `getUserQuizAttempt()` - Gets most recent attempt
   - `getUserQuizAttemptCount()` - Counts user's attempts
   - `updateRetakePermission()` - Toggles canRetake flag

2. **lib/providers/quiz_provider.dart**

   - `hasUserAttemptedQuiz()` - Checks if user can take quiz
   - `submitQuiz()` - Handles retake token consumption

3. **lib/screens/quiz/quiz_detail_screen.dart**

   - UI logic for showing/hiding "Start Quiz" button

4. **lib/screens/admin/quiz_submissions_screen.dart**
   - Admin interface for toggling retake permission

---

## ✅ Success Criteria

The fix is successful when:

1. ✅ User can take quiz initially
2. ✅ User blocked after first attempt
3. ✅ Admin can allow one reattempt
4. ✅ User can take quiz second time
5. ✅ User blocked after second attempt
6. ✅ No infinite attempts possible
7. ✅ Each user's permissions isolated
8. ✅ Historical attempts preserved

---

**Documentation Version:** 1.0  
**Date:** October 19, 2025  
**Status:** ✅ FIXED
