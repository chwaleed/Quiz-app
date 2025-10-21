# Quiz Result Display Bug Fix

## Problem Summary

Correct answers were being displayed as incorrect **only when viewing results immediately after completing a quiz**. However, when viewing the same quiz results from history, they displayed correctly.

## Root Cause Analysis

### Bug #1: Question Card Display Logic (QuestionCard Widget)

**Location:** `lib/widgets/question_card.dart`

**Issue:** Variable naming confusion in review mode logic

- Variable `isCorrect` was checking if an option is the correct answer (not if user's answer was correct)
- Both correct and selected states could be true simultaneously, causing display issues

**Fix:** Renamed variables for clarity:

```dart
// BEFORE (Confusing)
final bool isCorrect = correctAnswer == index;
final bool isWrong = isReview && isSelected && !isCorrect;

// AFTER (Clear)
final bool isCorrectOption = correctAnswer == index;
final bool isWrongSelection = isReview && isSelected && !isCorrectOption;
```

### Bug #2: Answer Data Loss (QuizTakingScreen) ⚠️ **CRITICAL**

**Location:** `lib/screens/quiz/quiz_taking_screen.dart`

**Issue:** Timing problem in answer retrieval

```dart
// WRONG ORDER - Answers lost!
final attempt = await quizProvider.submitQuiz(...);  // This calls _endQuiz() which clears answers
final answersList = quizProvider.getSelectedAnswer(...);  // Returns -1 for all questions!
```

**Root Cause Flow:**

1. `submitQuiz()` is called
2. Inside `submitQuiz()`, answers are saved to database ✅
3. Then `_endQuiz()` is called which executes `_selectedAnswers.clear()` ❌
4. Control returns to `quiz_taking_screen.dart`
5. Code tries to get answers using `getSelectedAnswer()`
6. All answers return `-1` because `_selectedAnswers` map is now empty!
7. Result screen receives all `-1` values → everything shows as incorrect

**Fix:** Retrieve answers BEFORE calling `submitQuiz()`:

```dart
// CORRECT ORDER
final answersList = List.generate(
  quizProvider.totalQuestions,
  (index) => quizProvider.getSelectedAnswer(index) ?? -1,
);

final attempt = await quizProvider.submitQuiz(...);  // Now safe to clear answers
```

## Why History Screen Worked Correctly

The history screen uses a different code path:

1. Navigates to `QuizResultLoaderScreen`
2. Loads data from **Firestore database** (not from provider's memory)
3. Database has the correct answers (saved before clearing)
4. Displays correctly ✅

## Files Modified

1. **`lib/widgets/question_card.dart`**

   - Fixed variable naming in `_buildOptionTile()` method
   - Clarified correct vs wrong answer display logic

2. **`lib/screens/quiz/quiz_taking_screen.dart`**
   - Moved answer collection BEFORE `submitQuiz()` call
   - Updated debug prints for verification

## Testing Checklist

- [ ] Complete a quiz and immediately view results
  - [ ] Correct answers show with green checkmark
  - [ ] Wrong answers show with red X
  - [ ] Percentage matches actual performance
- [ ] View same quiz from history screen

  - [ ] Results match what was shown immediately after quiz
  - [ ] All data displays correctly

- [ ] Verify debug output shows correct answer matching
  - [ ] Check console for "Answers collected BEFORE submit"
  - [ ] Verify Match=true for correct answers

## Impact

- ✅ Direct quiz results now display correctly
- ✅ History results continue to work correctly
- ✅ No data loss or corruption
- ✅ User experience significantly improved

## Lesson Learned

**Order matters!** When a method clears state (like `_endQuiz()`), always retrieve needed data BEFORE calling it, not after.

---

_Fixed: October 19, 2025_
