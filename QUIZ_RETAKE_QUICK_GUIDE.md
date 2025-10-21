# Quick Start Guide: Quiz Retake & Submissions Management

## Important: Token-Based Retake System

**How Retakes Work:**

- Each quiz can only be attempted **once** by default
- When admin grants a retake, it gives the user **ONE token** (one additional attempt)
- After using the retake token, the quiz becomes disabled again
- User must request admin for each additional attempt
- Admin can grant unlimited retakes, but **one at a time**

**Example Flow:**

1. User attempts quiz → Quiz disabled
2. Admin grants retake → User gets 1 token
3. User attempts quiz again → Token consumed, quiz disabled again
4. User requests 3rd attempt → Admin grants retake → User gets 1 token
5. User attempts quiz again → Token consumed, quiz disabled again
6. This process continues for each additional attempt

## For Admin Users

### Managing Quiz Visibility

#### View All Quizzes (Published & Drafts)

1. Navigate to Admin Dashboard
2. You'll see statistics showing:
   - Total Quizzes
   - Published (green badge)
   - Drafts (orange badge)
3. All quizzes are visible in the list

#### Publish/Unpublish a Quiz

1. Go to Admin Dashboard
2. Click "Edit" on any quiz
3. Toggle the "Active" or "Published" switch
4. Save changes
5. Draft quizzes are only visible to admins

### Managing Quiz Submissions

#### View All Submissions for a Quiz

1. Go to Admin Dashboard
2. Find the quiz you want to manage
3. Click the "Submissions" button
4. You'll see all user attempts with:
   - User name and email
   - Score and grade
   - Pass/Fail status
   - Time taken
   - Submission date
   - Retake permission status

#### Enable Retake for a User

**Important:** This grants **ONE retake token** only!

1. Navigate to the quiz's Submissions screen
2. Find the user's submission
3. Toggle the switch next to "User can retake this quiz"
4. The switch will turn green when enabled
5. User can now attempt the quiz **one more time**
6. After the user submits, the retake token is **automatically consumed**
7. Quiz becomes disabled again for that user
8. If user needs another attempt, repeat this process

**Note:** The retake permission is automatically reset to false after each quiz submission. This ensures controlled, one-time retakes.

#### Disable Retake Permission

1. Navigate to the quiz's Submissions screen
2. Find the user's submission
3. Toggle off the retake switch
4. User will no longer be able to retake the quiz

### Quick Actions

**From Admin Dashboard:**

- **Submissions** - View all user attempts
- **Edit** - Modify quiz details and questions
- **Delete** - Remove quiz permanently

**From Submissions Screen:**

- **Toggle Retake** - Grant/revoke retake permission
- **Pull to Refresh** - Update submission list

## For Regular Users

### Taking Quizzes

#### First Time Attempt

1. Browse available quizzes on Home screen
2. Only published (active) quizzes are visible
3. Click on a quiz to view details
4. Click "Start Quiz" to begin
5. Complete all questions and submit

#### After Attempting

- Quiz card shows "ATTEMPTED" badge (orange)
- Quiz card becomes slightly faded
- Best score is displayed on the card
- Cannot start the quiz again

#### Requesting Retake

1. If you need to retake a quiz:
   - The quiz will show "Already Attempted" message
   - Contact your administrator
   - Provide quiz name and reason
2. After admin enables retake:
   - "Already Attempted" message disappears
   - "Start Quiz" button becomes active
   - You can attempt the quiz again

### Quiz Card Indicators

**ATTEMPTED Badge** (Orange):

- Appears on top-right of quiz card
- Indicates you've already taken this quiz
- Card is slightly faded and disabled

**Best Score** (Star icon):

- Shows your highest score percentage
- Green (80%+), Orange (60-79%), Red (<60%)

**Pass/Fail Status**:

- Shown in quiz history
- Based on the quiz's passing score threshold

## Common Scenarios

### Scenario 1: User Attempts Quiz by Mistake

**Problem**: User accidentally started wrong quiz
**Solution**:

1. User completes the quiz (required)
2. User contacts admin
3. Admin goes to Submissions screen
4. Admin enables retake for that user
5. User can attempt again

### Scenario 2: User Wants to Improve Score

**Problem**: User passed but wants higher score
**Solution**:

1. User requests retake from admin
2. Admin reviews request
3. Admin enables retake (grants 1 token)
4. User attempts quiz again
5. System keeps best score visible
6. Retake token is consumed automatically
7. User must request again for additional attempts

### Scenario 3: Admin Creates Draft Quiz

**Problem**: Need to prepare quiz without publishing
**Solution**:

1. Admin creates quiz
2. Set "Active" to false (Draft mode)
3. Quiz is only visible to admin
4. Test and review quiz
5. Set "Active" to true to publish
6. Users can now see and attempt

### Scenario 4: Quiz Needs Maintenance

**Problem**: Quiz has errors and needs fixing
**Solution**:

1. Admin sets quiz to Draft (inactive)
2. Users can no longer attempt it
3. Admin edits questions/answers
4. Admin tests changes
5. Admin publishes (activates) again

## Tips & Best Practices

### For Admins:

- ✅ Review submissions regularly
- ✅ Be consistent with retake policies
- ✅ **Remember: Each retake grant is ONE token only**
- ✅ **Token is consumed automatically after user submits**
- ✅ Use drafts for quiz preparation
- ✅ Check statistics before major changes
- ✅ Keep track of who requested retakes and how many times
- ❌ Don't delete quizzes with submissions (data loss)
- ❌ Don't enable retake without reason (data integrity)
- ❌ **Don't expect retake to persist after submission**

### For Users:

- ✅ Read quiz instructions carefully
- ✅ Check time limit before starting
- ✅ Review answers before submitting
- ✅ Contact admin promptly for retake needs
- ❌ Don't attempt without preparation
- ❌ Don't request retake without valid reason

## Keyboard Shortcuts & Gestures

- **Pull to Refresh** - Update quiz list or submissions
- **Swipe Back** - Return to previous screen
- **Tap Quiz Card** - View quiz details
- **Long Press** (Future) - Quick actions menu

## Troubleshooting

### "Already Attempted" showing incorrectly

**Solution**:

1. Check if retake was granted
2. Restart the app
3. Contact admin if issue persists

### Submissions not loading

**Solution**:

1. Pull to refresh
2. Check internet connection
3. Verify admin permissions

### Can't see draft quizzes (Admin)

**Solution**:

1. Verify you're logged in as admin
2. Check role in Firebase Console
3. Contact system administrator

### Quiz card not showing attempted badge

**Solution**:

1. Pull to refresh quiz list
2. Restart app
3. Verify submission was successful

## Support & Contact

If you encounter issues:

1. Check this guide first
2. Try troubleshooting steps
3. Contact your system administrator
4. Provide screenshots if possible
5. Include quiz name and user details

## Updates & Changes

This feature was implemented on: [Current Date]

**Version**: 1.0.0

**What's New**:

- Admin can view both published and draft quizzes
- One-time quiz attempt restriction
- Admin quiz submissions management
- Retake permission system
- Visual indicators for attempted quizzes

**Coming Soon**:

- Bulk retake operations
- User notifications for retake approval
- Analytics and reporting
- Export submissions feature
