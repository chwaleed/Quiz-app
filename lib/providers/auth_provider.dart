import 'package:flutter/foundation.dart';
import 'package:testproject/models/user_model.dart';
import 'package:testproject/services/auth_service.dart';
import 'package:testproject/services/database_service.dart';

/// Provider for managing authentication state and user data
///
/// This provider handles all authentication-related operations including:
/// - User sign in/sign up
/// - User sign out
/// - Password reset
/// - Profile updates
/// - Session management
/// - Role-based access control
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();

  // State variables
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isInitialized => _isInitialized;

  /// Initialize the provider by checking auth state
  /// This should be called when the app starts
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _setLoading(true);
      _clearError();

      // Check if user is already signed in
      final user = await _authService.getCurrentUserData();
      if (user != null) {
        _currentUser = user;
      }
    } catch (e) {
      _setError('Failed to initialize: ${e.toString()}');
      // Log the error but don't prevent initialization
      debugPrint('Auth initialization error: ${e.toString()}');
    } finally {
      _isInitialized = true;
      _setLoading(false);
    }
  }

  /// Sign up a new user with email and password
  ///
  /// Returns true if successful, false otherwise
  /// Error message will be available in [error] getter
  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
    required String fullName,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final user = await _authService.signUp(
        email: email,
        password: password,
        username: username,
        fullName: fullName,
      );

      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }

      _setError('Failed to create account');
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in an existing user with email and password
  ///
  /// Returns true if successful, false otherwise
  /// Error message will be available in [error] getter
  Future<bool> signIn({required String email, required String password}) async {
    try {
      _setLoading(true);
      _clearError();

      final user = await _authService.signIn(email: email, password: password);

      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }

      _setError('Failed to sign in');
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign out the current user
  ///
  /// Returns true if successful, false otherwise
  Future<bool> signOut() async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.signOut();
      _currentUser = null;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Send password reset email to the specified email address
  ///
  /// Returns true if successful, false otherwise
  Future<bool> resetPassword({required String email}) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.resetPassword(email: email);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update the current user's profile information
  ///
  /// Can update fullName, username, and/or profilePictureUrl
  /// Returns true if successful, false otherwise
  Future<bool> updateProfile({
    String? fullName,
    String? username,
    String? profilePictureUrl,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.updateProfile(
        fullName: fullName,
        username: username,
        profilePictureUrl: profilePictureUrl,
      );

      // Refresh user data
      await refreshUserData();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update the current user's email address
  ///
  /// This will send a verification email to the new address
  /// Returns true if successful, false otherwise
  Future<bool> updateEmail({required String newEmail}) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.updateEmail(newEmail: newEmail);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update email in Firestore after verification
  ///
  /// Should be called after user verifies the new email
  Future<bool> updateEmailInFirestore({required String newEmail}) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.updateEmailInFirestore(newEmail: newEmail);
      await refreshUserData();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update the current user's password
  ///
  /// Returns true if successful, false otherwise
  Future<bool> updatePassword({required String newPassword}) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.updatePassword(newPassword: newPassword);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete the current user's account
  ///
  /// This will delete all user data and sign out
  /// Returns true if successful, false otherwise
  Future<bool> deleteAccount() async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.deleteAccount();
      _currentUser = null;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh the current user's data from Firestore
  ///
  /// This is useful after updates to ensure we have the latest data
  Future<void> refreshUserData() async {
    try {
      if (_currentUser == null) return;

      final updatedUser = await _dbService.getUser(_currentUser!.uid);
      if (updatedUser != null) {
        _currentUser = updatedUser;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to refresh user data: ${e.toString()}');
    }
  }

  /// Clear any error messages
  void clearError() {
    _clearError();
  }

  /// Check if the current user has admin privileges
  bool hasAdminAccess() {
    return _currentUser?.isAdmin ?? false;
  }

  /// Get user's total points
  int getUserPoints() {
    return _currentUser?.totalPoints ?? 0;
  }

  /// Get user's pass rate percentage
  double getUserPassRate() {
    return _currentUser?.passRate ?? 0.0;
  }

  // Private helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    // Clean up resources
    super.dispose();
  }
}
