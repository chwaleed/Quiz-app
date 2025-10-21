import 'package:cloud_firestore/cloud_firestore.dart';

/// Admin Helper Utilities
///
/// These are helper functions to manage admin users.
/// Use these for initial setup or testing purposes.
///
/// ⚠️ SECURITY WARNING:
/// These functions should be removed or secured in production.
/// Consider using Firebase Admin SDK or Cloud Functions for production.
class AdminHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Make a user an admin by their email address
  ///
  /// Usage:
  /// ```dart
  /// await AdminHelper.makeUserAdmin('user@example.com');
  /// ```
  static Future<bool> makeUserAdmin(String email) async {
    try {
      // Find user by email
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('❌ User not found with email: $email');
        return false;
      }

      // Update role to admin
      final userId = querySnapshot.docs.first.id;
      await _firestore.collection('users').doc(userId).update({
        'role': 'admin',
      });

      print('✅ User $email is now an admin!');
      return true;
    } catch (e) {
      print('❌ Error making user admin: $e');
      return false;
    }
  }

  /// Make a user a regular user by their email address
  ///
  /// Usage:
  /// ```dart
  /// await AdminHelper.removeAdminRole('user@example.com');
  /// ```
  static Future<bool> removeAdminRole(String email) async {
    try {
      // Find user by email
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('❌ User not found with email: $email');
        return false;
      }

      // Update role to user
      final userId = querySnapshot.docs.first.id;
      await _firestore.collection('users').doc(userId).update({'role': 'user'});

      print('✅ Admin role removed from $email');
      return true;
    } catch (e) {
      print('❌ Error removing admin role: $e');
      return false;
    }
  }

  /// Check if a user is an admin by their email
  ///
  /// Usage:
  /// ```dart
  /// bool isAdmin = await AdminHelper.checkIfUserIsAdmin('user@example.com');
  /// ```
  static Future<bool> checkIfUserIsAdmin(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('❌ User not found with email: $email');
        return false;
      }

      final userData = querySnapshot.docs.first.data();
      final role = userData['role'] as String?;

      return role == 'admin';
    } catch (e) {
      print('❌ Error checking admin status: $e');
      return false;
    }
  }

  /// List all admin users
  ///
  /// Usage:
  /// ```dart
  /// List<Map<String, dynamic>> admins = await AdminHelper.listAllAdmins();
  /// ```
  static Future<List<Map<String, dynamic>>> listAllAdmins() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .get();

      final admins = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'uid': doc.id,
          'email': data['email'],
          'username': data['username'],
          'fullName': data['fullName'],
        };
      }).toList();

      print('📋 Found ${admins.length} admin(s)');
      return admins;
    } catch (e) {
      print('❌ Error listing admins: $e');
      return [];
    }
  }

  /// Create the first admin user (for initial setup)
  /// Call this once during development setup
  ///
  /// Usage:
  /// ```dart
  /// await AdminHelper.createFirstAdmin(
  ///   email: 'admin@example.com',
  ///   password: 'securepassword',
  ///   username: 'admin',
  ///   fullName: 'System Admin',
  /// );
  /// ```
  static Future<bool> createFirstAdmin({
    required String email,
    required String password,
    required String username,
    required String fullName,
  }) async {
    try {
      // This would need to be implemented with Firebase Auth
      // For now, just provide instructions
      print('''
      
      ⚠️ To create the first admin:
      
      1. Sign up normally with:
         Email: $email
         Password: $password
         Username: $username
         Name: $fullName
         
      2. Then run:
         await AdminHelper.makeUserAdmin('$email');
         
      ''');

      return false; // Not implemented - user must do it manually
    } catch (e) {
      print('❌ Error: $e');
      return false;
    }
  }
}
