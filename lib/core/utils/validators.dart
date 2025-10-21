import '../constants/app_constants.dart';

/// Form validation utilities
class Validators {
  /// Validate email address
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.errorRequiredField;
    }

    if (!AppConstants.emailPattern.hasMatch(value)) {
      return AppConstants.errorInvalidEmail;
    }

    return null;
  }

  /// Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.errorRequiredField;
    }

    if (value.length < AppConstants.minPasswordLength) {
      return AppConstants.errorInvalidPassword;
    }

    if (value.length > AppConstants.maxPasswordLength) {
      return 'Password must be less than ${AppConstants.maxPasswordLength} characters.';
    }

    return null;
  }

  /// Validate password confirmation
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return AppConstants.errorRequiredField;
    }

    if (value != password) {
      return AppConstants.errorPasswordMismatch;
    }

    return null;
  }

  /// Validate username
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.errorRequiredField;
    }

    if (value.length < AppConstants.minUsernameLength ||
        value.length > AppConstants.maxUsernameLength) {
      return AppConstants.errorInvalidUsername;
    }

    if (!AppConstants.usernamePattern.hasMatch(value)) {
      return AppConstants.errorInvalidUsername;
    }

    return null;
  }

  /// Validate required field
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return fieldName != null
          ? '$fieldName is required'
          : AppConstants.errorRequiredField;
    }
    return null;
  }

  /// Validate full name
  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.errorRequiredField;
    }

    if (value.length < 2) {
      return 'Name must be at least 2 characters.';
    }

    if (value.length > 50) {
      return 'Name must be less than 50 characters.';
    }

    return null;
  }

  /// Validate quiz title
  static String? validateQuizTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Quiz title is required.';
    }

    if (value.length < 3) {
      return 'Quiz title must be at least 3 characters.';
    }

    if (value.length > 100) {
      return 'Quiz title must be less than 100 characters.';
    }

    return null;
  }

  /// Validate quiz description
  static String? validateQuizDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Quiz description is required.';
    }

    if (value.length < 10) {
      return 'Description must be at least 10 characters.';
    }

    if (value.length > 500) {
      return 'Description must be less than 500 characters.';
    }

    return null;
  }

  /// Validate positive number
  static String? validatePositiveNumber(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return fieldName != null
          ? '$fieldName is required'
          : AppConstants.errorRequiredField;
    }

    final number = int.tryParse(value);
    if (number == null || number <= 0) {
      return fieldName != null
          ? '$fieldName must be a positive number'
          : 'Must be a positive number';
    }

    return null;
  }

  /// Validate percentage (0-100)
  static String? validatePercentage(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return fieldName != null
          ? '$fieldName is required'
          : AppConstants.errorRequiredField;
    }

    final number = int.tryParse(value);
    if (number == null || number < 0 || number > 100) {
      return fieldName != null
          ? '$fieldName must be between 0 and 100'
          : 'Must be between 0 and 100';
    }

    return null;
  }

  /// Get password strength (0-4)
  static int getPasswordStrength(String password) {
    if (password.isEmpty) return 0;

    int strength = 0;

    // Length check
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;

    // Contains lowercase
    if (password.contains(RegExp(r'[a-z]'))) strength++;

    // Contains uppercase
    if (password.contains(RegExp(r'[A-Z]'))) strength++;

    // Contains number
    if (password.contains(RegExp(r'[0-9]'))) strength++;

    // Contains special character
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    // Normalize to 0-4 scale
    return (strength * 4 / 6).round().clamp(0, 4);
  }

  /// Get password strength label
  static String getPasswordStrengthLabel(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Strong';
      default:
        return 'Unknown';
    }
  }
}
