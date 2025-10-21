import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../core/constants/firebase_constants.dart';

/// Service class for handling all authentication related operations
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get current Firebase user
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign up a new user with email and password
  /// Creates both Firebase Auth account and Firestore user document
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String username,
    required String fullName,
  }) async {
    try {
      // Check if username is already taken
      final usernameQuery = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .where(FirebaseConstants.userUsernameField, isEqualTo: username)
          .limit(1)
          .get();

      if (usernameQuery.docs.isNotEmpty) {
        throw Exception('Username is already taken');
      }

      // Create Firebase Auth account
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user == null) {
        throw Exception('Failed to create user account');
      }

      // Create UserModel
      final newUser = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        username: username,
        fullName: fullName,
        role: 'user', // Default role
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
      );

      // Save user data to Firestore
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(newUser.uid)
          .set(newUser.toJson());

      return newUser;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  /// Sign in existing user with email and password
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in with Firebase Auth
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user == null) {
        throw Exception('Failed to sign in');
      }

      // Get user data from Firestore
      final userDoc = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists || userDoc.data() == null) {
        throw Exception('User data not found');
      }

      // Update last active timestamp
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userCredential.user!.uid)
          .update({FirebaseConstants.userLastActiveField: Timestamp.now()});

      return UserModel.fromJson(userDoc.data()!);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  /// Send password reset email
  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  /// Get current user data from Firestore
  Future<UserModel?> getCurrentUserData() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final userDoc = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (!userDoc.exists || userDoc.data() == null) return null;

      return UserModel.fromJson(userDoc.data()!);
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  /// Update user profile information
  Future<void> updateProfile({
    String? fullName,
    String? username,
    String? profilePictureUrl,
  }) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user logged in');

      final Map<String, dynamic> updates = {};

      if (fullName != null) {
        updates[FirebaseConstants.userFullNameField] = fullName;
      }

      if (username != null) {
        // Check if username is already taken by another user
        final usernameQuery = await _firestore
            .collection(FirebaseConstants.usersCollection)
            .where(FirebaseConstants.userUsernameField, isEqualTo: username)
            .limit(1)
            .get();

        if (usernameQuery.docs.isNotEmpty &&
            usernameQuery.docs.first.id != user.uid) {
          throw Exception('Username is already taken');
        }

        updates[FirebaseConstants.userUsernameField] = username;
      }

      if (profilePictureUrl != null) {
        updates[FirebaseConstants.userProfilePictureField] = profilePictureUrl;
      }

      if (updates.isEmpty) return;

      // Update Firestore document
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .update(updates);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Update user email in Firebase Auth and Firestore
  /// Note: User will receive a verification email at the new address
  Future<void> updateEmail({required String newEmail}) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user logged in');

      // Send verification email to new address (recommended by Firebase)
      await user.verifyBeforeUpdateEmail(newEmail);

      // Note: Firestore will be updated after email verification is complete
      // You may want to listen to auth state changes to update Firestore
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to send verification email: $e');
    }
  }

  /// Update email in Firestore after verification (call this after email is verified)
  Future<void> updateEmailInFirestore({required String newEmail}) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user logged in');

      // Update email in Firestore
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .update({FirebaseConstants.userEmailField: newEmail});
    } catch (e) {
      throw Exception('Failed to update email in Firestore: $e');
    }
  }

  /// Update user password
  Future<void> updatePassword({required String newPassword}) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user logged in');

      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user logged in');

      // Delete user data from Firestore
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .delete();

      // Delete Firebase Auth account
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  /// Re-authenticate user (required before sensitive operations)
  Future<void> reauthenticate({
    required String email,
    required String password,
  }) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user logged in');

      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to re-authenticate: $e');
    }
  }

  /// Handle Firebase Auth exceptions and return user-friendly messages
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'requires-recent-login':
        return 'Please log in again to perform this action.';
      case 'invalid-credential':
        return 'The provided credentials are invalid.';
      default:
        return 'Authentication error: ${e.message ?? e.code}';
    }
  }
}
