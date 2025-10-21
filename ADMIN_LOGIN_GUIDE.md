# Admin Login Guide 🔐

## How Admin Authentication Works

Your Quiz Master app has a **role-based authentication system** where users can be either:

- **`user`** (default) - Regular users who can take quizzes
- **`admin`** - Administrators who can create/edit/delete quizzes

## Current Situation ⚠️

When users sign up through the app, they are **automatically assigned the `user` role**. There is currently **no built-in UI** to create an admin account directly from the app.

## Methods to Create an Admin Account

### Method 1: Manual Firebase Console Update (Easiest) ✅

1. **Run your app and create a regular account**

   ```
   - Sign up with email/password through the app
   - Remember your credentials
   ```

2. **Go to Firebase Console**

   - Visit: https://console.firebase.google.com
   - Select your project: `quiz-app-bd447`

3. **Navigate to Firestore Database**

   - Click on "Firestore Database" in the left menu
   - Find the `users` collection

4. **Find your user document**

   - Locate the document with your email
   - Click on it to edit

5. **Change the role field**

   - Find the field: `role`
   - Change value from: `user`
   - Change value to: `admin`
   - Click "Update"

6. **Sign out and sign back in**
   - Log out of the app
   - Log back in with your credentials
   - You'll now have admin access! 🎉

### Method 2: Create Admin via Script (For Developers) 🛠️

Create a helper script to make a user admin:

**File: `lib/utils/make_admin.dart`**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// Helper function to make a user admin
/// Use this ONLY for initial admin setup
Future<void> makeUserAdmin(String email) async {
  final firestore = FirebaseFirestore.instance;

  try {
    // Find user by email
    final querySnapshot = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      print('❌ User not found with email: $email');
      return;
    }

    // Update role to admin
    final userId = querySnapshot.docs.first.id;
    await firestore.collection('users').doc(userId).update({
      'role': 'admin',
    });

    print('✅ User $email is now an admin!');
  } catch (e) {
    print('❌ Error making user admin: $e');
  }
}
```

Then call it from a temporary button or test:

```dart
// Temporary - Remove after creating admin
ElevatedButton(
  onPressed: () {
    makeUserAdmin('your-email@example.com');
  },
  child: Text('Make Me Admin'),
)
```

### Method 3: Direct Firestore Write (Advanced) 💻

If you have Firebase CLI installed:

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Use Firestore emulator or direct update
```

Then update directly via Firebase Admin SDK or Firestore REST API.

## How to Login as Admin

1. **Create an admin account** using one of the methods above

2. **Login normally** through the app with your admin credentials

3. **You'll see admin features:**
   - 📊 **Admin tab** in bottom navigation
   - 🎯 **Admin Dashboard** with statistics
   - ➕ **Create Quiz** button
   - ✏️ **Edit/Delete** options on quizzes
   - 👥 **User management** capabilities

## Verify Admin Access

After logging in, check for these indicators:

### Visual Indicators:

- ✅ Admin tab appears in bottom navigation
- ✅ Admin panel settings icon visible
- ✅ "Create Quiz" button available
- ✅ Edit/Delete options on quiz cards
- ✅ Profile shows "ADMIN" badge

### Code Check:

```dart
// In any screen with auth access
final authProvider = context.read<AuthProvider>();
print('Is Admin: ${authProvider.isAdmin}'); // Should print: Is Admin: true
```

## Admin Features Available

Once logged in as admin, you can:

### Quiz Management:

- ✅ **Create new quizzes** with questions
- ✅ **Edit existing quizzes** and questions
- ✅ **Delete quizzes**
- ✅ **View quiz statistics**
- ✅ **See attempt counts** and performance

### Dashboard:

- 📊 Total quizzes count
- 👥 Total users count
- 📈 Quiz attempts statistics
- 🏆 Top performing quizzes
- 📉 Recent activity

## Security Note 🔒

The current implementation stores the role in Firestore. For production apps, consider:

1. **Firebase Security Rules** to prevent role escalation:

```javascript
// firestore.rules
match /users/{userId} {
  allow read: if request.auth != null;
  allow write: if request.auth.uid == userId &&
               request.resource.data.role == resource.data.role; // Prevent role change
}
```

2. **Server-side validation** for admin operations
3. **Custom Claims** in Firebase Auth for better security
4. **Audit logging** for admin actions

## Troubleshooting

### Problem: Admin tab not showing after role change

**Solution:**

- Sign out completely
- Clear app cache (for web: clear browser cache)
- Sign back in

### Problem: Still seeing "user" role after update

**Solution:**

- Check Firebase Console to confirm role is "admin"
- Wait a few seconds for cache to clear
- Force refresh the app

### Problem: Can't access admin features

**Solution:**

- Verify role field in Firestore is exactly "admin" (lowercase)
- Check that `isAdmin` getter returns true
- Restart the app completely

## Quick Test Admin Account

For development/testing, create a test admin:

**Email:** `admin@test.com`
**Password:** `admin123456`
**Steps:**

1. Sign up with these credentials
2. Update role to "admin" in Firebase Console
3. Sign out and sign back in
4. Test admin features

## Need Help?

If you encounter issues:

1. Check Firebase Console for the user document
2. Verify the `role` field value
3. Check browser console for errors
4. Ensure Firebase rules allow the read operation

---

**Last Updated:** October 18, 2025  
**Project:** Quiz Master App  
**Firebase Project:** quiz-app-bd447
